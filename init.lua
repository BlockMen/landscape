local remove_full_grass = false  --set "true" to remove all full_grass_blocks

minetest.register_node("landscape:full_grass_block", {
	description = "Dirt with Grass",
	tiles = {"default_grass.png"},
	is_ground_content = true,
	groups = {crumbly=3, not_in_creative=1},
	drop = 'default:dirt',
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_grass_footstep", gain=0.4},
	}),
})

function check_reg(set, key)
    return set[key] ~= nil
end

local function get_type(pos)  --1 for left, 2 for right, 3 for behind, 4 for front
	local l1 = minetest.env:get_node({x=pos.x+1, y=pos.y, z=pos.z}).name
	local l2 = minetest.env:get_node({x=pos.x, y=pos.y, z=pos.z+1}).name
	local r1 = minetest.env:get_node({x=pos.x-1, y=pos.y, z=pos.z}).name
	local r2 = minetest.env:get_node({x=pos.x, y=pos.y, z=pos.z-1}).name
	if l1 == nil or l2 == nil or r1 == nil or r2 == nil then return end
	if not check_reg(minetest.registered_nodes, l1) or not check_reg(minetest.registered_nodes, r1) or not check_reg(minetest.registered_nodes, l2) or not check_reg(minetest.registered_nodes, r2) then return end
	if l1 == "air" or not minetest.registered_nodes[l1].walkable then
		return 1
	elseif r1 == "air" or not minetest.registered_nodes[r1].walkable then
		return 2
	elseif l2 == "air" or not minetest.registered_nodes[l2].walkable then
		return 3
	elseif r2 == "air" or not minetest.registered_nodes[r2].walkable then
		return 4
	else
		return 0
	end
end

local function is_edge(pos)
	local l1 = minetest.env:get_node({x=pos.x-1, y=pos.y, z=pos.z}).name
	local l2 = minetest.env:get_node({x=pos.x, y=pos.y, z=pos.z-1}).name
	local r1 = minetest.env:get_node({x=pos.x+1, y=pos.y, z=pos.z}).name
	local r2 = minetest.env:get_node({x=pos.x, y=pos.y, z=pos.z+1}).name
	if l1 == nil or l2 == nil or r1 == nil or r2 == nil then return end
	if not check_reg(minetest.registered_nodes, l1) or not check_reg(minetest.registered_nodes, r1) or not check_reg(minetest.registered_nodes, l2) or not check_reg(minetest.registered_nodes, r2) then return end
	if l1 == "air" or not minetest.registered_nodes[l1] or
	l2 == "air" or not minetest.registered_nodes[l2].walkable or
	l3 == "air" or not minetest.registered_nodes[r1].walkable or
	l4 == "air" or not minetest.registered_nodes[r2].walkable then
		return true
	end

end

local function check(pos)
	if string.find(minetest.env:get_node(pos).name, "_grass") then
		return true
	else
		return false
	end
end


if remove_full_grass == false then
	minetest.register_abm({
		nodenames = {"default:dirt_with_grass"},
		--neighbors = {"default:dirt_with_grass", "landscape:full_grass_block"},
		interval = 1,
		chance = 1,
		action = function(pos, node, active_object_count, active_object_count_wider)
			local under = {x=pos.x, y=pos.y-1, z=pos.z}
			local above = {x=pos.x, y=pos.y+1, z=pos.z}
			local under_front = {x=pos.x+1, y=pos.y-1, z=pos.z}
			local under_front2 = {x=pos.x, y=pos.y-1, z=pos.z+1}
			local under_back = {x=pos.x-1, y=pos.y-1, z=pos.z}
			local under_back2 = {x=pos.x, y=pos.y-1, z=pos.z-1}
			local n = minetest.env:get_node(above).name
			if n == nil then return end
			if not check_reg(minetest.registered_nodes, n) then return end
			if n == "air" or not minetest.registered_nodes[n].walkable then
			if get_type(pos) ~= 0 then
				local typ = get_type(pos)
				local ok = false
				if typ == 1 then
					ok = check(under_front)
				elseif typ == 2 then
					ok = check(under_back)
				elseif typ == 3 then
					ok = check(under_front2)
				elseif typ == 4 then
					ok = check(under_back2)
				end
				if ok then
					if minetest.env:get_node(under).name == "default:dirt" then 
						if not is_edge(under) then
					--IF GRAS UNTEN-DAVOR tthen....
							minetest.env:set_node(pos, {name="landscape:full_grass_block"})	
						end
					else
						minetest.env:set_node(pos, {name="landscape:full_grass_block"})
					end
				end
			end
			end

		end
	})

	--remove full grass when block is placed above
	minetest.register_abm({
		nodenames = {"landscape:full_grass_block"},
		interval = 2.0,
		chance = 20,
		action = function(pos, node, active_object_count, active_object_count_wider)
		local n = minetest.env:get_node({x=pos.x, y=pos.y+1, z=pos.z}).name
		if n == nil then return end
		if not check_reg(minetest.registered_nodes, n) then return end
		if n ~= "air" or minetest.registered_nodes[n].walkable then
			minetest.env:set_node(pos, {name="default:dirt"})
		end
	end
	})
else
	minetest.register_abm({
		nodenames = {"landscape:full_grass_block"},
		interval = 1.0,
		chance = 1,
		action = function(pos, node, active_object_count, active_object_count_wider)
			local tmp_node3 = {name="default:dirt_with_grass"}
			minetest.env:set_node(pos, tmp_node3)
		end
	})
end
