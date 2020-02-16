local Interfaces = require("utility/interfaces")
local Events = require("utility/events")
local GuiUtil = require("utility/gui-util")
--local Logging = require("utility/logging")
local Colors = require("utility/colors")
local GuiActionsClick = require("utility/gui-actions-click")
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
    GuiActionsClick.LinkGuiClickActionNameToFunction("Gui.CloseWinningGuiForPlayer", Gui.CloseWinningGuiForPlayer)
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
    if not global.gui.playerOverviewOpen[player.index] then
        return
    end
    Gui.OpenOverviewForPlayer(player)
end

Gui.RecreateAllPlayers = function()
    for _, player in pairs(game.connected_players) do
        Gui.RecreatePlayer(player)
    end
end

Gui.OpenOverviewForPlayer = function(player)
    global.gui.playerOverviewOpen[player.index] = true
    player.set_shortcut_toggled("rocket_target-overview_toggle", true)
    Gui.CreateOverviewForPlayer(player)
end

Gui.CloseOverviewForPlayer = function(player)
    GuiUtil.DestroyPlayersReferenceStorage(player.index, "overview")
    global.gui.playerOverviewOpen[player.index] = false
    player.set_shortcut_toggled("rocket_target-overview_toggle", false)
end

Gui.ToggleOverViewForPlayer = function(player)
    if global.gui.playerOverviewOpen[player.index] then
        Gui.CloseOverviewForPlayer(player)
    else
        Gui.OpenOverviewForPlayer(player)
    end
end

Gui.CreateOverviewForPlayer = function(player)
    local overviewValueLabelStyle = "muppet_label_heading_large_bold"
    if global.rocket.showGoalTitleText then
        overviewValueLabelStyle = "muppet_label_text_medium_semibold"
    end
    GuiUtil.AddElement(
        {
            parent = player.gui.left,
            name = "overview",
            type = "frame",
            style = "muppet_frame_main_marginTL_paddingBR",
            storeName = "overview",
            children = {
                {
                    type = "flow",
                    direction = "vertical",
                    style = "muppet_flow_vertical_marginTL",
                    children = {
                        {
                            type = "label",
                            caption = {"string-mod-setting.rocket_target-goal_type-" .. global.rocket.goalItemName},
                            style = "muppet_label_heading_large_bold",
                            exclude = not global.rocket.showGoalTitleText
                        },
                        {
                            type = "table",
                            column_count = 2,
                            children = {
                                {
                                    name = "overviewValue",
                                    type = "label",
                                    style = overviewValueLabelStyle,
                                    storeName = "overview"
                                },
                                {
                                    name = "overviewValue",
                                    type = "sprite",
                                    style = "muppet_sprite_32",
                                    styling = {width = 20, height = 20},
                                    storeName = "overview"
                                }
                            }
                        }
                    }
                }
            }
        }
    )

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
        valueLabel.caption = {"gui-caption." .. GuiUtil.GenerateGuiElementName("overviewValue", "label"), global.rocket.goalProgress, global.rocket.goalTarget}
    else
        valueLabel.caption = global.rocket.goalProgress
    end
    if global.rocket.goalReached then
        valueLabel.style.font_color = Colors.limegreen
    else
        valueLabel.style.font_color = Colors.white
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
    local label1Text = global.rocket.winningTitle
    local label1Style = "muppet_label_text_medium_semibold"
    local label2Text = ""
    if label1Text == "" then
        label1Text = global.rocket.winningMessage
    else
        label2Text = global.rocket.winningMessage
        label1Style = "muppet_label_heading_large_bold"
    end

    GuiUtil.AddElement(
        {
            parent = player.gui.center,
            name = "winningGuiOuter",
            type = "frame",
            style = "muppet_frame_main_marginTL_paddingBR",
            storeName = "winningMessage",
            children = {
                {
                    type = "flow",
                    direction = "vertical",
                    style = "muppet_flow_vertical",
                    children = {
                        {
                            type = "flow",
                            direction = "horizontal",
                            style = "muppet_flow_horizontal_marginTL",
                            children = {
                                {
                                    type = "label",
                                    style = label1Style,
                                    caption = label1Text,
                                    styling = {maximal_width = 470}
                                },
                                {
                                    type = "flow",
                                    direction = "horizontal",
                                    style = "muppet_flow_horizontal",
                                    styling = {horizontal_align = "right", horizontally_stretchable = true, minimal_width = 30},
                                    children = {
                                        {
                                            name = "winningGuiCloseButton",
                                            type = "sprite-button",
                                            sprite = "utility/close_white",
                                            tooltip = "self",
                                            style = "muppet_sprite_button_frame_clickable",
                                            registerClick = {actionName = "Gui.CloseWinningGuiForPlayer"}
                                        }
                                    }
                                }
                            }
                        },
                        {
                            type = "frame",
                            style = "muppet_frame_content_marginTL_paddingBR",
                            styling = {horizontally_stretchable = true},
                            exclude = label2Text == "",
                            children = {
                                {
                                    type = "flow",
                                    direction = "vertical",
                                    style = "muppet_flow_vertical_marginTL",
                                    children = {
                                        {
                                            type = "label",
                                            style = "muppet_label_text_medium_semibold_paddingSides",
                                            caption = label2Text,
                                            styling = {maximal_width = 500}
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    )
end

Gui.CloseWinningGuiForPlayer = function(actionData)
    local player = game.get_player(actionData.playerIndex)
    GuiUtil.DestroyPlayersReferenceStorage(player.index, "winningMessage")
end

return Gui
