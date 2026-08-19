Poptracker for Clair Obscur Expedition 33 randomizer.

Maps come from: [Minimap mod from paboyafx](https://www.nexusmods.com/clairobscurexpedition33/mods/383)

Documentation and Poptracker pack by yezzdia
Note: If I am no longer contributing but there is a question about how this was all set up, feel free to @ me in the AP AD server or DM me on Discord.

## General File Structure
## Images
1. `items` - contains all of the images for each item in Poptracker. This includes literal items in the game (Pictos), imaginary items created for AP (Area tickets), and Poptracker settings (bottom segment of the left column) because all of the settings are items in the background.
2. `maps` - contains all of the maps. Names are similar to the actual zone name except for the Continent which was broken up into 3 pieces

## Items
This is a sole json file that contains all of the items and their properties. 

## Layouts
1. `items.json` - the layout of the items on the left side of the Poptracker are all laid out here. I generally didn't have much of a format that I followed here other than avoiding making the items wider than 6 items. Although that was partially a selfish reason because it fits nicely on my vertical monitor. :) I wanted to keep a logical separation between the different areas Esquie is needed which is why it is split into different sized chunks. A while ago a compact layout was mentioned that I never got around to making and condensing those categories is probably where most of the space would come from.
2. `maps.json` - Just has the map tab layout. If you change the format of this (ie nest multiple maps), you will need to correct autotab for it to work properly.
3. `tracker.json` - Categories for the items gets put here

- New additions to the layout need to be made in `tracker.json` and `items.json` for items, and only `maps.json` for maps.

## Locations
### Locations (again)
- This is where all of the nodes on the map are held. 
- Everything in the `locations` folder points to the nodes on Poptracker themselves while everything in the `logics` folder contain the respective logic for each location
- The general structure of each file is `Chests` > `Enemies/Bosses` > `Merchants` > `Flags`. While not every file follows this format, it is because I am stupid and didn't notice. This structure was followed for no reason other than to make it easy to find what you're looking for.
- For locations, you can have individual nodes or stack locations. `flying_waters.json` has a great example of how this can be formatted with the addition of the shop. Generally speaking, just follow the format of what is already there and you'll get where you need to go.
- For individual nodes, `sections` needs to have a reference to the name of the matching logic file, followed by a /, followed by the name of the check in the `logics` file. For example, `"ref": "Entrance - Flying Waters/Goblu"` references the "Entrance - Flying Waters" file, specifically the "Goblu" check.
- For stacked nodes, `sections` needs to contain an array of each node you are including in the stack. See Noco's locations in `flying_waters.json` for an example. In each section of `sections`, you need to have a reference similar to the note above, as well as a name. The name is what appears on the tracker, but for consistency, I kept them the same.
- For both, `map_locations` determines which map and its xy coordinates to display the block

### Locations\Logics
- `map_locations` is used to map what node in Poptracker lists **all** of the locations in this file. All of the trapezoid locations on the Continent are mapped in the individual files in this key.
- `name` must match up with what is being referenced in the `locations` file.
- Under each node, `access_rules` is used to determine whether the individual node has any special logic and is displayed as red, green, or yellow.
- Under each node, `visibility_rules` can be used to determine whether the individual node has certain logic conditions that will cause this node to be displayed or hidden. If true, it is shown. If false, it is hidden.
- At the bottom of the file, `access_rules` and `visibility_rules` can be included. These two rules apply to every item in the file.
- To check for an item in either rule, use the item code (`FlyingWaters` == `Area - Flying Waters`)
- To use a custom function (see Scripts) to check for logic, call it by using `$FunctionName`. If your function has args, those can be assigned by using `$FunctionName|arg`. In the case of the picto level calculation, it uses this format: `$calculate_picto_count_from_level|3` to pass 3 to the function. Keep in mind that these functions **ALWAYS** pass as a string. I had some weird issues when trying to cast it from the function itself, so I just convert in each function.
- To make an `access_rules` change the location to yellow, surround the rule in []. For example, `[$calculate_picto_count_from_level|3]`, if you have enough Pictos for this access_rule to be true, the node will be green. If it returns false, it will display yellow, not red. 
- Rules are grouped by being included in quotes "like,[this]". Multiple groups can be overlaid if there are different logic sets by separating quoted segments with a comma `"similar,$toSomething|like","$this"` where it will throw true if `similar` and function `toSomething` with arg `like` are all true, **OR** function `this` returns true. `access_rules` and `visibility_rules` follow this same structure.

## Maps
- `maps.json` holds all of the map keys. You can change the size of each node by default here, as well as associate a map file. The name that is used in `logics` and `locations` to point a location to a map uses the `name` key here.

## Scripts
1. `autotracking.lua` - I think this was the only file I didn't touch in here. It may have been included in the initial autotracking setup which was done by Demorck.
2. `import_locations.lua` - Houses every json file that is loaded into the tracker. If you create a new file, it needs to be added here.
3. `init.lua` - Any scripts or data files that need to be loaded on pack load need to be included here
4. `utils.lua` - I believe this is all included in the pack by default. Just some functions you can use. Don't think I actually used any of these.

### Scripts\Logic
- All functions that are called in any of the logic files are called from `logic.lua`
- Each function should return a bool
- Refer to Locations\Logics for more information on how to call these functions. 
- Instead of using the same region structure as the apworld, I separated them into nested functions that feed off the logic of previous functions. It may not be the easiest to follow, but I was new to all of this when I set it up and am far too lazy to redo it all at this point. Since this game has its regions built as fairly linear, this works well because in order to get to `firstcont_north` (after Flying Waters), you have to have `firstcont_south`, and so on.
- Most of it is pretty straight forward, but some comments are included in the script as needed.

### Scripts\Autotracking
1. `autotab_mapping.lua` - This is used for the autotabbing feature. Each area has a listed entrance and exit. The entrance is used to move your map to the respective zone, while the exit is used to point Poptracker to a specific map in the Continent since the game treats this as one map. More information on this in `archipelago.lua`.
2. `flag_mapping.lua` - Maps each flag ingame to its respective `logics` location. More information on this in `archipelago.lua`. `Not Implemented` is a keyphrase that the script looks for.
3. `item_mapping.lua` - Maps each AP item ID to the item name in Poptracker as well as the item type. This file is the reason why the item index shifting is such a massive pain in the ass to deal with. If an item is granted in AP and Poptracker gives the wrong one, this item index is off.
4. `location_mapping.lua` - Basically the same as `item_mapping.lua`, but way longer. This is used to check off nodes on Poptracker when a flag is found. 
5. `archipelago.lua` - This is where most of my customization was made. This is called when AP connects. This performs an initial sync from AP to Poptracker. This will sync any slot data, options, items, etc.
- `apply_slot_data()` applies slot data upon initial connection
- `Archipelago:SetNotify({ap_flags})` causes Poptracker to listen for any flag changes. Whenever a flag change is made, it will update the node on Poptracker.
- `Archipelago:Get({ap_flags})` is called to do a one-time update to make sure flags are up to date.
- Same logic is applied for autotabbing as the above to function calls
- Pretty much everything else in here is commented. If you're making changes, refer to existing code.

## Cheatsheet
1. When adding an item to Poptracker, add it in `items\items.json`, an image (if applicable) in `images\items`, and a layout entry in `layouts\items.json`. If it is an option, add it in `scripts\autotracking\archipelago.lua` to be toggled on connection. If it is an actual item, add it in `scripts\autotracking\item_mapping.lua`
2. When adding a location, add it in `locations\area_name.json`, `locations\logics\area_name.json`, retrieve the location id from AP, and add that into `scripts\autotracking\location_mapping.lua`. If any special access or visibility logic is required, add it in `scripts\logic\logic.lua`.
3. To make Poptracker auto-update, change the version in `manifest.json`, create the zip for the new release, add a new entry at the **TOP** of `versions.json` (using the filehash of the new zip) (Make sure to update the version in both `package_version` and the URL), and push to Github. For the zip, exclude `versions.json`.