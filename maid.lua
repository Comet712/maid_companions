--[[

MIT License

Copyright (c) 2025 Comet712

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

]]--




--[[
Maid State key:
0: Follow
1: Home (stay near home node position)
]]--

mobs:register_mob("maid_companions:maid", {

	type = "animal",
	visual = "mesh",
	mesh = "mobs_character.b3d",
	textures = {
		{"mobs_trader4.png"}
	},
	
	collisionbox = {-0.35,-1.0,-0.35, 0.35,0.8,0.35},
	visual_size = {x = 1, y = 1},
	
	--fly =true,
	
	mobs_spawn = false,
	pathfinding = 1,
	passive = true,
	pushable = false,
	runaway = false,
	hp_max = 999999,
	fall_damage = false,
	fear_height = 0,
	lava_damage = 0,
	fire_damage = 0,
	suffocation = 0,
	node_damage = false,
	floats = 1,
	follow = {"default:bread"},


--[[
	--Node replacement for farming
	replace_what = { {"group:grass", "default:dirt", 0} },
	replace_rate = 10,

	--replace_with = "farming:seed_wheat",
	reach = 5,

	on_replace = function (self, pos, oldnode, newnode)
		
minetest.chat_send_player(self.owner, "Farmed an item!")

		if self.owner then
			--Give player the wheat collected.
			local Wheat_Stack = ItemStack("farming:wheat 1")
			local Owner_Inventory = core.get_inventory({type="player", name=self.owner})
			Owner_Inventory:add_item("main", Wheat_Stack)
		end

		return true
	end,

--]]
	
	on_spawn = function(self)
		if(self.Maid_State == nil) then
			self.Maid_State = 0 --Follow
			self.Active_Skin_Name = "mobs_trader4.png"
		end
		
		if(self.My_Tick == nil) then
			self.My_Tick = 0
		end
		
		
	end,
	after_activate = function(self)
	
		Start_Method(self)
		
	end,
	
	on_rightclick = function(self)
			
		Open_Maid_Menu_For_Player(self)
		
	end,
	
	do_custom = function(self)
		--This is the Tick method. Every tick the counter increases. And every 60 ticks it does common actions.
		self.My_Tick = self.My_Tick + 1
		if(self.My_Tick >= 60) then
			self.My_Tick = 0
			--Do every 60 ticks
			Every_60_ticks_actions(self)
			
		end
		
	end

})


function Start_Method(maid)

	--Set skin
	maid.object:set_properties({textures = {maid.Active_Skin_Name .. ""}})
	--minetest.chat_send_player(maid.owner, "[Maid skin loaded as ".. maid.Active_Skin_Name .."]")
	
	--Say home position
	--minetest.chat_send_player(maid.owner, "[Maid ".. maid.Active_Skin_Name .." is set to "..maid.Maid_State.."]")
	
	Update_Maid_Size(maid)

end



function Update_Maid_Size(This_Maid)

	if This_Maid.Maid_Size == 1 then
    		--Update to small size
    		This_Maid.base_size = {x = .7, y = .7}
		This_Maid.base_colbox = {-0.25,-.7,-0.25, 0.25,0.55,0.25}
		
    	else
    		--Update to big size
    		This_Maid.base_size = {x = 1, y = 1}
    		This_Maid.base_colbox = {-0.35,-1.0,-0.35, 0.35,0.8,0.35}
    		
    	end

end





function Every_60_ticks_actions(maid)
	--Heal the maid constantly so they don't die.
	maid.health = maid.health + 999999
	
	
	if maid.Maid_State == 0 then
		--The maid is in follow state
		
		local Maid_Owner = core.get_player_by_name(maid.owner)
		if not Maid_Owner then
			--Switch to home mode
			maid.Maid_State = 1
			maid.Home_Position = maid.object:get_pos()
		else
			--Follow the player depending on distance
			
			local Maid_Position = maid.object:get_pos()
			local Player_Position = Maid_Owner:get_pos()
			Distance = vector.distance(Maid_Position, Player_Position)
			
			if(Distance > 15) then
				--Warp to player
				local Warp_Position = vector.new(Player_Position.x + 1, Player_Position.y + 1, Player_Position.z + 1)
				maid.object:set_pos(Warp_Position)
				maid.object:set_velocity({x=0.0, y=0.0, z=0.0})
			elseif(Distance > 6) then
				--Run towards player
				maid:go_to(Player_Position)
			else
				--Can stop moving and wander.
				
			end
			
		end
	else
		--The maid is in home state
		
		if maid.Home_Position == nil then
			maid.Home_Position = maid.object:get_pos()
		end
		
		local Maid_Position = maid.object:get_pos()
		Distance_From_Home = vector.distance(Maid_Position, maid.Home_Position)
		
		if Distance_From_Home > 8 then
			--Warp to home
			maid.object:set_pos(maid.Home_Position)
			maid.object:set_velocity({x=0.0, y=0.0, z=0.0})
		end
		
	end
end




mobs:register_egg("maid_companions:maid", "A maid companion.",
		"maid_egg.png", 1, false)
		
		
core.register_craft({
	output = "maid_companions:maid",
	recipe = {
		{"", "", ""},
		{"", "farming:bread", ""},
		{"farming:bread", "farming:bread", "farming:bread"}
	}
})





--Formspecs

function Get_Maid_Menu(This_Maid)

	local Home_State_String = "Off"
	local Maid_Size_String = "Big"
	
	if This_Maid.Maid_State == 1 then
		Home_State_String = "On"
	end
	
	if This_Maid.Maid_Size == 1 then
		Maid_Size_String = "Small"
	end

	local menu = {
		"formspec_version[4]",
		"size[9,9]",
		"field[.5,.6;5,.6;Texture_Name;Enter skin name, no file extension;]",
		"button[.5,1.4;3,.8;Show_Skins_Button;Say available skins]",
		"button[3.7,1.4;3,.8;Change_Maid_Texture_Button;Change maid skin]",
		"button[.5,2.4;2.4,.8;Toggle_Maid_Size_Button;Height: ".. Maid_Size_String .."]",
		
		"button[.5,4.5;3,1.5;Toggle_Home_Button;Home Mode: ".. Home_State_String .."]",
		
		"field[.5,7.3;5,.6;Depart_Code;To depart maid, type goodbye;]",
		"button[.5,8;3,.8;Depart_Maid_Button;Depart Maid]",
		
		
	}
	
	menu.Maid_Refference = "aaaaa"
	
	return table.concat(menu, "")

end


function Open_Maid_Menu_For_Player(This_Maid)

	local Maid_Owner = core.get_player_by_name(This_Maid.owner)
	if not Maid_Owner then
		return
	end

	local My_Context = Context_By_Playername(This_Maid.owner)
    	My_Context.target = This_Maid
	core.show_formspec(This_Maid.owner, "maid_companions:maid_menu", Get_Maid_Menu(This_Maid))
end




core.register_on_player_receive_fields(function(player, formname, fields)
    
    if formname ~= "maid_companions:maid_menu" then
        return
    end
    
    local Player_Name = player:get_player_name()
    local My_Context = Context_By_Playername(Player_Name)
    
    This_Maid = My_Context.target

	--[[
	if(This_Maid.owner == nil) then
		return
	end
	]]--
    
    if fields.Depart_Maid_Button and fields.Depart_Code and fields.Depart_Code == "goodbye" then
    	--Depart the maid
        mobs:remove(My_Context.target, true)
        core.chat_send_player(This_Maid.owner, "A maid left safely.")
        minetest.show_formspec(Player_Name, "", "")
        
    elseif fields.Toggle_Home_Button then
    
    	--We will toggle Home state of the maid.
	if This_Maid.Maid_State == 1 then
		This_Maid.Maid_State = 0
		minetest.chat_send_player(This_Maid.owner, "[Maid set to Follow Mode] ")
	else
		This_Maid.Maid_State = 1
		This_Maid.Home_Position = This_Maid.object:get_pos()		
		minetest.chat_send_player(This_Maid.owner, "[Maid set to Home Mode, near " .. math.floor(This_Maid.Home_Position.x) .. "," .. math.floor(This_Maid.Home_Position.y) .. "," .. math.floor(This_Maid.Home_Position.z) .. "]")
	end
	
	minetest.show_formspec(Player_Name, "", "")
	
    elseif fields.Change_Maid_Texture_Button then
    	
    	--Change the skin of the maid
    	local Name_Of_New_Texture = "mobs_trader4"
    	if fields.Texture_Name == "" then
    		minetest.chat_send_player(This_Maid.owner, "Error, you need to type the name of the texture. Click the other button to see available textures.")
    	else
		Name_Of_New_Texture = fields.Texture_Name
    	end
    	
    	This_Maid.object:set_properties({textures = {Name_Of_New_Texture .. ".png"}})
    	
	This_Maid.Active_Skin_Name = Name_Of_New_Texture .. ".png"
	
    	
    	--I'm too lazy to look up Not syntax XD
    	if fields.Texture_Name == "" then
    		
    	else
		minetest.chat_send_player(This_Maid.owner, "[Maid skin changed to ".. This_Maid.Active_Skin_Name .."]")
    	end
    	
    	minetest.show_formspec(Player_Name, "", "")
    
    
    
    
    elseif fields.Show_Skins_Button then
    	--Says all the available skins in chat
    	All_Skins = minetest.get_dir_list(minetest.get_modpath('maid_companions') .. "/textures")
    	All_Skins_String = table.concat(All_Skins, "")
    	All_Skins_String = string.gsub(All_Skins_String, ".png", ", ")
    	minetest.chat_send_player(This_Maid.owner, All_Skins_String)
    	
    	minetest.show_formspec(Player_Name, "", "")
    	
    	
    	
    elseif fields.Toggle_Maid_Size_Button then
    
    	if This_Maid.Maid_Size == 1 then
    		--Currently small size, we will change to big.
    		This_Maid.Maid_Size = 0
    		Update_Maid_Size(This_Maid)
    		minetest.chat_send_player(This_Maid.owner, "Maid updated to Big size. Reload world for change to go into effect.")
    	else
    		--Currently big size, we will change to small.
    		This_Maid.Maid_Size = 1
    		Update_Maid_Size(This_Maid)
    		minetest.chat_send_player(This_Maid.owner, "Maid updated to Small size. Reload world for change to go into effect.")
    	end
    	
    	minetest.show_formspec(Player_Name, "", "")
    
    end
    
end)




local Maid_Contexts = {}

function Context_By_Playername(Player_Name)

    local Found_Context = Maid_Contexts[Player_Name] or {}
    Maid_Contexts[Player_Name] = Found_Context
	
    return Found_Context
	
end



core.register_on_leaveplayer(function(player)

    Maid_Contexts[player:get_player_name()] = nil
	
end)
