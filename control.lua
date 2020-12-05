local Rocket = require("scripts/rocket")
local Gui = require("scripts/gui")

local function CreateGlobals()
    Rocket.CreateGlobals()
    Gui.CreateGlobals()
end

local function OnLoad()
    --Any Remote Interface registration calls can go in here or in root of control.lua
    Rocket.OnLoad()
    Gui.OnLoad()
end

local function OnSettingChanged(event)
    Rocket.OnSettingChanged(event)
end

local function OnStartup()
    CreateGlobals()
    OnLoad()
    OnSettingChanged(nil)

    Gui.Startup()
end

script.on_init(OnStartup)
script.on_configuration_changed(OnStartup)
script.on_event(defines.events.on_runtime_mod_setting_changed, OnSettingChanged)
script.on_load(OnLoad)
