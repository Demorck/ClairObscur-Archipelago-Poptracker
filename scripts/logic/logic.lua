-- Access functions

function can_access_level(level_name)
    return has(level_name)
end

function has_at_least(item, amount)
    return Tracker:ProviderCountForCode(item) >= amount
end

function estimated_level_50()
    return has_at_least("Picto",5) or has("PaintedPower")
end

function has_lost_gestral(count)
    if has("gestral_shuffle") then
        return has_at_least("LostGestral", tonumber(count))
    else
        local calculatedCount = 0

        --Esquies Nest (1)
        if(firstcont_north()) then
            calculatedCount = calculatedCount + 1
        end

        --Outside SWC (2)
        if(firstcont_north_and_esquie()) then
            calculatedCount = calculatedCount + 1
        end

        --White Tree (3)
        if(south_sea()) then
            calculatedCount = calculatedCount + 1
        end

        --near Monoco's Station (4)
        if(secondcont_south()) then
            calculatedCount = calculatedCount + 1
        end

        --Near Costal Cave and mimes on red island after OL (6)
        if(north_sea()) then
            calculatedCount = calculatedCount + 2
        end

        --ENS, Reacher, and ET (9)
        if(sky_no_pp()) then
            calculatedCount = calculatedCount + 3
        end

        if(calculatedCount >= tonumber(count)) then
            return true
        else
            return false
        end
    end 
end

function has_beast_part(count)
    return has_at_least("BeastPart", tonumber(count))
end

function has_five_characters()
    local characters = {"Gustave", "Maelle", "Lune", "Sciel", "Monoco", "Verso"}
    local count = 0

    for _, character in ipairs(characters) do
        if has(character) then
            count = count + 1
        end
    end

    return count >= 5
end

function has_rock_crystal(count)
    return has_at_least("RockCrystal", tonumber(count))
end

function show_endgame_locations()
    return has("include_endgame_locations") or has("goal_simon") or has("goal_osquio")
end

-- This function was created because certain locations for Clea were initially flagged as "endgame locations", but need to be included for her goal.
function hide_clea_endgame_locations()
    if has("include_endgame_locations") then
        return true
    end

    if has("goal_clea") or has("goal_paintress") or has("goal_curator") then
        return false
    end
    
            return true
end

function calculate_picto_count_from_level(count) -- count is the picto level on the APWorld to keep consistent
    local estimatedLevel = math.ceil((tonumber(count)-1) * 5.8) -- Yoinked from convert_pictos() function on the APWorld

    --If the player has painted power, reduce the estimatedLevel by 1 since it doesn't count as a picto
    if has("PaintedPower") then
        estimatedLevel = estimatedLevel - 1
    end

    return has_at_least("Picto",estimatedLevel)
end

-- Continent Pathing Functions

function south_sea()
    return has("swim")
end

function north_sea()
    return (has("coral")) or has("fly")
end

function firstcont_south()
    return true --for random starting location, if that is ever added.
end

function firstcont_north()
    return (has("swim") or (has("FlyingWaters") and calculate_picto_count_from_level(3)) or has("fly")) --Picto level 3 gotten from the flying_waters.json in the logic folder
end

function firstcont_north_and_esquie()
    return has("esquie") and firstcont_north()
end

function secondcont_south()
    return (south_sea() and has("ForgottenBattlefield") and calculate_picto_count_from_level(8)) or north_sea() --Picto level 8 gotten from the forgotten_battlefield.json in the logic folder
end

function secondcont_nw()
    return (secondcont_south() and has("MonocosStation") and calculate_picto_count_from_level(9)) or has("coral") or has("fly") --Picto level 9 gotten from the monocos_station.json in the logic folder
end

function secondcont_ne()
    return (secondcont_south() and has("MonocosStation") and calculate_picto_count_from_level(9)) or has("fly") --Picto level 9 gotten from the monocos_station.json in the logic folder
end

function sky()
    return has("fly") and has("paintedpower")
end

function sky_no_pp()
    return has("fly")
end

function dive()
    return has("dive")
end

-- Shopsanity logic --
-- Shopsanity is an item, so no need for a script to check that

function shop_count(count)
    --print("Dumping shopsanity, location_per_shop, count, has_at_least(location_per_shop, count):")
    --print(has("shopsanity"))
    --print(has("location_per_shop"))
    --print(count)
    --print(has_at_least("location_per_shop", tonumber(count)))
    if has("shopsanity") and has_at_least("location_per_shop", tonumber(count)) then
        return true
    else
        return false
    end
end

function extra_shop_count(count)
    if has("shopsanity") and has_at_least("extra_location_per_shop", tonumber(count)) then
        return true
    else
        return false
    end
end

-- Multiple Goal logic --

local goals = {
    paintress = "goal_paintress",
    curator = "goal_curator",
    clea = "goal_clea",
    painted_love = "goal_painted-love",
    simon = "goal_simon",
    osquio = "goal_osquio"
}

function is_goal_selected(goal)
    local goal_key = goals[goal]
    return has(goal_key)
end

function goal_finishes_run(goal)
    local goal_key = goals[goal]
    
    if not goal_key then
        return false
    end
    
    if not has(goal_key) then
        return false
    end

    if has("goal_requirement_any") then
        return true
    end

    for goal_name, goal_key in pairs(goals) do
        if goal_name ~= goal and has(goal_key) then
            local goalStatus = Tracker:FindObjectForCode(goal_key)

            if not goalStatus then
                return false
            end

            if (goalStatus.CurrentStage ~= 2) then
                return false
            end
        end
    end

    return true
end
