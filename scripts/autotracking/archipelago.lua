ScriptHost:LoadScript("scripts/autotracking/item_mapping.lua")
ScriptHost:LoadScript("scripts/autotracking/location_mapping.lua")
ScriptHost:LoadScript("scripts/autotracking/flag_mapping.lua")
ScriptHost:LoadScript("scripts/autotracking/autotab_mapping.lua")

lastLevel = "SpringMeadows"
-- used for hint tracking to quickly map hint status to a value from the Highlight enum
HINT_STATUS_MAPPING = {}
if Highlight then
	HINT_STATUS_MAPPING = {
		[20] = Highlight.Avoid,
		[40] = Highlight.None,
		[10] = Highlight.NoPriority,
		[0] = Highlight.Unspecified,
		[30] = Highlight.Priority,
	}
end

CUR_INDEX = -1
LOCAL_ITEMS = {}
GLOBAL_ITEMS = {}

-- gets the data storage key for hints for the current player
-- returns nil when not connected to AP
function getHintDataStorageKey()
	if AutoTracker:GetConnectionState("AP") ~= 3 or Archipelago.TeamNumber == nil or Archipelago.TeamNumber == -1 or Archipelago.PlayerNumber == nil or Archipelago.PlayerNumber == -1 then
		if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
			print("Tried to call getHintDataStorageKey while not connect to AP server")
		end
		return nil
	end
	return string.format("_read_hints_%s_%s", Archipelago.TeamNumber, Archipelago.PlayerNumber)
end

-- resets an item to its initial state
function resetItem(item_code, item_type)
	local obj = Tracker:FindObjectForCode(item_code)
	if obj then
		item_type = item_type or obj.Type
		if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
			print(string.format("resetItem: resetting item %s of type %s", item_code, item_type))
		end
		if item_type == "toggle" or item_type == "toggle_badged" then
			obj.Active = false
		elseif item_type == "progressive" or item_type == "progressive_toggle" then
			obj.CurrentStage = 0
			obj.Active = false
		elseif item_type == "consumable" then
			obj.AcquiredCount = 0
		elseif item_type == "custom" then
			-- your code for your custom lua items goes here
		elseif item_type == "static" and AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
			print(string.format("resetItem: tried to reset static item %s", item_code))
		elseif item_type == "composite_toggle" and AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
			print(string.format(
				"resetItem: tried to reset composite_toggle item %s but composite_toggle cannot be accessed via lua." ..
				"Please use the respective left/right toggle item codes instead.", item_code))
		elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
			print(string.format("resetItem: unknown item type %s for code %s", item_type, item_code))
		end
	elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
		print(string.format("resetItem: could not find item object for code %s", item_code))
	end
end

-- advances the state of an item
function incrementItem(item_code, item_type, multiplier)
	local obj = Tracker:FindObjectForCode(item_code)
	if obj then
		item_type = item_type or obj.Type
		if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
			print(string.format("incrementItem: code: %s, type %s", item_code, item_type))
		end
		if item_type == "toggle" or item_type == "toggle_badged" then
			obj.Active = true
		elseif item_type == "progressive" or item_type == "progressive_toggle" then
			if obj.Active then
				obj.CurrentStage = obj.CurrentStage + 1
			else
				obj.Active = true
			end
		elseif item_type == "consumable" then
			obj.AcquiredCount = obj.AcquiredCount + obj.Increment * multiplier
		elseif item_type == "custom" then
			-- your code for your custom lua items goes here
		elseif item_type == "static" and AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
			print(string.format("incrementItem: tried to increment static item %s", item_code))
		elseif item_type == "composite_toggle" and AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
			print(string.format(
				"incrementItem: tried to increment composite_toggle item %s but composite_toggle cannot be access via lua." ..
				"Please use the respective left/right toggle item codes instead.", item_code))
		elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
			print(string.format("incrementItem: unknown item type %s for code %s", item_type, item_code))
		end
	elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
		print(string.format("incrementItem: could not find object for code %s", item_code))
	end
end

-- apply everything needed from slot_data, called from onClear
function apply_slot_data(slot_data)
	-- put any code here that slot_data should affect (toggling setting items for example)

	local options = slot_data["options"]

	-- Default autotab to on
	local autotabItem = Tracker:FindObjectForCode("autotab")
	autotabItem.Active = 1

	--[[ 
	goals are: 
	0 = Paintress (The Monolith)
	1 = Curator (Lumiere)
	2 = Painted Love (Endless Tower)
	3 = Simon (Renoir's Draft)
	4 = Clea (Flying Manor) 
	]]
	if options['goal'] then
		goal = options['goal']
		print("goal: "..goal)

		local itemOption = Tracker:FindObjectForCode("goal")
		if goal == 0 then 
			itemOption.CurrentStage = 1
		elseif goal == 1 then --Curator
			itemOption.CurrentStage = 2
		elseif goal == 2 then --Painted Love
			itemOption.CurrentStage = 4
		elseif goal == 3 then --Simon
			itemOption.CurrentStage = 5
		elseif goal == 4 then --Clea
			itemOption.CurrentStage = 3
		end
		
	end

	-- Shuffle Free Aim
	if options['shuffle_free_aim'] then
		local setOption = options['shuffle_free_aim']
		local item = Tracker:FindObjectForCode("FreeAim")
		local itemOption = Tracker:FindObjectForCode("shuffle_free_aim")
		--print("shuffle_free_aim: "..setOption)

		itemOption.Active = setOption
		if setOption == 1 then
			item.Active = 0
		elseif setOption == 0 then
			item.Active = 1
		end
	end

	-- Gestral Shuffle
	if options['gestral_shuffle'] then
		local setOption = options['gestral_shuffle']
		local itemOption = Tracker:FindObjectForCode("gestral_shuffle")
		print("gestral_shuffle: "..setOption)

		itemOption.Active = setOption
	end

	-- include Endgame Locations
	-- Changed this to include to make visibility rules simpler
	if options['exclude_endgame_locations'] and (goal <= 1 or goal == 4) then
		local setOption = options['exclude_endgame_locations']
		local itemOption = Tracker:FindObjectForCode("include_endgame_locations")
		print("exclude_endgame_locations: "..setOption)

		itemOption.Active = setOption
	else
		print("Marking include_endgame_locations because it is 1, 2 or the goal is Simon or Painted Love")
		local itemOption = Tracker:FindObjectForCode("include_endgame_locations")
		itemOption.Active = 1
	end

	-- include Endless Tower
	-- Changed this to include to make visibility rules simpler
	if options['exclude_endless_tower'] and options['exclude_endgame_locations'] then
		local setOption = options['exclude_endless_tower']
		local endgameSetOption = options['exclude_endgame_locations']
		local itemOption = Tracker:FindObjectForCode("include_endless_tower")
		
		print("exclude_endless_tower: "..setOption)

		if goal >= 2 and goal ~= 4 then
			itemOption.Active = 1
		elseif endgameSetOption == 0 then
			itemOption.Active = 0
		else
			itemOption.Active = setOption
		end
		
	end
end

-- called right after an AP slot is connected
function onClear(slot_data)
	-- use bulk update to pause logic updates until we are done resetting all items/locations
	Tracker.BulkUpdate = true
	if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
		print(string.format("called onClear, slot_data:\n%s", dump_table(slot_data)))
	end
	CUR_INDEX = -1
	-- reset locations
	for _, mapping_entry in pairs(LOCATION_MAPPING) do
		for _, location_table in ipairs(mapping_entry) do
			if location_table then
				local location_code = location_table
				if location_code then
					if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
						print(string.format("onClear: clearing location %s", location_code))
					end
					if location_code:sub(1, 1) == "@" then
						local obj = Tracker:FindObjectForCode(location_code)
						if obj then
							obj.AvailableChestCount = obj.ChestCount
							if obj.Highlight then
								obj.Highlight = Highlight.None
							end
						elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
							print(string.format("onClear: could not find location object for code %s", location_code))
						end
					else
						-- reset hosted item
						local item_type = location_table[2]
						resetItem(location_code, item_type)
					end
				elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
					print(string.format("onClear: skipping location_table with no location_code"))
				end
			elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
				print(string.format("onClear: skipping empty location_table"))
			end
		end
	end
	-- reset items
	for _, mapping_entry in pairs(ITEM_MAPPING) do
		print("map 1: "..mapping_entry[1].."\nmap 2: "..mapping_entry[2])
		if mapping_entry[1] and mapping_entry[2] then
			local item_code = mapping_entry[1]
			local item_type = mapping_entry[2]
			
			if item_code then
				resetItem(item_code, item_type)
			elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
				print(string.format("onClear: skipping item_table with no item_code"))
			end
		elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
			print(string.format("onClear: skipping empty item_table"))
		end
	end
	apply_slot_data(slot_data)

	-- used for tracking which flags have been accessed. Not locations, but helpful for the player
	ap_flags = Archipelago.PlayerNumber.."-coe33-flags"
	print("Setting Notify for: "..ap_flags)
	Archipelago:SetNotify({ap_flags})
	Archipelago:Get({ap_flags})

	-- used for autotabbing
	ap_autotab = Archipelago.PlayerNumber.."-coe33-currentLocation"
	print("Setting Notify for: "..ap_autotab)
	Archipelago:SetNotify({ap_autotab})
	Archipelago:Get({ap_autotab})

	LOCAL_ITEMS = {}
	GLOBAL_ITEMS = {}
	-- manually run snes interface functions after onClear in case we need to update them (i.e. because they need slot_data)
	if PopVersion < "0.20.1" or AutoTracker:GetConnectionState("SNES") == 3 then
		-- add snes interface functions here
	end
	-- setup data storage tracking for hint tracking
	local data_strorage_keys = {}
	if PopVersion >= "0.32.0" then
		data_strorage_keys = { getHintDataStorageKey() }
	end
	-- subscribes to the data storage keys for updates
	-- triggers callback in the SetNotify handler on update
	Archipelago:SetNotify(data_strorage_keys)
	-- gets the current value for the data storage keys
	-- triggers callback in the Retrieved handler when result is received
	Archipelago:Get(data_strorage_keys)
	Tracker.BulkUpdate = false
end

-- called when an item gets collected
function onItem(index, item_id, item_name, player_number)
	if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
		print(string.format("called onItem: %s, %s, %s, %s, %s", index, item_id, item_name, player_number, CUR_INDEX))
	end
	if not AUTOTRACKER_ENABLE_ITEM_TRACKING then
		return
	end
	if index <= CUR_INDEX then
		return
	end
	local is_local = player_number == Archipelago.PlayerNumber
	CUR_INDEX = index
	local mapping_entry = ITEM_MAPPING[item_id]
	if not mapping_entry then
		if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
			print(string.format("onItem: could not find item mapping for id %s", item_id))
		end
		return
	end
    if mapping_entry then
        local item_code = mapping_entry[1]
        local item_type = mapping_entry[2]
        local multiplier = mapping_entry[3] or 1
        if item_code then
            incrementItem(item_code, item_type, multiplier)
            -- keep track which items we touch are local and which are global
            if is_local then
                if LOCAL_ITEMS[item_code] then
                    LOCAL_ITEMS[item_code] = LOCAL_ITEMS[item_code] + 1
                else
                    LOCAL_ITEMS[item_code] = 1
                end
            else
                if GLOBAL_ITEMS[item_code] then
                    GLOBAL_ITEMS[item_code] = GLOBAL_ITEMS[item_code] + 1
                else
                    GLOBAL_ITEMS[item_code] = 1
                end
            end
        elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("onClear: skipping item_table with no item_code"))
            print(string.format("item_table: %s", dump_table(mapping_entry)))
        end
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onClear: skipping empty item_table"))
    end
	if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
		print(string.format("local items: %s", dump_table(LOCAL_ITEMS)))
		print(string.format("global items: %s", dump_table(GLOBAL_ITEMS)))
	end
	-- track local items via snes interface
	if PopVersion < "0.20.1" or AutoTracker:GetConnectionState("SNES") == 3 then
		-- add snes interface functions for local item tracking here
	end
end

-- called when a location gets cleared
function onLocation(location_id, location_name)
	if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
		print(string.format("called onLocation: %s, %s", location_id, location_name))
	end
	if not AUTOTRACKER_ENABLE_LOCATION_TRACKING then
		return
	end
	local mapping_entry = LOCATION_MAPPING[location_id]
	if not mapping_entry then
		if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
			print(string.format("onLocation: could not find location mapping for id %s", location_id))
		end
		return
	end
    if mapping_entry then
        local location_code = mapping_entry[1]
        if location_code then
            local obj = Tracker:FindObjectForCode(location_code)
            if obj then
                if location_code:sub(1, 1) == "@" then
                    obj.AvailableChestCount = obj.AvailableChestCount - 1
                else
                    -- increment hosted item
                    local item_type = mapping_entry[2]
                    incrementItem(location_code, item_type)
                end
            elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onLocation: could not find object for code %s", location_code))
            end
        elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("onLocation: skipping location_table with no location_code"))
        end
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onLocation: skipping empty location_table"))
    end
end

-- called when a locations is scouted
function onScout(location_id, location_name, item_id, item_name, item_player)
	if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
		print(string.format("called onScout: %s, %s, %s, %s, %s", location_id, location_name, item_id, item_name,
			item_player))
	end
	-- not implemented yet :(
end

-- called when a bounce message is received
function onBounce(json)
	if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
		print(string.format("called onBounce: %s", dump_table(json)))
	end
	-- your code goes here
end

-- called whenever Archipelago:Get returns data from the data storage or
-- whenever a subscribed to (via Archipelago:SetNotify) key in data storgae is updated
-- oldValue might be nil (always nil for "_read" prefixed keys and via retrieved handler (from Archipelago:Get))
function onDataStorageUpdate(key, value, oldValue)
	print(key)

	--if you plan to only use the hints key, you can remove this if
	if key == getHintDataStorageKey() then
		onHintsUpdate(value)
	end

	--Looks for [SlotNumber]-coe33-flags - ex. 1-coe33-flags. Ensures data is kept separate if multiple of the same game are run and that it is a unique key
	if key == ap_flags then
		if value ~= nil then
			for areaName, table in pairs(value) do
				for index, flagName in pairs(table) do
					mapFlagLocation(areaName, flagName)
				end
			end
		end
		
		--uncomment if you need to print out the flag map again
		--printFlagMap(value)
	end

	-- Autotabbing
	-- If the player is going to a level in the top half AUTOTAB_MAPPING, it tabs to that level
	-- If the player is going to the Continent, it pulls the last level the player was in and uses the bottom half of AUTOTAB_MAPPING to determine which part of the Continent to tab to
	-- it's probably inefficient, but it gets the job done. sue me (please don't)
	-- looks for [SlotNumber]-coe33-currentLocation
	if key == ap_autotab then
		if value ~= nil then
			print("Printing ap_autotab:")
			print(value)

			if AUTOTAB_MAPPING[tostring(value)] and has("autotab") then 
				print(value.." has been found in AUTOTAB_MAPPING")

				if value == "WorldMap" then
					exitString = "EXIT_"..tostring(lastLevel)
					print("Mapping to "..exitString)
					if AUTOTAB_MAPPING[exitString] then
						exitTabs = AUTOTAB_MAPPING[exitString]
						for exitInternalLevel, exitTabName in ipairs(exitTabs) do
							print("Exit tab: "..exitTabName)
							Tracker:UiHint("ActivateTab", exitTabName)
						end
					else
						print("value does not exist. Add to autotab mapping!")
						print("[\""..exitString.."\"] = { \"Continent\", \" Continent\" },")
					end
				else
					tabs = AUTOTAB_MAPPING[tostring(value)]
					for internalLevel, tabName in ipairs(tabs) do
						print("Activating tab "..tabName)
						Tracker:UiHint("ActivateTab", tabName)
					end
				end
			end

			if value == "Camps" or value == "WorldMap" then
				print("Current level is "..value..", so lastLevel is not being updated")
			else
				lastLevel = value
				print("Last Level is "..lastLevel)
			end
			
		end
	end
end

-- finds the flag location from flag_mapping.lua
-- drops AvailableChestCount by 1 to gray out the location
function mapFlagLocation(areaName, flagName)
	local modifiedName = areaName.."=>"..flagName
	--[[ print("\n======== mapFlagLocation() ========")
	print("modifiedName is "..modifiedName) ]]

	if FLAG_MAPPING[modifiedName] == nil then
		print("[NOTICE] Add Flag to mapping:")
		print("[\""..modifiedName.."\"] = { \"@\" },")
	else
		if FLAG_MAPPING[modifiedName][1] == "@" or FLAG_MAPPING[modifiedName][1] == "Not Implemented" then
			print("[WARNING] Flag not mapped. FLAG_MAPPING is nil, FLAG_MAPPING[modifiedName][1] is \"@\" or \"Not Implemeneted\". Expected modifiedName is "..modifiedName)
		else
			print(FLAG_MAPPING[modifiedName][1])
			local obj = Tracker:FindObjectForCode(FLAG_MAPPING[modifiedName][1])
			if obj.AvailableChestCount ~= 0 then
				print("Unchecking location "..modifiedName)
				obj.AvailableChestCount = obj.AvailableChestCount - 1
			end
		end
	end
	
	--print("====== End mapFlagLocation() ======\n")
end

-- Prints out the flag map in a format that allows you to copy-paste into flag_mapping.lua
-- Imports existing data as well if possible
function printFlagMap(value)
	for areaName, table in pairs(value) do
		for index, flagName in pairs(table) do
			local modifiedName = areaName.."=>"..flagName
			local mappedLocation = ""

			if  FLAG_MAPPING[modifiedName] then
				if FLAG_MAPPING[modifiedName][1] ~= "@" and FLAG_MAPPING[modifiedName][1] ~= "Not Implemented" then
					mappedLocation = mappedLocation..FLAG_MAPPING[modifiedName][1]
				else
					mappedLocation = FLAG_MAPPING[modifiedName][1]
				end
			else
				mappedLocation = "@"
			end
			
			print("[\""..modifiedName.."\"] = { \""..mappedLocation.."\" },")
		end
	end
end

-- called whenever the hints key in data storage updated
-- NOTE: this should correctly handle having multiple mapped locations in a section.
--       if you only map sections 1 to 1 you can simplfy this. for an example see
--       https://github.com/Cyb3RGER/sm_ap_tracker/blob/main/scripts/autotracking/archipelago.lua
function onHintsUpdate(hints)
	-- Highlight is only supported since version 0.32.0
	if PopVersion < "0.32.0" or not AUTOTRACKER_ENABLE_LOCATION_TRACKING then
		return
	end
	local player_number = Archipelago.PlayerNumber
	-- get all new highlight values per section
	local sections_to_update = {}
	for _, hint in ipairs(hints) do
		-- we only care about hints in our world
		if hint.finding_player == player_number then
			updateHint(hint, sections_to_update)
		end
	end
	-- update the sections
	for location_code, highlight_code in pairs(sections_to_update) do
		-- find the location object
		local obj = Tracker:FindObjectForCode(location_code)
		-- check if we got the location and if it supports Highlight
		if obj and obj.Highlight then
			obj.Highlight = highlight_code
		end
	end
end

-- update section highlight based on the hint
function updateHint(hint, sections_to_update)
	-- get the highlight enum value for the hint status
	local hint_status = hint.status
	local highlight_code = nil
	if hint_status then
		highlight_code = HINT_STATUS_MAPPING[hint_status]
	end
	if not highlight_code then
		if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
			print(string.format("updateHint: unknown hint status %s for hint on location id %s", hint.status,
				hint.location))
		end
		-- try to "recover" by checking hint.found (older AP versions without hint.status)
		if hint.found == true then
			highlight_code = Highlight.None
		elseif hint.found == false then
			highlight_code = Highlight.Unspecified
		else
			return
		end
	end
	-- get the location mapping for the location id
	local mapping_entry = LOCATION_MAPPING[hint.location]
	if not mapping_entry then
		if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
			print(string.format("updateHint: could not find location mapping for id %s", hint.location))
		end
		return
	end
	--get the "highest" highlight value pre section
	for _, location_table in pairs(mapping_entry) do
		if location_table then
			local location_code = location_table[1]
			-- skip hosted items, they don't support Highlight
			if location_code and location_code:sub(1, 1) == "@" then
				-- see if we already set a Highlight for this section
				local existing_highlight_code = sections_to_update[location_code]
				if existing_highlight_code then
					-- make sure we only replace None or "increase" the highlight but never overwrite with None
					-- this so sections with mulitple mapped locations show the "highest" Highlight and
					-- only show no Highlight when all hints are found
					if existing_highlight_code == Highlight.None or (existing_highlight_code < highlight_code and highlight_code ~= Highlight.None) then
						sections_to_update[location_code] = highlight_code
					end
				else
					sections_to_update[location_code] = highlight_code
				end
			end
		end
	end
end

-- add AP callbacks
-- un-/comment as needed
Archipelago:AddClearHandler("clear handler", onClear)
if AUTOTRACKER_ENABLE_ITEM_TRACKING then
	Archipelago:AddItemHandler("item handler", onItem)
end
if AUTOTRACKER_ENABLE_LOCATION_TRACKING then
	Archipelago:AddLocationHandler("location handler", onLocation)
end
Archipelago:AddRetrievedHandler("retrieved handler", onDataStorageUpdate)
Archipelago:AddSetReplyHandler("set reply handler", onDataStorageUpdate)
-- Archipelago:AddScoutHandler("scout handler", onScout)
-- Archipelago:AddBouncedHandler("bounce handler", onBounce)