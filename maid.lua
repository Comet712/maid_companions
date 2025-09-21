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
2: Pseudo-home mode (Act like in home mode. If owner returns, revert to follow mode.)
]]--

--core.chat_send_all("Arrived at line"..math.random(1000000))





mobs:register_mob("maid_companions:maid", {



	type = "animal",
	
	passive = false,



	--Dogfight has jittering issues when following the player. Dogshoot in melee mode is a smoother follow experience
	attack_type = "dogshoot",

	dogshoot_count_max = 0, 
	dogshoot_count2_max = 20, 
	dogshoot_switch = 1,

	pathfinding = 1,
	reach = 2,
	damage = 0,
	run_velocity = 5,
	jump = true,
	--jump_height = 4,
	view_range = 25,
	walk_velocity = 1,
	
	
	visual = "mesh",
	mesh = "mobs_character.b3d",
	textures = {
		{"mobs_trader4.png"}
	},
	
	collisionbox = {-0.35,-1.0,-0.35, 0.35,0.8,0.35},
	--collisionbox = {-0.7, -1, -0.7, 0.7, 1.6, 0.7},
	visual_size = {x = 1, y = 1},
	
	--fly =true,

	physical = false,
	pushable = false,


	mobs_spawn = false,
	--pathfinding = 1,
	--passive = true,
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


animation = {
		
		stand_start = 188,
		stand_end = 188,
		
		walk_speed = 20,
		walk_start = 168,
		walk_end = 187,
		
		--[[
		run_speed = 25,
		run_start = 168,
		run_end = 187,
		--]]
	},
	--(inclusive)
	--Punching: 189 - 200
	--Standing: 188
	--Walking: 168 - 187
	-- Dead: ??? - 167
	--Sitting: Lower number




	
	on_spawn = function(self)
		if(self.Maid_State == nil) then
			self.Maid_State = 0 --Follow
			self.Active_Skin_Name = "mobs_trader4.png"
		end
		
		if(self.My_Tick == nil) then
			self.My_Tick = 0
		end
		
		
	end,
	 
	
	
on_activate = function(self, staticdata)
	
    end,
	

after_activate = function(self, staticdata, def, dtime)

	if(self.ID == nil) then
	self.ID = ""..math.random(100000000)
	end
	
	
        if staticdata then
		    data = core.deserialize(staticdata)
			
			if(data) then
						
				self.Inventory_Name = data.Inventory_Name or nil

				Create_Maid_Inventory(self)
				
				--Fill in the recreated inventory with the remembered items
				
				if(self.Saved_Inventory_Data) then
									
				    if type(self.Saved_Inventory_Data) == "table" then
					
						for list_name, list in pairs(self.Saved_Inventory_Data) do
							self.Inventory:set_list(list_name, list)
						end
					
					end
				
				end
				
			end
			
        end

	
		Start_Method(self)
		
	end,
	
	
	
	
	
	
	on_rightclick = function(self)
	
		Open_Maid_Menu_For_Player(self)
		
	end,
	
	
	
	
	do_custom = function(self)
		--This is the Tick method. Every tick the counter increases. And every 60 ticks it does common actions.
		self.My_Tick = self.My_Tick + 1
		if(self.My_Tick % 60 == 0) then
			--Do every 60 ticks
			Every_60_ticks_actions(self)
			
		end
		
		if(self.My_Tick >= 242) then
			self.My_Tick = 0
			--Do every 4 seconds
			Every_4_seconds_actions(self)
			
		end
		
	end

})



function Save_Maid_Inventory(This_Maid)

This_Maid.Saved_Inventory_Data = "ccccccc"

Temp_Inventory = Get_Maid_Inventory(This_Maid)


if(Temp_Inventory ) then

This_Maid.Saved_Inventory_Data = {}

	for list_name, list in pairs(Temp_Inventory:get_lists()) do
				
			Item_List = {}
			for k, item in ipairs(list) do
				Item_List[k] = item:to_string()

			end
					
			This_Maid.Saved_Inventory_Data[list_name] = Item_List


	end

end





end






function Start_Method(maid)

	maid.object:set_properties({collide_with_objects = false})


	--Set skin
	maid.object:set_properties({textures = {maid.Active_Skin_Name .. ""}})

	
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
			
			if maid.Maid_State == 0 then
				--This is Pseudo-home mode. Functionally the same as home mode, but will be switched back to follow when player is online.
				maid.Maid_State = 2 
			else
				--Maid State is already 1 or 2
			end
			
			
			
			maid.Home_Position = maid.object:get_pos()
			
			maid.CurrentlyRunningTowardsPlayer = false
			--maid.state = "stand"
			maid.attack = nil
		else
			--Follow the player depending on distance
			
			local Maid_Position = maid.object:get_pos()
			local Player_Position = Maid_Owner:get_pos()
			Distance = vector.distance(Maid_Position, Player_Position)
			
			
			if(Distance > 20) then
			
			maid.CurrentlyRunningTowardsPlayer = false
				--Warp to player, too far.
				local Warp_Position = vector.new(Player_Position.x + 1, Player_Position.y + 1, Player_Position.z + 1)
				maid.object:set_pos(Warp_Position)
				maid.object:set_velocity({x=0.0, y=0.0, z=0.0})
				--Save new position
				Remember_Maid_Position(This_Maid)
				
			
				else
				
					--Maids follow you
					--maid.animation.walk_speed = 35
				
				
				
					if(Distance > 9) then
					
						if(maid.CurrentlyRunningTowardsPlayer == nil or maid.CurrentlyRunningTowardsPlayer == false or maid.state ~= "attack") then
							--minetest.chat_send_player(maid.owner, maid.Active_Skin_Name.." trying to follow player! "..math.random(0, 300))

							--Run towards player
												
							maid.run_velocity = 6
							maid:do_attack(Maid_Owner, 0)
							
							--view range needs to be high for go_to to work
							
							
							maid.CurrentlyRunningTowardsPlayer = true
						end
							
							
					else
							
							
							
							if Distance <= 5 then
								maid.run_velocity = 4
								--maid.animation.walk_speed = 25
							end
							
							
							if Distance <= 3 then
							--Stop running if we were.
							
								if maid.CurrentlyRunningTowardsPlayer then
									Try_To_Repair_Player_Armor(maid)
								end
								--Once maid had reunited close to the player, they can wander a bit further away.
								maid.CurrentlyRunningTowardsPlayer = false
								--maid.animation.walk_speed = 15
								--maid.state = "stand"
								maid.attack = nil
								
								--Heal armor. The maid attacking the player for 0 damage still creates armor wear, so we need to compensate.

						end
							
						
						
					end
				
				
				
			
				
			
			
			
			end
				
				
				

			
			
			
			
			
		end
	else
		--The maid is in home state
		
		--maid.animation.walk_speed = 20
		
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




function Every_4_seconds_actions(This_Maid) 


Remember_Maid_Position(This_Maid)


--Check if an absent owner returned, and if we need to return to follow mode.

if This_Maid.Maid_State == 2 then

	local Maid_Owner = core.get_player_by_name(This_Maid.owner)
	if Maid_Owner then
		--The owner returned, and the maid is supposed to be in follow mode, to update to follow mode.	
		This_Maid.Maid_State = 0
	end

end

	

			
			 




--Farming code
Maid_Position = This_Maid.object:get_pos()
nearby_wheat = minetest.find_node_near(Maid_Position, 1, "farming:wheat_8")

if(nearby_wheat ~= nil) then
--Harvest wheat

pos_to_replace = nearby_wheat
core.set_node(pos_to_replace, {name = "farming:seed_wheat", param2 = 1})
core.get_node_timer(pos_to_replace):start(math.random(150, 300))

Maid_Inventory = core.get_inventory({ type="detached", name=""..Get_Maid_Inventory_Name(This_Maid) })

Wheat_Stack = ItemStack("farming:wheat 1")
Maid_Inventory:add_item("main", Wheat_Stack)

 Save_Maid_Inventory(This_Maid)

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


	Maid_Inventory_Name = Get_Maid_Inventory_Name(This_Maid)
	 Get_Maid_Inventory(This_Maid)


	local menu = {
		"formspec_version[4]",
		"size[18,12]",
		"field[.5,.6;5,.6;Texture_Name;Enter skin name, no file extension;]",
		"button[.5,1.4;3,.8;Show_Skins_Button;Say available skins]",
		"button[3.7,1.4;3,.8;Change_Maid_Texture_Button;Change maid skin]",
		"button[.5,2.4;2.4,.8;Toggle_Maid_Size_Button;Height: ".. Maid_Size_String .."]",
		
		"button[.5,4.5;3,1.5;Toggle_Home_Button;Home Mode: ".. Home_State_String .."]",
		
		"field[.5,9.5.3;5,.6;Depart_Code;To depart maid, type goodbye;]",
		"button[.5,10.5;3,.8;Depart_Maid_Button;Depart Maid]",
		"list[detached:"..Maid_Inventory_Name..";main;7.5,1.7;8,1]",
		"list[detached:"..Maid_Inventory_Name..";main;7.5,3;8,3;8]",
		"list[current_player;main;7.5,6.6;8,1;]",
		"list[current_player;main;7.5,7.9;8,3;8]",
		
		
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





--Inventory related code

function Get_Maid_Inventory(This_Maid)

if(This_Maid.Inventory == nil) then
 Create_Maid_Inventory(This_Maid)
end



return This_Maid.Inventory

end


function Get_Maid_Inventory_Name(This_Maid)

if(This_Maid.Inventory == nil) then
 Create_Maid_Inventory(This_Maid)
end

return This_Maid.Inventory_Name

end




function Get_Maid_Inventory(This_Maid)

if(This_Maid.Inventory == nil) then
 Create_Maid_Inventory(This_Maid)
end

return This_Maid.Inventory

end




function Create_Maid_Inventory(This_Maid)

New_Name = ""

if(This_Maid.Inventory_Name) then
New_Name = This_Maid.Inventory_Name
else
New_Name = ""..This_Maid.owner..""..math.random(1000000)
end


Maid_Inventory = core.create_detached_inventory(New_Name, {
on_put = function(inv, listname, index, stack, player)
	   Save_Maid_Inventory(This_Maid)
    end,
on_take = function(inv, listname, index, stack, player)
	   Save_Maid_Inventory(This_Maid)
    end,
on_move = function(inv, listname, index, stack, player)
	   Save_Maid_Inventory(This_Maid)
    end,
})
Maid_Inventory:set_size("main", 24)
Maid_Inventory:set_width("main", 8)



This_Maid.Inventory = Maid_Inventory
This_Maid.Inventory_Name = New_Name




end










--Log maid positions to a file, in case they get lost and you need to track them down

Maid_Positions_Log = {}


function Remember_Maid_Position(This_Maid)

if(This_Maid == nil) then
return
end

MaidPosition = This_Maid.object:get_pos()

if(MaidPosition == nil) then
return
end

Entry_String ="Player: "..This_Maid.owner..", Maid skin: "..This_Maid.Active_Skin_Name.." Maid position: "..math.floor(MaidPosition.x)..", "..math.floor(MaidPosition.y)..", "..math.floor(MaidPosition.z)


Is_Maid_Already_Included = false

for k, v in pairs(Maid_Positions_Log) do
    if k == This_Maid.ID then
	Is_Maid_Already_Included = true
	break
	end
end

if Is_Maid_Already_Included == false then
table.insert(Maid_Positions_Log, This_Maid.ID, Entry_String)
end

end





function Save_Maid_Log()

--Write it to a file
Filepath = core.get_worldpath().."/MaidLocations.txt"
InputOutput = io.open(Filepath, "w")
InputOutput:write(core.serialize(Maid_Positions_Log))
InputOutput:close()

end




function Save_Maid_Logs_Repeating()

Log_Timer = 0
	
core.register_globalstep(function(dtime)
	
	Log_Timer = Log_Timer + dtime
	
	if Log_Timer > 14 then
	
	    Log_Timer = 0
		Save_Maid_Log()
		
end
end)
	
end




Save_Maid_Logs_Repeating()




--Try to load log from file, so we can add entries to it.
Read_Filepath = core.get_worldpath().."/MaidLocations.txt"
Read_InputOutput = io.open(Read_Filepath, "r")

if Read_InputOutput then

Maid_Positions_Log = core.deserialize(Read_InputOutput:read("*all"))

Read_InputOutput:close()

--minetest.chat_send_all("File read.")

end






function Try_To_Repair_Player_Armor(This_Maid)

if not minetest.get_modpath("3d_armor") then
return
end


	Player_Armor_Inventory = minetest.get_inventory({type="detached", name=This_Maid.owner.."_armor"})

	if Player_Armor_Inventory then
	

		--Loop through all armor pieces, repair their durability by one.

		for list_name, list in pairs(Player_Armor_Inventory:get_lists()) do
		
			num_armor_pieces = 0;
			for key,value in pairs(list) do
			num_armor_pieces = num_armor_pieces + 1
			end

				
			for k, item in ipairs(list) do
			

				if item then
								--core.chat_send_all(""..item:to_string()..", "..math.random(1000000))
								
								local armor_use = core.get_item_group(item:get_name(), "armor_use")
								armor_use = math.ceil(armor_use/num_armor_pieces) * 7
								
								if armor_use then
								
									item:add_wear(-1 * (armor_use))
									Player_Armor_Inventory:set_stack("armor", k, item)
								
								end
								
								
												
				end

			end
					

		end


	else
		--core.chat_send_all("Missed armor "..math.random(1000000))
	end

end

