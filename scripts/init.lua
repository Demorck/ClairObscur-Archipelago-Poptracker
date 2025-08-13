DEBUG = false
ENABLE_DEBUG_LOG = DEBUG


Tracker:AddItems("items/items.json")

Tracker:AddMaps("maps/maps.json")

-- Tracker:AddLocations("locations/maps.json")
-- Tracker:AddLocations("locations/continent.json")
Tracker:AddLocations("locations/spring_meadows.json")
Tracker:AddLocations("locations/logics/spring_meadows.json")
Tracker:AddLocations("locations/flying_waters.json")
Tracker:AddLocations("locations/logics/flying_waters.json")

Tracker:AddLayouts("layouts/items.json")
Tracker:AddLayouts("layouts/maps.json")
Tracker:AddLayouts("layouts/tracker.json")