local Commands = require("utility/commands")
local Interfaces = require("utility/interfaces")
local Events = require("utility/events")
local Logging = require("utility/logging")
local Rocket = {}

---@class Rocket_RocketLaunched # The response object passed to the callback function when the GUI element is clicked. Registered with GuiActionsClick.RegisterGuiForClick().
---@field rocketId uint # The sequential Id of the rocket launch.
---@field tick uint # The tick the rocket was launched.
---@field items Rocket_RocketLaunchedContent[] # An array of the items in the rocket launched.

---@class Rocket_RocketLaunchedContent # The name and count of an item in a launched rocket.
---@field name string
---@field count uint

---@class Rocket_GoalIncreaseSupporter
---@field id uint # The sequential Id of the goal increase.
---@field description string # The supports name of the goal increase.
---@field done boolean # If the target has been completed or not.

Rocket.CreateGlobals = function()
    global.rocket = global.rocket or {} ---@type table
    global.rocket.rocketsLaunched = global.rocket.rocketsLaunched or {} ---@type table<uint, Rocket_RocketLaunched>
    global.rocket.startingGoal = global.rocket.startingGoal or 0 ---@type uint
    global.rocket.goalIncrease = global.rocket.goalIncrease or 0 ---@type uint
    global.rocket.goalTarget = global.rocket.goalTarget or 0 ---@type uint
    global.rocket.goalProgress = global.rocket.goalProgress or 0 ---@type uint
    global.rocket.goalIncreaseSupporters = global.rocket.goalIncreaseSupporters or {} ---@type table<uint, Rocket_GoalIncreaseSupporter>
    global.rocket.goalItemName = global.rocket.goalItemName or "unknown" ---@type string
    global.rocket.showGoalTitleText = global.rocket.showGoalTitleText or false
    global.rocket.goalReached = global.rocket.goalReached or false ---@type boolean
    global.rocket.winningTitle = global.rocket.winningTitle or "" ---@type string
    global.rocket.winningMessage = global.rocket.winningMessage or "" ---@type string
    global.rocket.startingCompletedCount = global.rocket.startingCompletedCount or 0 ---@type uint
    global.rocket.customItemTrackedName = global.rocket.customItemTrackedName or "" ---@type string
end

Rocket.OnLoad = function()
    Commands.Register("rocket_target_increase_goal", { "api-description.rocket_target_increase_goal" }, Rocket.OnCommandIncreaseGoal, true)
    Events.RegisterHandlerEvent(defines.events.on_rocket_launched, "Rocket.OnRocketLaunched", Rocket.OnRocketLaunched)
end

---@param event EventData.on_runtime_mod_setting_changed
Rocket.OnSettingChanged = function(event)
    if event == nil or event.setting == "rocket_target-starting_goal" then
        global.rocket.startingGoal = tonumber(settings.global["rocket_target-starting_goal"].value) --[[@as uint]]
        Rocket.UpdateGoalTarget()
    end
    if event == nil or event.setting == "rocket_target-goal_type" or event.setting == "rocket_target-custom_item_tracked" or event.setting == "rocket_target-starting_completed_count" then
        global.rocket.goalItemName = settings.global["rocket_target-goal_type"].value --[[@as string]]
        global.rocket.startingCompletedCount = tonumber(settings.global["rocket_target-starting_completed_count"].value) --[[@as uint]]
        global.rocket.customItemTrackedName = settings.global["rocket_target-custom_item_tracked"].value --[[@as string]]
        if global.rocket.goalItemName == "custom" then
            Rocket.CustomItemPrototypeNameSet()
        end
        Rocket.ResetRocketLaunchedGoalCount()
    end
    if event == nil or event.setting == "rocket_target-goal_title" then
        global.rocket.showGoalTitleText = settings.global["rocket_target-goal_title"].value --[[@as string]]
        Interfaces.Call("Gui.RecreateAllPlayers")
    end
    if event == nil or event.setting == "rocket_target-winning_title" then
        global.rocket.winningTitle = settings.global["rocket_target-winning_title"].value --[[@as string]]
    end
    if event == nil or event.setting == "rocket_target-winning_message" then
        global.rocket.winningMessage = settings.global["rocket_target-winning_message"].value --[[@as string]]
    end
end

Rocket.UpdateGoalTarget = function()
    global.rocket.goalTarget = math.floor(global.rocket.startingGoal + global.rocket.goalIncrease) --[[@as uint]]
    Interfaces.Call("Gui.UpdateOverviewForAllPlayers")
end

---@param commandData CustomCommandData
Rocket.OnCommandIncreaseGoal = function(commandData)
    local args = Commands.GetArgumentsFromCommand(commandData.parameter)
    if #args < 1 or #args > 2 then
        Logging.LogPrint("ERROR: rocket_target_increase_goal called with wrong number of arguments")
        return
    end
    local increaseValue = tonumber(args[1])
    if increaseValue == nil or increaseValue <= 0 then
        Logging.LogPrint("ERROR: rocket_target_increase_goal called with non positive number increase value: '" .. args[1] .. "'")
        return
    end
    global.rocket.goalIncrease = global.rocket.goalIncrease + increaseValue
    local supporterName = args[2] or ""
    for _ = 1, increaseValue do
        local id = #global.rocket.goalIncreaseSupporters + 1 --[[@as uint]]
        global.rocket.goalIncreaseSupporters[id] = {
            id = id,
            description = supporterName,
            done = false
        }
    end
    Rocket.UpdateGoalTarget()
end

---@param event  EventData.on_rocket_launched
Rocket.OnRocketLaunched = function(event)
    local rocket = event.rocket
    if rocket == nil or not rocket.valid then
        return
    end
    local rocketId = #global.rocket.rocketsLaunched + 1 --[[@as uint]]
    local rocketDetails = {
        rocketId = rocketId,
        tick = event.tick,
        items = {}
    }
    for name, count in pairs(rocket.get_inventory(defines.inventory.rocket).get_contents()) do
        table.insert(
            rocketDetails.items,
            {
                name = name,
                count = count
            }
        )
    end
    Rocket.AddRocketLaunchedGoalItems(rocketDetails)
    global.rocket.rocketsLaunched[rocketId] = rocketDetails
    Interfaces.Call("Gui.UpdateOverviewForAllPlayers")
end

---@param rocketDetails Rocket_RocketLaunched
Rocket.AddRocketLaunchedGoalItems = function(rocketDetails)
    local targetProgressedCount = 0 ---@type uint
    if global.rocket.goalItemName == "rocket-silo-rocket" then
        targetProgressedCount = 1
    elseif global.rocket.goalItemName ~= "unknown" then
        for _, item in pairs(rocketDetails.items) do
            if item.name == global.rocket.goalItemName then
                targetProgressedCount = targetProgressedCount + item.count
            end
        end
    else
        Logging.LogPrint("Invalid custom item prototype name configured: '" .. tostring(global.rocket.goalItemName) .. "'")
    end
    global.rocket.goalProgress = global.rocket.goalProgress + targetProgressedCount
    Rocket.CheckGoalCompleted()
    --Not done as not sure how to handle the starting target value
    --[[for _, supporter in pairs(global.rocket.goalIncreaseSupporters) do
        if supporter.done == false then
            supporter.done = true
            done = done - 1
            if done == 0 then
                break
            end
        end
    end]]
end

Rocket.ResetRocketLaunchedGoalCount = function()
    global.rocket.goalProgress = global.rocket.startingCompletedCount
    for _, supporter in pairs(global.rocket.goalIncreaseSupporters) do
        supporter.done = false
    end
    for _, rocketDetails in pairs(global.rocket.rocketsLaunched) do
        Rocket.AddRocketLaunchedGoalItems(rocketDetails)
    end
    Rocket.UpdateGoalTarget()
    Interfaces.Call("Gui.RecreateAllPlayers")
end

Rocket.CheckGoalCompleted = function()
    if global.rocket.goalReached or global.rocket.goalTarget <= 0 then
        return
    end
    if global.rocket.goalProgress >= global.rocket.goalTarget then
        global.rocket.goalReached = true
        Interfaces.Call("Gui.ShowWinningGuiAllPlayers")
    else
        global.rocket.goalReached = false
    end
end

Rocket.CustomItemPrototypeNameSet = function()
    ---@diagnostic disable: missing-fields # get_filtered_item_prototypes Factorio object definition expects too much.
    local results = game.get_filtered_item_prototypes({ { filter = "name", name = global.rocket.customItemTrackedName } })
    ---@diagnostic enable: missing-fields # get_filtered_item_prototypes Factorio object definition expects too much.
    if results ~= nil and #results == 1 then
        global.rocket.goalItemName = global.rocket.customItemTrackedName
    else
        Logging.LogPrint("Invalid custom item prototype name: '" .. tostring(global.rocket.customItemTrackedName) .. "'")
        global.rocket.goalItemName = "unknown"
    end
end

return Rocket
