local Interfaces = require("utility/interfaces")
local Events = require("utility/events")
local GuiUtil = require("utility/gui-util")
--local Logging = require("utility/logging")
local Colors = require("utility/colors")
local GuiActionsClick = require("utility/gui-actions-click")
local Gui = {}

Gui.CreateGlobals = function()
    global.gui = global.gui or {} ---@type table
    global.gui.playerOverviewOpen = global.gui.playerOverviewOpen or {} ---@type table<uint, boolean> -- PlayerIndex to open or not.
end

Gui.OnLoad = function()
    GuiActionsClick.MonitorGuiClickActions()
    Interfaces.RegisterInterface("Gui.UpdateOverviewForAllPlayers", Gui.UpdateOverviewForAllPlayers)
    Events.RegisterHandlerEvent(defines.events.on_player_joined_game, "Gui.OnPlayerJoined", Gui.OnPlayerJoined)
    Interfaces.RegisterInterface("Gui.RecreateAllPlayers", Gui.RecreateAllPlayers)
    Events.RegisterHandlerEvent(defines.events.on_lua_shortcut, "Gui.OnLuaShortcut", Gui.OnLuaShortcut)
    Interfaces.RegisterInterface("Gui.ShowWinningGuiAllPlayers", Gui.ShowWinningGuiAllPlayers)
    GuiActionsClick.LinkGuiClickActionNameToFunction("Gui.CloseWinningGuiForPlayer", Gui.CloseWinningGuiForPlayer)
end

Gui.Startup = function()
    Gui.RecreateAllPlayers()
end

---@param event EventData.on_player_joined_game
Gui.OnPlayerJoined = function(event)
    local playerIndex, player = event.player_index, game.get_player(event.player_index) ---@cast player -nil
    global.gui.playerOverviewOpen[playerIndex] = global.gui.playerOverviewOpen[playerIndex] or true
    Gui.RecreatePlayer(player)
end

---@param player LuaPlayer
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

---@param player LuaPlayer
Gui.OpenOverviewForPlayer = function(player)
    global.gui.playerOverviewOpen[player.index] = true
    player.set_shortcut_toggled("rocket_target-overview_toggle", true)
    Gui.CreateOverviewForPlayer(player)
end

---@param player LuaPlayer
Gui.CloseOverviewForPlayer = function(player)
    GuiUtil.DestroyPlayersReferenceStorage(player.index, "overview")
    global.gui.playerOverviewOpen[player.index] = false
    player.set_shortcut_toggled("rocket_target-overview_toggle", false)
end

---@param player LuaPlayer
Gui.ToggleOverViewForPlayer = function(player)
    if global.gui.playerOverviewOpen[player.index] then
        Gui.CloseOverviewForPlayer(player)
    else
        Gui.OpenOverviewForPlayer(player)
    end
end

---@param player LuaPlayer
Gui.CreateOverviewForPlayer = function(player)
    local overviewValueLabelStyle = "muppet_label_heading_large_bold"
    local goalItemNameCaption = "" ---@type LocalisedString
    if global.rocket.showGoalTitleText then
        overviewValueLabelStyle = "muppet_label_text_medium_semibold"
        local goalItemName = { "item-name." .. global.rocket.goalItemName } ---@type LocalisedString
        if global.rocket.goalItemName == "rocket-silo-rocket" then
            goalItemName = "Rockets"
        end
        goalItemNameCaption = { "self", goalItemName }
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
                            name = "goalType",
                            type = "label",
                            caption = goalItemNameCaption,
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
                                    styling = { width = 20, height = 20 },
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

---@param player LuaPlayer
Gui.UpdateOverviewForPlayer = function(player)
    local playerIndex = player.index
    if not global.gui.playerOverviewOpen[playerIndex] then
        return
    end

    local valueLabel = GuiUtil.GetElementFromPlayersReferenceStorage(playerIndex, "overview", "overviewValue", "label") ---@type LuaGuiElement
    if global.rocket.goalTarget > 0 then
        valueLabel.caption = { "gui-caption." .. GuiUtil.GenerateGuiElementName("overviewValue", "label"), global.rocket.goalProgress, global.rocket.goalTarget }
    else
        valueLabel.caption = global.rocket.goalProgress
    end
    if global.rocket.goalReached then
        valueLabel.style.font_color = Colors.limegreen
    else
        valueLabel.style.font_color = Colors.white
    end

    local valueSprite = GuiUtil.GetElementFromPlayersReferenceStorage(playerIndex, "overview", "overviewValue", "sprite") ---@type LuaGuiElement
    local valueSpritePath ---@type string
    if global.rocket.goalItemName == "rocket-silo-rocket" then
        valueSpritePath = "rocket_target-rocket_launched"
    else
        valueSpritePath = "item/" .. global.rocket.goalItemName
    end
    if game.is_valid_sprite_path(valueSpritePath) then
        valueSprite.sprite = valueSpritePath
    else
        valueSprite.sprite = "item/item-unknown"
    end
end

---@param eventData EventData.on_lua_shortcut
Gui.OnLuaShortcut = function(eventData)
    local shortcutName = eventData.prototype_name
    if shortcutName == "rocket_target-overview_toggle" then
        local player = game.get_player(eventData.player_index) ---@cast player -nil
        Gui.ToggleOverViewForPlayer(player)
    end
end

Gui.ShowWinningGuiAllPlayers = function()
    for _, player in pairs(game.connected_players) do
        Gui.ShowWinningGuiForPlayer(player)
    end
end

---@param player LuaPlayer
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
                                    styling = { maximal_width = 470 }
                                },
                                {
                                    type = "flow",
                                    direction = "horizontal",
                                    style = "muppet_flow_horizontal",
                                    styling = { horizontal_align = "right", horizontally_stretchable = true, minimal_width = 30 },
                                    children = {
                                        {
                                            name = "winningGuiCloseButton",
                                            type = "sprite-button",
                                            sprite = "utility/close_white",
                                            tooltip = "self",
                                            style = "muppet_sprite_button_frame_clickable",
                                            registerClick = { actionName = "Gui.CloseWinningGuiForPlayer" }
                                        }
                                    }
                                }
                            }
                        },
                        {
                            type = "frame",
                            style = "muppet_frame_content_marginTL_paddingBR",
                            styling = { horizontally_stretchable = true },
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
                                            styling = { maximal_width = 500 }
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

--- Needed as current old version of UTILS isn't typed.
---@class UtilityGuiActionsClick_ActionData # The response object passed to the callback function when the GUI element is clicked. Registered with GuiActionsClick.RegisterGuiForClick().
---@field actionName string # The action name registered to this GUI element being clicked.
---@field playerIndex uint # The player_index of the player who clicked the GUI.
---@field data any # The data argument passed in when registering this function action name.
---@field eventData EventData.on_gui_click # The raw Factorio event data for the on_gui_click event.

---@param actionData UtilityGuiActionsClick_ActionData
Gui.CloseWinningGuiForPlayer = function(actionData)
    local player = game.get_player(actionData.playerIndex) ---@cast player -nil
    GuiUtil.DestroyPlayersReferenceStorage(player.index, "winningMessage")
end

return Gui
