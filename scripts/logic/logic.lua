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
    return has_at_least("LostGestral", tonumber(count))
end

function has_beast_part(count)
    return has_at_least("BeastPart", tonumber(count))
end

function has_rock_crystal(count)
    return has_at_least("RockCrystal", tonumber(count))
end

function hide_clea_endgame_locations()
    if has("include_endgame_locations") then
        return true
    end

    if has("goal_clea") then
        return false
    end
    return true
end

-- Continent Pathing Functions

function south_sea()
    return has("swim")
end

function north_sea()
    return (has("swim") and has("coral")) or has("fly")
end

function firstcont_south()
    return true --for random starting location
end

function firstcont_north()
    return (has("swim") or has("FlyingWaters")) or has("fly")
end

function firstcont_north_and_esquie()
    return has("esquie") and firstcont_north()
end

function secondcont_south()
    return (south_sea() and has("ForgottenBattlefield")) or north_sea()
end

function secondcont_nw()
    return (secondcont_south() and has("MonocosStation")) or has("fly")
end

function secondcont_ne()
    return (secondcont_south() and has("MonocosStation")) or has("fly")
end

function sky()
    return has("fly") and has("paintedpower")
end

function sky_no_pp()
    return has("fly")
end

function dive()
    return has("swim") and has("dive")
end