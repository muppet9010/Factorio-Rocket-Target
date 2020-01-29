local Interfaces = require("utility/interfaces")
local Events = require("utility/events")
local GuiUtil = require("utility/gui-util")
local Logging = require("utility/logging")
local Gui = {}

Gui.CreateGlobals = function()
    global.gui = global.gui or {}
    global.gui.playerOverviewOpen = global.gui.playerOverviewOpen or {}
end

Gui.OnLoad = function()
    Interfaces.RegisterInterface("Gui.UpdateOverviewForAllPlayers", Gui.UpdateOverviewForAllPlayers)
    Events.RegisterHandler(defines.events.on_player_joined_game, "Gui.OnPlayerJoined", Gui.OnPlayerJoined)
    Interfaces.RegisterInterface("Gui.RecreateAllPlayers", Gui.RecreateAllPlayers)
    Events.RegisterHandler(defines.events.on_lua_shortcut, "Gui.OnLuaShortcut", Gui.OnLuaShortcut)
end

Gui.Startup = function()
    Gui.RecreateAllPlayers()
end

Gui.OnPlayerJoined = function(event)
    local playerIndex, player = event.player_index, game.get_player(event.player_index)
    global.gui.playerOverviewOpen[playerIndex] = global.gui.playerOverviewOpen[playerIndex] or true
    Gui.RecreatePlayer(player)
end

Gui.RecreatePlayer = function(player)
    GuiUtil.DestroyPlayersReferenceStorage(player.index, "overview")
    Gui.CreateOverviewForPlayer(player)
end

Gui.RecreateAllPlayers = function()
    for _, player in pairs(game.connected_players) do
        Gui.RecreatePlayer(player)
    end
end

Gui.OpenOverviewForPlayer = function(player)
    global.gui.playerOverviewOpen[player.index] = true
    Gui.CreateOverviewForPlayer(player)
end

Gui.CloseOverviewForPlayer = function(player)
    GuiUtil.DestroyPlayersReferenceStorage(player.index, "overview")
    global.gui.playerOverviewOpen[player.index] = false
end

Gui.ToggleOverViewForPlayer = function(player)
    if global.gui.playerOverviewOpen[player.index] then
        Gui.CloseOverviewForPlayer(player)
    else
        Gui.OpenOverviewForPlayer(player)
    end
end

Gui.CreateOverviewForPlayer = function(player)
    local playerIndex = player.index
    if not global.gui.playerOverviewOpen[playerIndex] then
        return
    end

    local frame = GuiUtil.AddElement({parent = player.gui.left, name = "overview", type = "frame", style = "muppet_margin_frame_main"}, "overview")
    local flow = GuiUtil.AddElement({parent = frame, name = "overview", type = "flow", direction = "vertical", style = "muppet_vertical_flow"})
    GuiUtil.AddElement({parent = flow, name = "overviewTitle", type = "label", caption = {"string-mod-setting.rocket_target-goal_type-" .. global.rocket.goalItemName}, style = "muppet_large_semibold_heading"})
    local overViewValueTable = GuiUtil.AddElement({parent = flow, name = "overviewValue", type = "table", column_count = 2})
    GuiUtil.AddElement({parent = overViewValueTable, name = "overviewValue", type = "label", style = "muppet_medium_semibold_text"}, "overview")
    GuiUtil.AddElement({parent = overViewValueTable, name = "overviewValue", type = "sprite", style = "rocket_target_medium_text_sprite"}, "overview")

    Gui.UpdateOverviewForPlayer(player)
end

Gui.UpdateOverviewForAllPlayers = function()
    for _, player in pairs(game.connected_players) do
        Gui.UpdateOverviewForPlayer(player)
    end
end

Gui.UpdateOverviewForPlayer = function(player)
    local playerIndex = player.index
    if not global.gui.playerOverviewOpen[playerIndex] then
        return
    end

    GuiUtil.UpdateElementFromPlayersReferenceStorage(
        playerIndex,
        "overview",
        "overviewValue",
        "label",
        {
            caption = {"self", global.rocket.goalProgress, global.rocket.goalTarget}
        }
    )

    local valueSprite = GuiUtil.GetElementFromPlayersReferenceStorage(playerIndex, "overview", "overviewValue", "sprite")
    local valueSpritePath
    if global.rocket.goalItemName == "rocket-silo-rocket" then
        valueSpritePath = "rocket_target-rocket_launched"
    else
        valueSpritePath = "item/" .. global.rocket.goalItemName
    end
    valueSprite.sprite = valueSpritePath
end

Gui.OnLuaShortcut = function(eventData)
    local shortcutName = eventData.prototype_name
    if shortcutName == "rocket_target-overview_toggle" then
        local player = game.get_player(eventData.player_index)
        Gui.ToggleOverViewForPlayer(player)
    end
end

return Gui
