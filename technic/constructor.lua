
minetest.register_craft({
	type = "shapeless",
	output = 'technic:constructor_mk1_off 1',
	recipe = {'technic:nodebreaker_off', 'technic:deployer_off'},
})

minetest.register_craft({
	type = "shapeless",
	output = 'technic:constructor_mk2_off 1',
	recipe = {'technic:constructor_mk1_off', 'technic:constructor_mk1_off'},
})

minetest.register_craft({
	type = "shapeless",
	output = 'technic:constructor_mk3_off 1',
	recipe = {'technic:constructor_mk2_off', 'technic:constructor_mk2_off'},
})

local mk_inv_sizes = { 1, 2, 4 }

for mk = 1, 3 do

	local ctor_on_name = "technic:constructor_mk"..mk.."_on"
	local ctor_off_name = "technic:constructor_mk"..mk.."_off"
	local ctor_inv_size = mk_inv_sizes[mk]

	local function ctor_on(pos, node)
		if node.name == ctor_off_name then
			technic_construct_nodes(pos, ctor_inv_size)
			technic_swap_node(pos, ctor_on_name)
			nodeupdate(pos)
		end
	end

	local function ctor_off(pos, node)
		if node.name == ctor_on_name then
			technic_swap_node(pos, ctor_off_name)
			nodeupdate(pos)
		end
	end

	minetest.register_node(ctor_off_name, {
		description = "Constructor MK"..mk,
		tile_images = {
			"technic_constructor_mk"..mk.."_top_off.png",
			"technic_constructor_mk"..mk.."_bottom_off.png",
			"technic_constructor_mk"..mk.."_side2_off.png",
			"technic_constructor_mk"..mk.."_side1_off.png",
			"technic_constructor_back.png",
			"technic_constructor_front_off.png"
		},
		is_ground_content = true,
		paramtype2 = "facedir",
		groups = {snappy=2,choppy=2,oddly_breakable_by_hand=2, mesecon_receptor_off = 1, mesecon_effector_off = 1, mesecon = 2},
		mesecons= {effector={action_on=ctor_on}},
		sounds = default.node_sound_stone_defaults(),
		on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			local formspec = "invsize[8,9;]label[0,0;Constructor MK1]"

			for i = 1, ctor_inv_size do
				formspec = formspec..
				  "label[5,"..(i - 1)..";Slot "..i.."]"..
				  "list[current_name;slot"..i..";6,"..(i - 1)..";1,1;]"
				inv:set_size("slot"..i, 1)
			end

			formspec = formspec.."list[current_player;main;0,5;8,4;]"

			meta:set_string("formspec", formspec)
			meta:set_string("infotext", "Constructor MK"..mk)
		end,

		can_dig = function(pos,player)
			local meta = minetest.env:get_meta(pos)
			local inv = meta:get_inventory()
			return inv:is_empty("slot1")
		end,
	})

	minetest.register_node(ctor_on_name, {
		description = "Constructor MK"..mk,
		tile_images = {
			"technic_constructor_mk"..mk.."_top_on.png",
			"technic_constructor_mk"..mk.."_bottom_on.png",
			"technic_constructor_mk"..mk.."_side2_on.png",
			"technic_constructor_mk"..mk.."_side1_on.png",
			"technic_constructor_back.png",
			"technic_constructor_front_on.png"
		},
		is_ground_content = true,
		paramtype2 = "facedir",
		groups = {snappy=2,choppy=2,oddly_breakable_by_hand=2,mesecon = 2,not_in_creative_inventory=1},
		mesecons= {effector={action_off=ctor_off}},
		sounds = default.node_sound_stone_defaults(),
		drop = ctor_off_name,
	})

end
