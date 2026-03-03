-- Lazarus Space: Formspec GUI for the Continuum Disrupter

function lazarus_space.build_formspec(pos)
	local meta = minetest.get_meta(pos)
	local state = meta:get_string("state")
	if state == "" then state = "idle" end
	local eu_input = meta:get_int("HV_EU_input")
	local eu_demand = meta:get_int("HV_EU_demand")
	local charge = meta:get_int("charge")
	local hash = minetest.hash_node_position(pos)
	local field = lazarus_space.active_fields[hash]

	-- Determine display status.
	local status
	if state == "idle" then
		status = "Idle -- Awaiting Activation"
	elseif state == "charging" then
		local pct = math.min(100,
			math.floor(charge / (lazarus_space.CHARGE_REQUIRED / 100)))
		if eu_demand > 0 and eu_input < eu_demand then
			status = "Insufficient Power -- Charging Paused ("
				.. pct .. "%)"
		else
			status = "Charging -- Accumulating Power ("
				.. pct .. "%)"
		end
	elseif state == "active" then
		status = "Field Active -- Time Frozen"
	elseif state == "warp_charging" then
		status = "Warp Device Charging"
	elseif state == "portal_growing" then
		status = "Portal Growing"
	elseif state == "portal_ready" then
		status = "Portal Ready"
	else
		status = state
	end

	local toggle_label, toggle_name
	if state == "idle" then
		toggle_label = "Activate"
		toggle_name = "activate"
	else
		toggle_label = "Deactivate"
		toggle_name = "deactivate"
	end

	local fs = "size[8,8.5]"
		.. "label[0.5,0.3;Continuum Disrupter]"
		.. "label[0.5,1.0;Status: "
			.. minetest.formspec_escape(status) .. "]"

	-- Show power info during charging.
	if state == "charging" then
		fs = fs
			.. "label[0.5,1.5;Power Draw: "
				.. eu_demand .. " EU/s]"
			.. "label[0.5,2.0;Power Input: "
				.. eu_input .. " EU/s]"
			.. "label[0.5,2.5;Charge: "
				.. math.min(100,
					math.floor(charge / (lazarus_space.CHARGE_REQUIRED / 100)))
				.. "%]"
	end

	-- Show field info when active.
	if field and (state == "active" or state == "warp_charging"
			or state == "portal_growing"
			or state == "portal_ready") then
		fs = fs
			.. "label[0.5,1.5;Field Radius: "
				.. field.radius .. " blocks]"
			.. "label[0.5,2.0;Field Status: Stable]"
		if field.reactor_found then
			fs = fs
				.. "label[0.5,2.5;Reactor Core: Detected"
					.. " (dig to transmute)]"
		end
	end

	fs = fs
		.. "button[0.5,3.5;3,1;" .. toggle_name .. ";"
			.. toggle_label .. "]"
		.. "label[0.5,5.5;WARNING: Field requires continuous]"
		.. "label[0.5,6.0;player presence. Leaving the area]"
		.. "label[0.5,6.5;will cause total field collapse.]"

	meta:set_string("formspec", fs)
	return fs
end
