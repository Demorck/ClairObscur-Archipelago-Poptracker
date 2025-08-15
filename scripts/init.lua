DEBUG = false
ENABLE_DEBUG_LOG = DEBUG



ScriptHost:LoadScript("scripts/utils.lua")
ScriptHost:LoadScript("scripts/logic/logic.lua")

Tracker:AddItems("items/items.json")

Tracker:AddMaps("maps/maps.json")

-- Tracker:AddLocations("locations/maps.json")
-- Tracker:AddLocations("locations/continent.json")
ScriptHost:LoadScript("scripts/import_locations.lua")

Tracker:AddLayouts("layouts/items.json")
Tracker:AddLayouts("layouts/maps.json")
Tracker:AddLayouts("layouts/tracker.json")