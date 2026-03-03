-- Lazarus Space: Node registrations and crafting

-- ============================================================
-- CONTINUUM DISRUPTER — INACTIVE
-- ============================================================

minetest.register_node("lazarus_space:continuum_disrupter", {
	description = "Continuum Disrupter",
	tiles = {
		"lazarus_space_disrupter_top.png",
		"lazarus_space_disrupter_bottom.png",
		"lazarus_space_disrupter_side.png",
		"lazarus_space_disrupter_side.png",
		"lazarus_space_disrupter_side.png",
		"lazarus_space_disrupter_front.png",
	},
	paramtype2 = "facedir",
	groups = {
		cracky = 1,
		technic_machine = 1,
		technic_hv = 1,
		oddly_breakable_by_hand = 1,
	},
	connect_sides = {"bottom", "back"},
	is_ground_content = false,
	sounds = default.node_sound_stone_defaults(),
	on_construct = function(pos)
		lazarus_space.on_construct(pos)
	end,
	on_destruct = function(pos)
		lazarus_space.on_destruct(pos)
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		lazarus_space.on_receive_fields(pos, formname, fields, sender)
	end,
	technic_run = function(pos, node)
		lazarus_space.technic_run(pos, node)
	end,
	technic_on_disable = function(pos, node)
		lazarus_space.technic_on_disable(pos, node)
	end,
})

-- ============================================================
-- CONTINUUM DISRUPTER — ACTIVE
-- ============================================================

minetest.register_node("lazarus_space:continuum_disrupter_active", {
	description = "Continuum Disrupter",
	tiles = {
		"lazarus_space_disrupter_top.png",
		"lazarus_space_disrupter_bottom.png",
		"lazarus_space_disrupter_side.png",
		"lazarus_space_disrupter_side.png",
		"lazarus_space_disrupter_side.png",
		"lazarus_space_disrupter_front_active.png",
	},
	paramtype2 = "facedir",
	groups = {
		cracky = 1,
		technic_machine = 1,
		technic_hv = 1,
		oddly_breakable_by_hand = 1,
		not_in_creative_inventory = 1,
	},
	connect_sides = {"bottom", "back"},
	is_ground_content = false,
	light_source = 8,
	sounds = default.node_sound_stone_defaults(),
	drop = "lazarus_space:continuum_disrupter",
	on_construct = function(pos)
		lazarus_space.on_construct(pos)
	end,
	on_destruct = function(pos)
		lazarus_space.on_destruct(pos)
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		lazarus_space.on_receive_fields(pos, formname, fields, sender)
	end,
	technic_run = function(pos, node)
		lazarus_space.technic_run(pos, node)
	end,
	technic_on_disable = function(pos, node)
		lazarus_space.technic_on_disable(pos, node)
	end,
})

-- ============================================================
-- TECHNIC MACHINE REGISTRATION
-- ============================================================

technic.register_machine("HV",
	"lazarus_space:continuum_disrupter", technic.receiver)
technic.register_machine("HV",
	"lazarus_space:continuum_disrupter_active", technic.receiver)

-- ============================================================
-- DISRUPTED SPACE — INDESTRUCTIBLE FIELD BARRIER (20 variants)
-- ============================================================

-- Keep original for backward compatibility with existing worlds.
minetest.register_node("lazarus_space:disrupted_space", {
	description = "Disrupted Space",
	drawtype = "glasslike",
	tiles = {{
		name = "lazarus_space_disrupted_space.png",
		animation = {
			type = "vertical_frames",
			aspect_w = 16,
			aspect_h = 16,
			length = 8.0,
		},
	}},
	paramtype = "light",
	sunlight_propagates = false,
	walkable = true,
	diggable = false,
	pointable = false,
	drop = "",
	is_ground_content = false,
	groups = {not_in_creative_inventory = 1},
	on_blast = function() end, -- immune to explosions
})

-- 20 opacity variants for smooth visual blending across the shell.
-- Variant 1 = most opaque (alpha ~90), variant 20 = most
-- transparent (alpha ~10). Nearly invisible in most areas.
-- The shell is felt more than seen.
for i = 1, 20 do
	minetest.register_node(
		"lazarus_space:disrupted_space_" .. i, {
		description = "Disrupted Space",
		drawtype = "glasslike",
		tiles = {{
			name = "lazarus_space_disrupted_space_" .. i .. ".png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 8.0,
			},
		}},
		paramtype = "light",
		use_texture_alpha = "blend",
		sunlight_propagates = false,
		walkable = true,
		diggable = false,
		pointable = false,
		drop = "",
		is_ground_content = false,
		groups = {not_in_creative_inventory = 1},
		on_blast = function() end,
	})
end

-- ============================================================
-- DECAYING URANIUM — UNSTABLE TRANSMUTED CORE
-- ============================================================

minetest.register_node("lazarus_space:decaying_uranium", {
	description = "Decaying Uranium",
	tiles = {{
		name = "lazarus_space_decaying_uranium.png",
		animation = {
			type = "vertical_frames",
			aspect_w = 16,
			aspect_h = 16,
			length = 1.6,
		},
	}},
	light_source = minetest.LIGHT_MAX,
	is_ground_content = false,
	groups = {cracky = 2, not_in_creative_inventory = 1},
	sounds = default.node_sound_stone_defaults(),
})

-- ============================================================
-- LAZARUS PORTAL — GROUND SURFACE PORTAL
-- ============================================================

minetest.register_node("lazarus_space:lazarus_portal", {
	description = "Lazarus Portal",
	drawtype = "nodebox",
	tiles = {"lazarus_space_lazarus_portal.png"},
	node_box = {
		type = "wallmounted",
		wall_bottom = {-0.5, -0.5, -0.5, 0.5, -0.5 + 1/16, 0.5},
		wall_top = {-0.5, 0.5 - 1/16, -0.5, 0.5, 0.5, 0.5},
		wall_side = {-0.5, -0.5, -0.5, -0.5 + 1/16, 0.5, 0.5},
	},
	paramtype = "light",
	paramtype2 = "wallmounted",
	walkable = false,
	pointable = false,
	buildable_to = false,
	sunlight_propagates = false,
	is_ground_content = false,
	drop = "",
	groups = {not_in_creative_inventory = 1},
})

-- ============================================================
-- PORTAL SURFACE COATING VARIANTS (26 variants)
-- ============================================================

-- Thin slab thickness (1/16 of a block).
local PT = 1/16

-- Base slab boxes for each face direction.
-- Each box is {x1, y1, z1, x2, y2, z2}.
local FACE_BOXES = {
	floor   = {-0.5, -0.5, -0.5, 0.5, -0.5 + PT, 0.5},
	ceiling = {-0.5, 0.5 - PT, -0.5, 0.5, 0.5, 0.5},
	wall_n  = {-0.5, -0.5, 0.5 - PT, 0.5, 0.5, 0.5},
	wall_s  = {-0.5, -0.5, -0.5, 0.5, 0.5, -0.5 + PT},
	wall_e  = {0.5 - PT, -0.5, -0.5, 0.5, 0.5, 0.5},
	wall_w  = {-0.5, -0.5, -0.5, -0.5 + PT, 0.5, 0.5},
}

-- Direction vector to face name mapping.
lazarus_space.FACE_DIRS = {
	{x = 0, y = -1, z = 0, face = "floor"},
	{x = 0, y = 1, z = 0, face = "ceiling"},
	{x = 1, y = 0, z = 0, face = "wall_e"},
	{x = -1, y = 0, z = 0, face = "wall_w"},
	{x = 0, y = 0, z = 1, face = "wall_n"},
	{x = 0, y = 0, z = -1, face = "wall_s"},
}

-- All 26 portal variants: 6 flat + 12 edge + 8 corner.
local PORTAL_VARIANTS = {
	-- 6 flat face variants
	{name = "portal_floor", faces = {"floor"}},
	{name = "portal_ceiling", faces = {"ceiling"}},
	{name = "portal_wall_n", faces = {"wall_n"}},
	{name = "portal_wall_s", faces = {"wall_s"}},
	{name = "portal_wall_e", faces = {"wall_e"}},
	{name = "portal_wall_w", faces = {"wall_w"}},
	-- 12 edge variants (L-shaped, two perpendicular slabs)
	{name = "portal_edge_floor_n", faces = {"floor", "wall_n"}},
	{name = "portal_edge_floor_s", faces = {"floor", "wall_s"}},
	{name = "portal_edge_floor_e", faces = {"floor", "wall_e"}},
	{name = "portal_edge_floor_w", faces = {"floor", "wall_w"}},
	{name = "portal_edge_ceiling_n",
		faces = {"ceiling", "wall_n"}},
	{name = "portal_edge_ceiling_s",
		faces = {"ceiling", "wall_s"}},
	{name = "portal_edge_ceiling_e",
		faces = {"ceiling", "wall_e"}},
	{name = "portal_edge_ceiling_w",
		faces = {"ceiling", "wall_w"}},
	{name = "portal_edge_n_e", faces = {"wall_n", "wall_e"}},
	{name = "portal_edge_n_w", faces = {"wall_n", "wall_w"}},
	{name = "portal_edge_s_e", faces = {"wall_s", "wall_e"}},
	{name = "portal_edge_s_w", faces = {"wall_s", "wall_w"}},
	-- 8 inside corner variants (three-sided)
	{name = "portal_corner_floor_n_e",
		faces = {"floor", "wall_n", "wall_e"}},
	{name = "portal_corner_floor_n_w",
		faces = {"floor", "wall_n", "wall_w"}},
	{name = "portal_corner_floor_s_e",
		faces = {"floor", "wall_s", "wall_e"}},
	{name = "portal_corner_floor_s_w",
		faces = {"floor", "wall_s", "wall_w"}},
	{name = "portal_corner_ceiling_n_e",
		faces = {"ceiling", "wall_n", "wall_e"}},
	{name = "portal_corner_ceiling_n_w",
		faces = {"ceiling", "wall_n", "wall_w"}},
	{name = "portal_corner_ceiling_s_e",
		faces = {"ceiling", "wall_s", "wall_e"}},
	{name = "portal_corner_ceiling_s_w",
		faces = {"ceiling", "wall_s", "wall_w"}},
}

-- Register all 26 variants.
for _, variant in ipairs(PORTAL_VARIANTS) do
	local boxes = {}
	for _, face in ipairs(variant.faces) do
		boxes[#boxes + 1] = FACE_BOXES[face]
	end
	minetest.register_node(
		"lazarus_space:" .. variant.name, {
		description = "Lazarus Portal",
		drawtype = "nodebox",
		tiles = {"lazarus_space_lazarus_portal.png"},
		node_box = {
			type = "fixed",
			fixed = boxes,
		},
		paramtype = "light",
		walkable = false,
		pointable = false,
		buildable_to = false,
		sunlight_propagates = false,
		is_ground_content = false,
		drop = "",
		groups = {not_in_creative_inventory = 1},
	})
end

-- Build lookup table: sorted face key -> node name.
lazarus_space.PORTAL_LOOKUP = {}
for _, variant in ipairs(PORTAL_VARIANTS) do
	local sorted = {}
	for _, f in ipairs(variant.faces) do
		sorted[#sorted + 1] = f
	end
	table.sort(sorted)
	local key = table.concat(sorted, "+")
	lazarus_space.PORTAL_LOOKUP[key] =
		"lazarus_space:" .. variant.name
end

-- ============================================================
-- PORTAL CRAMPED SPACE VARIANTS (4, 5, and 6-face)
-- ============================================================

-- Generate all combinations of k faces from the sorted list.
local ALL_FACE_NAMES = {
	"ceiling", "floor", "wall_e", "wall_n", "wall_s", "wall_w",
}

local function face_subsets(k)
	local results = {}
	local function recurse(start, current)
		if #current == k then
			local copy = {}
			for i, v in ipairs(current) do copy[i] = v end
			results[#results + 1] = copy
			return
		end
		for i = start, #ALL_FACE_NAMES do
			current[#current + 1] = ALL_FACE_NAMES[i]
			recurse(i + 1, current)
			current[#current] = nil
		end
	end
	recurse(1, {})
	return results
end

for face_count = 4, 6 do
	for _, face_set in ipairs(face_subsets(face_count)) do
		-- Build node name: portal_4f_ceiling_floor_wall_n_wall_s
		local name = "portal_" .. face_count .. "f"
		for _, f in ipairs(face_set) do
			name = name .. "_" .. f
		end

		-- Build nodebox with a thin slab for each face.
		local boxes = {}
		for _, f in ipairs(face_set) do
			boxes[#boxes + 1] = FACE_BOXES[f]
		end

		minetest.register_node(
			"lazarus_space:" .. name, {
			description = "Lazarus Portal",
			drawtype = "nodebox",
			tiles = {"lazarus_space_lazarus_portal.png"},
			node_box = {
				type = "fixed",
				fixed = boxes,
			},
			paramtype = "light",
			walkable = false,
			pointable = false,
			buildable_to = false,
			sunlight_propagates = false,
			is_ground_content = false,
			drop = "",
			groups = {not_in_creative_inventory = 1},
		})

		-- Add to lookup table.
		local key = table.concat(face_set, "+")
		lazarus_space.PORTAL_LOOKUP[key] =
			"lazarus_space:" .. name
	end
end

-- ============================================================
-- WARP DEVICE GLOW STAGES (portal charge buildup)
-- ============================================================

-- 4 stages of increasing glow with progressively brighter
-- white overlay on the original jumpdrive warp device texture.
-- Colorize alpha: 15% -> 40% -> 70% -> 90% white overlay.
local GLOW_LIGHT = {4, 7, 10, minetest.LIGHT_MAX}
local GLOW_COLORIZE = {38, 102, 178, 230}

-- Register with placeholder tiles; overridden after mods loaded.
for i, light in ipairs(GLOW_LIGHT) do
	minetest.register_node(
		"lazarus_space:warp_glow_" .. i, {
		description = "Warp Device (Charging " .. i .. ")",
		tiles = {"lazarus_space_disrupter_front.png"},
		paramtype = "light",
		light_source = light,
		diggable = false,
		pointable = false,
		walkable = true,
		is_ground_content = false,
		drop = "",
		groups = {not_in_creative_inventory = 1},
	})
end

-- After all mods loaded, read the jumpdrive warp device texture
-- and apply progressively brighter white overlays.
minetest.register_on_mods_loaded(function()
	local base_tiles = nil
	local def = minetest.registered_nodes["jumpdrive:warp_device"]
	if def and def.tiles then
		base_tiles = {}
		for ti, tile in ipairs(def.tiles) do
			if type(tile) == "string" then
				base_tiles[ti] = tile
			elseif type(tile) == "table" and tile.name then
				base_tiles[ti] = tile.name
			else
				base_tiles[ti] =
					"lazarus_space_disrupter_front.png"
			end
		end
	end

	if not base_tiles or #base_tiles == 0 then
		base_tiles = {"lazarus_space_disrupter_front.png"}
		minetest.log("warning",
			"Lazarus Space: jumpdrive:warp_device texture"
			.. " not found, using fallback for glow")
	end

	for i, alpha in ipairs(GLOW_COLORIZE) do
		local glow_tiles = {}
		for ti, tex in ipairs(base_tiles) do
			glow_tiles[ti] = tex
				.. "^[colorize:#FFFFFF:" .. alpha
		end
		minetest.override_item(
			"lazarus_space:warp_glow_" .. i, {
			tiles = glow_tiles,
		})
	end

	minetest.log("action",
		"Lazarus Space: warp glow textures set using "
		.. base_tiles[1])
end)

-- ============================================================
-- CRAFTING RECIPE
-- ============================================================

minetest.register_craft({
	output = "lazarus_space:continuum_disrupter",
	recipe = {
		{"default:mese", "technic:stainless_steel_ingot",
			"default:mese"},
		{"technic:stainless_steel_ingot",
			"technic:hv_transformer",
			"technic:stainless_steel_ingot"},
		{"default:mese", "default:diamondblock",
			"default:mese"},
	},
})
