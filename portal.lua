-- Lazarus Space: Portal growth, teleportation, and warp device interaction

local PORTAL_GROWTH_INTERVAL = 0.135 -- seconds between growth ticks
local PORTAL_TELEPORT_RANGE = 10000
local PORTAL_Y_MIN = 85
local PORTAL_Y_MAX = 120
local PORTAL_Y_SCAN = 5 -- vertical scan range for terrain following
local WARP_CHARGE_TIME = 3.0 -- seconds for warp device glow charge
local WARP_GLOW_STAGES = 4 -- number of glow brightness levels
local PORTAL_ACTIVATE_DELAY = 2.0 -- seconds after coating before teleport

--- Find the ground surface Y at a given X/Z, searching within
--- scan_range blocks above and below ref_y. Returns the Y
--- position to place a portal on (one above the surface), or
--- nil if no solid ground is found.
local function find_ground_y(x, z, ref_y, scan_range)
	-- Scan from top to bottom for the first solid block
	-- that has a non-solid (or air) block above it.
	for y = ref_y + scan_range, ref_y - scan_range, -1 do
		local check = {x = x, y = y, z = z}
		local node = minetest.get_node(check)
		if node.name == "ignore" then goto next_y end
		local def = minetest.registered_nodes[node.name]
		if def and def.walkable then
			-- Found solid ground. Portal goes on top.
			local above = {x = x, y = y + 1, z = z}
			local above_node = minetest.get_node(above)
			if above_node.name == "air"
					or lazarus_space.is_portal(
					above_node.name) then
				return y + 1
			end
			-- Solid block with something non-air above it
			-- (e.g. another solid block). Keep scanning down.
		end
		::next_y::
	end
	return nil
end

--- Analyze surrounding surfaces and select the best portal
--- variant to coat all touching faces. Returns the variant
--- node name if valid, nil if not.
--- Check whether a node is a liquid (water, lava, etc.).
local function is_liquid_node(name)
	local def = minetest.registered_nodes[name]
	return def and def.liquidtype and def.liquidtype ~= "none"
end

local function select_portal_variant(pos)
	local node = minetest.get_node(pos)
	-- Accept air and liquid positions as valid coating targets.
	-- Liquid blocks are consumed and replaced by portal.
	if node.name ~= "air" and not is_liquid_node(node.name) then
		return nil
	end

	-- Check all 6 neighbors for solid surfaces.
	-- Inclusive check: anything that is not air, not ignore,
	-- not a portal variant, and not a liquid counts as solid.
	-- This covers leaves, fences, glass, and all other blocks.
	local solid_faces = {}
	for _, fd in ipairs(lazarus_space.FACE_DIRS) do
		local np = vector.add(pos, fd)
		local nnode = minetest.get_node(np)
		if nnode.name ~= "air"
				and nnode.name ~= "ignore"
				and not lazarus_space.is_portal(nnode.name)
				and not is_liquid_node(nnode.name) then
			solid_faces[#solid_faces + 1] = fd.face
		end
	end

	if #solid_faces == 0 then return nil end

	-- Sort for canonical lookup key.
	table.sort(solid_faces)
	local key = table.concat(solid_faces, "+")
	return lazarus_space.PORTAL_LOOKUP[key]
end

-- ============================================================
-- WARP DEVICE INTERACTION
-- ============================================================

-- Build a portal-trigger on_rightclick for a given jumpdrive node.
local function make_portal_rightclick(node_name, original_rightclick)

	-- Fallthrough: show original behavior or metadata formspec.
	local function show_original(pos, node, clicker,
			itemstack, pointed_thing)
		if original_rightclick then
			return original_rightclick(
				pos, node, clicker,
				itemstack, pointed_thing)
		end
		-- No original callback; open metadata formspec.
		if clicker:is_player() then
			local fmeta = minetest.get_meta(pos)
			local fs = fmeta:get_string("formspec")
			if fs ~= "" then
				minetest.show_formspec(
					clicker:get_player_name(),
					"nodemeta:" .. pos.x .. ","
						.. pos.y .. "," .. pos.z,
					fs)
			end
		end
		return itemstack
	end

	return function(pos, node, clicker, itemstack, pointed_thing)
		-- Diagnostic: log every right-click on this node.
		local clicker_name = clicker:is_player()
			and clicker:get_player_name() or "non-player"
		minetest.log("action",
			"Lazarus Space: on_rightclick fired on "
			.. node_name .. " at "
			.. minetest.pos_to_string(pos)
			.. " by " .. clicker_name)

		-- Check: is the warp device inside an active field?
		local in_field = false
		local field_hash = nil
		for hash, field in pairs(
				lazarus_space.active_fields) do
			if field.state == "active" then
				local d = vector.distance(pos, field.pos)
				if d <= field.radius then
					in_field = true
					field_hash = hash
					break
				end
			end
		end

		if not in_field then
			minetest.log("action",
				"Lazarus Space: " .. node_name
				.. " not inside active field,"
				.. " falling through")
			return show_original(pos, node, clicker,
				itemstack, pointed_thing)
		end

		-- Check: is the player holding decaying uranium?
		local held_name = itemstack:get_name()
		if held_name ~= "lazarus_space:decaying_uranium" then
			minetest.log("action",
				"Lazarus Space: player holding '"
				.. held_name
				.. "', not decaying uranium,"
				.. " falling through")
			return show_original(pos, node, clicker,
				itemstack, pointed_thing)
		end

		-- Both conditions met: start warp charge sequence.
		minetest.log("action",
			"Lazarus Space: WARP CHARGE — both"
			.. " conditions met at "
			.. minetest.pos_to_string(pos))

		-- Consume uranium from hand.
		itemstack:take_item(1)

		-- Swap warp device to first glow stage.
		minetest.set_node(pos,
			{name = "lazarus_space:warp_glow_1"})

		-- Track charge state in the field.
		local field = lazarus_space.active_fields[field_hash]
		if field then
			field.state = "warp_charging"
			field.warp_charge_pos = vector.new(pos)
			field.warp_charge_timer = 0
			field.warp_charge_stage = 1

			-- Update device formspec.
			local meta = minetest.get_meta(field.pos)
			meta:set_string("state", "warp_charging")
			lazarus_space.build_formspec(field.pos)
		end

		minetest.log("action",
			"Lazarus Space: warp charge started at "
			.. minetest.pos_to_string(pos))

		return itemstack
	end
end

-- Override jumpdrive:warp_device for portal trigger.
minetest.register_on_mods_loaded(function()
	local target = "jumpdrive:warp_device"
	local def = minetest.registered_nodes[target]

	if not def then
		minetest.log("warning",
			"Lazarus Space: " .. target .. " not found,"
			.. " portal trigger disabled")
		return
	end

	minetest.log("action",
		"Lazarus Space: found " .. target
		.. ", installing portal trigger")

	local original_rc = def.on_rightclick
	local new_rc = make_portal_rightclick(target, original_rc)

	minetest.override_item(target, {
		on_rightclick = new_rc,
	})

	-- Verify the override was actually applied.
	local verify = minetest.registered_nodes[target]
	if verify and verify.on_rightclick == new_rc then
		minetest.log("action",
			"Lazarus Space: override VERIFIED for "
			.. target)
	else
		minetest.log("error",
			"Lazarus Space: override FAILED for "
			.. target
			.. " — on_rightclick not applied!")
	end
end)

-- ============================================================
-- WARP DEVICE CHARGE SEQUENCE
-- ============================================================

--- Place a portal block at pos and record it. Returns true
--- if placed, false if position was not suitable.
local function place_portal_block(field, p)
	local variant = select_portal_variant(p)
	if not variant then return false end
	minetest.set_node(p, {name = variant})
	field.portal_positions[
		#field.portal_positions + 1] = p
	return true
end

--- Begin portal growth at a position (called when charge completes).
--- Simple uniform flood fill expanding from the seed position.
local function begin_portal_growth(field, pos)
	field.state = "portal_growing"
	field.portal_origin = vector.new(pos)
	field.portal_timer = 0

	-- Place seed at warp device position.
	local seed_y = find_ground_y(
		pos.x, pos.z, pos.y, PORTAL_Y_SCAN)
	if not seed_y then seed_y = pos.y end
	local seed = {x = pos.x, y = seed_y, z = pos.z}

	field.portal_positions = {}

	-- Place central seed block.
	if not place_portal_block(field, seed) then
		minetest.set_node(seed,
			{name = "lazarus_space:portal_1f_floor"})
		field.portal_positions[1] = seed
	end

	-- Frontier starts with just the seed.
	field.portal_frontier = {seed}

	-- Persistent visited set so the flood fill never
	-- re-checks positions across ticks.
	field.portal_visited = {}
	local sk = seed.x .. ":" .. seed.y .. ":" .. seed.z
	field.portal_visited[sk] = true

	-- Update device metadata.
	local meta = minetest.get_meta(field.pos)
	meta:set_string("state", "portal_growing")
	lazarus_space.build_formspec(field.pos)

	minetest.log("action",
		"Lazarus Space: portal flood fill started at "
		.. minetest.pos_to_string(pos))
end

-- Globalstep: advance warp device charge, swap glow stages.
minetest.register_globalstep(function(dtime)
	for hash, field in pairs(lazarus_space.active_fields) do
		if field.state ~= "warp_charging" then
			goto next_field
		end

		field.warp_charge_timer = field.warp_charge_timer
			+ dtime
		-- Calculate which glow stage we should be at.
		local progress = field.warp_charge_timer
			/ WARP_CHARGE_TIME
		local target_stage = math.min(WARP_GLOW_STAGES,
			math.floor(progress * WARP_GLOW_STAGES) + 1)

		-- Swap to next glow stage if needed.
		if target_stage > field.warp_charge_stage then
			field.warp_charge_stage = target_stage
			local glow_pos = field.warp_charge_pos
			minetest.set_node(glow_pos, {
				name = "lazarus_space:warp_glow_"
					.. target_stage,
			})
		end

		-- Charge complete: remove glow, start portal.
		if field.warp_charge_timer >= WARP_CHARGE_TIME then
			local glow_pos = field.warp_charge_pos
			minetest.set_node(glow_pos, {name = "air"})

			-- Clear charge tracking.
			field.warp_charge_pos = nil
			field.warp_charge_timer = nil
			field.warp_charge_stage = nil

			-- Begin portal growth.
			begin_portal_growth(field, glow_pos)
		end

		::next_field::
	end
end)

-- ============================================================
-- PORTAL GROWTH ANIMATION
-- ============================================================

-- 6 cardinal directions for flood fill expansion.
local FLOOD_DIRS = {
	{x = 1, y = 0, z = 0},
	{x = -1, y = 0, z = 0},
	{x = 0, y = 1, z = 0},
	{x = 0, y = -1, z = 0},
	{x = 0, y = 0, z = 1},
	{x = 0, y = 0, z = -1},
}

local growth_timer = 0
minetest.register_globalstep(function(dtime)
	-- Activation delay runs every frame (not gated by
	-- growth interval) to track real elapsed time.
	for hash, field in pairs(lazarus_space.active_fields) do
		if field.state == "portal_waiting" then
			field.portal_activate_timer =
				field.portal_activate_timer + dtime
			if field.portal_activate_timer
					>= PORTAL_ACTIVATE_DELAY then
				local elapsed = minetest.get_us_time()
					- field.portal_activate_start
				-- Delay elapsed. Portal is active.
				field.state = "portal_ready"
				field.portal_activate_timer = nil
				field.portal_activate_start = nil
				local meta = minetest.get_meta(
					field.pos)
				meta:set_string("state",
					"portal_ready")
				lazarus_space.build_formspec(field.pos)
				-- Activation cue.
				minetest.add_particlespawner({
					amount = 200,
					time = 0.5,
					minpos = vector.subtract(
						field.pos,
						field.radius * 0.5),
					maxpos = vector.add(
						field.pos,
						field.radius * 0.5),
					minvel = {x = -1, y = -1, z = -1},
					maxvel = {x = 1, y = 1, z = 1},
					minacc = {x = 0, y = 0, z = 0},
					maxacc = {x = 0, y = 0, z = 0},
					minexptime = 1,
					maxexptime = 3,
					minsize = 0.5,
					maxsize = 1.5,
					texture =
						"lazarus_space_lazarus_portal.png",
					glow = 14,
				})
				for _, player in ipairs(
						minetest
						.get_connected_players()) do
					local d = vector.distance(
						player:get_pos(), field.pos)
					if d <= field.radius + 16 then
						minetest.chat_send_player(
							player:get_player_name(),
							"The portal is ready.")
					end
				end
				minetest.log("action",
					"Lazarus Space: portal active"
					.. " after "
					.. string.format("%.1f",
						elapsed / 1000000)
					.. "s delay")
			end
		end
	end

	growth_timer = growth_timer + dtime
	if growth_timer < PORTAL_GROWTH_INTERVAL then return end
	growth_timer = 0

	for hash, field in pairs(lazarus_space.active_fields) do
		if field.state ~= "portal_growing" then
			goto continue
		end
		if not field.portal_frontier then
			goto continue
		end

		-- Frontier empty: flood fill reached all connected
		-- positions. Brute-force sweep the entire sphere
		-- to catch unreachable pockets (sealed rooms).
		if #field.portal_frontier == 0 then
			local r = field.radius
			local center = field.pos
			local sweep_placed = 0
			for dx = -r, r do
				for dy = -r, r do
					for dz = -r, r do
						local dist = math.sqrt(
							dx * dx + dy * dy
							+ dz * dz)
						if dist <= r then
							local p = {
								x = center.x + dx,
								y = center.y + dy,
								z = center.z + dz,
							}
							if place_portal_block(
									field, p) then
								sweep_placed =
									sweep_placed + 1
							end
						end
					end
				end
			end

			-- Growth complete. Start 5s delay.
			field.state = "portal_waiting"
			field.portal_frontier = nil
			field.portal_visited = nil
			field.portal_activate_timer = 0
			field.portal_activate_start =
				minetest.get_us_time()
			local meta = minetest.get_meta(
				field.pos)
			meta:set_string("state",
				"portal_waiting")
			lazarus_space.build_formspec(field.pos)
			minetest.log("action",
				"Lazarus Space: flood fill complete,"
				.. " " .. #field.portal_positions
				.. " portal blocks placed"
				.. " (sweep caught "
				.. sweep_placed .. "),"
				.. " delay timer started")
			goto continue
		end

		-- Flood fill: expand every frontier position
		-- in all 6 directions simultaneously. Expands
		-- through air AND portal positions so the wave
		-- reaches all surfaces including those behind
		-- open gaps.
		local new_frontier = {}
		local visited = field.portal_visited
		for _, fpos in ipairs(field.portal_frontier) do
			for _, d in ipairs(FLOOD_DIRS) do
				local np = vector.add(fpos, d)
				local k = np.x .. ":" .. np.y
					.. ":" .. np.z
				if not visited[k] then
					visited[k] = true
					local dist = vector.distance(
						np, field.pos)
					if dist <= field.radius then
						-- Try to place portal.
						local placed =
							place_portal_block(
								field, np)
						if placed then
							new_frontier[
								#new_frontier + 1]
								= np
						else
							-- Not placed. Add to
							-- frontier if position
							-- is traversable (air,
							-- liquid, or non-walkable)
							-- so the wave continues
							-- through open space.
							local node =
								minetest.get_node(
									np)
							if node.name
									~= "ignore"
									then
								local def =
									minetest
									.registered_nodes
									[node.name]
								if not def
										or not
										def.walkable
										or is_liquid_node(
										node.name)
										then
									new_frontier[
										#new_frontier
										+ 1] = np
								end
							end
						end
					end
				end
			end
		end
		field.portal_frontier = new_frontier

		::continue::
	end
end)

-- ============================================================
-- PORTAL TELEPORTATION
-- ============================================================

minetest.register_globalstep(function(dtime)
	for _, player in ipairs(minetest.get_connected_players()) do
		local pos = player:get_pos()
		local node = minetest.get_node(vector.round(pos))
		-- Also check the node at feet level.
		local feet_node = minetest.get_node({
			x = math.floor(pos.x + 0.5),
			y = math.floor(pos.y),
			z = math.floor(pos.z + 0.5),
		})

		if not lazarus_space.is_portal(node.name)
				and not lazarus_space.is_portal(
				feet_node.name) then
			goto next_player
		end

		-- Player is touching a portal. Find which field.
		local field_pos = nil
		for hash, field in pairs(lazarus_space.active_fields) do
			if field.state == "portal_ready" then
				local d = vector.distance(pos, field.pos)
				if d <= field.radius then
					field_pos = field.pos
					break
				end
			end
		end

		if not field_pos then goto next_player end

		-- Teleport to random surface position.
		local dest_x = math.random(-PORTAL_TELEPORT_RANGE,
			PORTAL_TELEPORT_RANGE)
		local dest_z = math.random(-PORTAL_TELEPORT_RANGE,
			PORTAL_TELEPORT_RANGE)
		local dest_y = PORTAL_Y_MAX

		-- Scan downward for solid surface.
		for y = PORTAL_Y_MAX, PORTAL_Y_MIN, -1 do
			local check = {x = dest_x, y = y, z = dest_z}
			local n = minetest.get_node(check)
			local def = minetest.registered_nodes[n.name]
			if def and def.walkable then
				dest_y = y + 1
				break
			end
		end
		dest_y = math.max(PORTAL_Y_MIN,
			math.min(PORTAL_Y_MAX, dest_y))

		player:set_pos({x = dest_x, y = dest_y, z = dest_z})

		minetest.log("action",
			"Lazarus Space: teleported "
			.. player:get_player_name()
			.. " to " .. dest_x .. "," .. dest_y
			.. "," .. dest_z)

		-- Collapse the field behind them.
		lazarus_space.teardown_field(field_pos)

		::next_player::
	end
end)
