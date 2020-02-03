local Interfaces = require("utility/interfaces")
local Events = require("utility/events")
local GuiUtil = require("utility/gui-util")
--local Logging = require("utility/logging")
local Colors = require("utility/colors")
local GuiActions = require("utility/gui-actions")
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
    Interfaces.RegisterInterface("Gui.ShowWinningGuiAllPlayers", Gui.ShowWinningGuiAllPlayers)
    GuiActions.RegisterActionType("Gui.CloseWinningGuiForPlayer", Gui.CloseWinningGuiForPlayer)
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
    local overviewValueLabelStyle = "muppet_large_bold_heading"
    if global.rocket.showGoalTitleText then
        GuiUtil.AddElement({parent = flow, name = "overviewTitle", type = "label", caption = {"string-mod-setting.rocket_target-goal_type-" .. global.rocket.goalItemName}, style = "muppet_large_bold_heading"})
        overviewValueLabelStyle = "muppet_medium_semibold_text"
    end
    local overViewValueTable = GuiUtil.AddElement({parent = flow, name = "overviewValue", type = "table", column_count = 2})
    GuiUtil.AddElement({parent = overViewValueTable, name = "overviewValue", type = "label", style = overviewValueLabelStyle}, "overview")
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

    local valueLabel = GuiUtil.GetElementFromPlayersReferenceStorage(playerIndex, "overview", "overviewValue", "label")
    if global.rocket.goalTarget > 0 then
        valueLabel.caption = {"gui-caption." .. GuiUtil.GenerateName("overviewValue", "label"), global.rocket.goalProgress, global.rocket.goalTarget}
    else
        valueLabel.caption = global.rocket.goalProgress
    end
    if global.rocket.goalReached then
        valueLabel.style.font_color = Colors.limegreen
    end

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

Gui.ShowWinningGuiAllPlayers = function()
    for _, player in pairs(game.connected_players) do
        Gui.ShowWinningGuiForPlayer(player)
    end
end

Gui.ShowWinningGuiForPlayer = function(player)
    if global.rocket.winningTitle == "" and global.rocket.winningMessage == "" then
        return
    end
    local text1 = global.rocket.winningTitle
    local text2 = ""
    if text1 == "" then
        text1 = global.rocket.winningMessage
    else
        text2 = global.rocket.winningMessage
    end

    local frameOuter = GuiUtil.AddElement({parent = player.gui.center, name = "winningGuiOuter", type = "frame", style = "muppet_frame_main"}, "winningMessage")
    local flowOuter = GuiUtil.AddElement({parent = frameOuter, name = "winningGuiOuter", type = "flow", direction = "vertical", style = "muppet_vertical_flow"})

    local flowOuterContent = GuiUtil.AddElement({parent = flowOuter, name = "winningGuiOuterContent", type = "flow", direction = "horizontal", style = "muppet_horizontal_flow"})
    local winningGuiOuterContentLabel = GuiUtil.AddElement({parent = flowOuterContent, name = "winningGuiOuterContent", type = "label", style = "muppet_large_bold_heading", caption = text1})
    winningGuiOuterContentLabel.style.horizontal_align = "left"
    winningGuiOuterContentLabel.style.maximal_width = 470

    local closeButtonFlow = GuiUtil.AddElement({parent = flowOuterContent, name = "winningGuiCloseButton", type = "flow", direction = "horizontal", style = "muppet_horizontal_flow"})
    closeButtonFlow.style.horizontal_align = "right"
    closeButtonFlow.style.horizontally_stretchable = true
    closeButtonFlow.style.padding = 4
    GuiUtil.AddElement({parent = closeButtonFlow, name = "winningGuiCloseButton", type = "sprite-button", sprite = "utility/close_white", tooltip = "self", style = "close_button"})
    GuiActions.RegisterButtonToAction("winningGuiCloseButton", "sprite-button", "Gui.CloseWinningGuiForPlayer")

    if text2 ~= "" then
        local frameInner = GuiUtil.AddElement({parent = flowOuter, name = "winningGuiInnerContent", type = "frame", style = "muppet_frame_content"})
        frameInner.style.horizontally_stretchable = true
        local winningGuiInnerContentLabel = GuiUtil.AddElement({parent = frameInner, name = "winningGuiInnerContent", type = "label", style = "muppet_medium_semibold_text", caption = text2})
        winningGuiInnerContentLabel.style.horizontal_align = "left"
        winningGuiInnerContentLabel.style.maximal_width = 500
    end
end

Gui.CloseWinningGuiForPlayer = function(actionData)
    local player = game.get_player(actionData.playerIndex)
    GuiUtil.DestroyElementInPlayersReferenceStorage(player.index, "winningMessage", "winningGuiOuter", "frame")
end

return Gui
