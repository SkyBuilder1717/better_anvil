local modpath = minetest.get_modpath(minetest.get_current_modname())
better_anvil = {
    registered_repairs = {}
}
dofile(modpath.."/api.lua")

minetest.register_node("better_anvil:anvil", {
    description = "Anvil",
	tiles = {
		"better_anvil_top.png",
		"better_anvil_top.png",
		"better_anvil_side1.png",
		"better_anvil_side1.png",
		"better_anvil_side2.png",
		"better_anvil_side2.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.3125, 0.0625, -0.4375, 0.375, 0.5, 0.4375},
			{-0.1875, -0.4375, -0.25, 0.25, 0.4375, 0.25},
			{-0.375, -0.5, -0.4375, 0.4375, -0.1875, 0.4375},
		}
	},
    groups = {cracky = 1, falling_node = 1, level = 1},
	sounds = default.node_sound_metal_defaults(),
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        if meta == nil then
            return
        end
        meta:set_string("formspec", better_anvil.get_formspec(true))
        local inv = meta:get_inventory()
        inv:set_size("input", 1)
        inv:set_size("modifier", 1)
        inv:set_size("output", 1)
    end,
	on_metadata_inventory_take = function(pos, list_name, i, stack, player)
		local meta = minetest.get_meta(pos)
	    local inv = meta:get_inventory()
		local mdstack = inv:get_stack("modifier", 1)
		if list_name == "output" then
			inv:set_stack("input", 1, "")
            if not mdstack:is_empty() then
				inv:set_stack("modifier", 1, "")
            end
			meta:set_string("formspec", better_anvil.get_formspec(true))
		elseif list_name == "modifier" then
			meta:set_string("formspec", better_anvil.get_formspec(true))
			inv:set_stack("output", 1, "")
		end
	end,
	allow_metadata_inventory_put = function(pos, list_name, index, itemstack, player)
		local meta = minetest.get_meta(pos)
	    local inv = meta:get_inventory()
		if list_name == "input" then
			local name = itemstack:get_name()
			meta:set_string("formspec", better_anvil.get_formspec(false))
			return 1
		elseif list_name == "modifier" then
			local istack = inv:get_stack("input", 1)
			local name = itemstack:get_name()
			if istack then
				local craft = minetest.get_craft_recipe(name)
				minetest.chat_send_all(dump(craft))
				if istack:get_name() == name then
					if (istack:get_wear() < itemstack:get_wear()) or (istack:get_wear() == itemstack:get_wear()) then
						return 1
					else
						return 0
					end
				elseif itemstack:get_definition().groups.dye == 1 then
					return 1
				else
					return 1
				end
			else
				meta:set_string("formspec", better_anvil.get_formspec(true))
				return 1
			end
		elseif list_name == "output" then
			meta:set_string("formspec", better_anvil.get_formspec(true))
			return 0
		end
		better_anvil.update(pos, fields)
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		better_anvil.update(pos, fields)
	end,
})
minetest.register_alias("anvil", "better_anvil:anvil")

minetest.register_craft({
	output = "better_anvil:anvil",
	recipe = {
		{"default:steelblock", "default:steelblock", "default:steelblock"},
		{"", "default:steel_ingot", ""},
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"}
	}
})