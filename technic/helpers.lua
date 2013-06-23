
function technic_deploy_node(pos, node, inv, slot_name)
	local stack = inv:get_stack(slot_name, 1)
	local def = stack:get_definition()
	if def.type == "node" then
		node_to_be_placed = {
			name = stack:get_name(),
			param1 = 0,
			param2 = 0, --self.param2,
		}
		minetest.env:set_node(pos, node_to_be_placed)
		stack:take_item()
		inv:set_stack(slot_name, 1, stack)
	elseif def.type == "craft" then
		if def.on_place then
			-- print("deploy_node: item has on_place. trying...")
			local ok, stk = pcall(def.on_place, stack1[1], nil, {
				-- Fake pointed_thing
				type = "node",
				above = pos1,
				under = { x=pos1.x, y=pos1.y-1, z=pos1.z },
			})
			if ok then
				inv:set_stack(slot_name, 1, stk)
				return
			end
		end
		minetest.item_place_object(stack, nil, {
			-- Fake pointed_thing
			type = "node",
			above = pos1,
			under = pos1,
		})
		inv:set_stack(slot_name, 1, nil)
	end
end


function technic_break_node(pos, node, inv, slot_name)
	local def = minetest.registered_nodes[node.name]
	local drop = def.drop or node.name
	local stack = inv:get_stack(slot_name, 1)
	if type(drop) == "table" then
		local pr = PseudoRandom(math.random())
		local c = 0
		local loop = 0 -- Prevent infinite loop
		while (loop < 1000) do
			local i = math.floor(pr:next(1, #drop.items))
			if pr:next(1, drop.items[i].rarity or 1) == 1 then
				inv:set_stack(slot_name, 1, ItemStack(drop.items[i].items[1]))
				break
			end
			loop = loop + 1
		end
		minetest.env:remove_node(pos)
	elseif type(drop) == "string" then
		inv:set_stack(slot_name, 1, ItemStack(drop))
		minetest.env:remove_node(pos)
	end
end


function technic_facedir_to_dir(facedir)
	local dir = { x=0, y=0, z=0 }
	if     facedir == 0 then dir.z = -1
	elseif facedir == 1 then dir.x = -1
	elseif facedir == 2 then dir.z =  1
	elseif facedir == 3 then dir.x =  1
	else
		return nil
	end
	print("facedir: "..facedir)
	print("dir: "..dump(dir))
	return dir
end


function technic_get_item_meta(string)
	if string.find(string, "return {") then
		return minetest.deserialize(string)
	else
		return nil
	end
end


function technic_set_item_meta(table)
	return minetest.serialize(table)
end


function technic_swap_node(pos, newnode)
	hacky_swap_node(pos, newnode)
end


function technic_construct_nodes(pos, count)
	local self = minetest.get_node(pos)
	local inv = minetest.get_meta(pos):get_inventory()
	local dir = technic_facedir_to_dir(self.param2)
	if not dir then return end
	local pos = { x = pos.x, y = pos.y, z = pos.z }
	for i = 1, count do
		local slot_name = "slot"..i
		local stack = inv:get_stack(slot_name, 1)
		pos.x = pos.x + dir.x
		pos.z = pos.z + dir.z
		local node = minetest.get_node(pos)
		local def = stack:get_definition()
		if not def then return end
		if (stack:get_name()) and (node.name == "air") then
			technic_deploy_node(pos, node, inv, slot_name)
		elseif (node.name ~= "air") and (node.name ~= "ignore") then
			technic_break_node(pos, node, inv, slot_name)
		end
	end
end
