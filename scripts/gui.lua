local Interfaces = require("utility/interfaces")
local Events = require("utility/events")
local GuiUtil = require("utility/gui-util")
local Logging = require("utility/logging")
local Gui = {}

Gui.CreateGlobals = function()
end

Gui.OnLoad = function()
    Interfaces.Register("Gui.UpdateValueForAllPlayers", Gui.UpdateValueForAllPlayers)
end

Gui.Startup = function()
end

Gui.UpdateValueForAllPlayers = function()
    for _, player in pairs(game.connected_players) do
        Gui.UpdateValueForPlayer(player)
    end
end

Gui.UpdateValueForPlayer = function(player)
    --TODO
end

return Gui
