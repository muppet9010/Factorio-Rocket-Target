local Commands = require("utility/commands")
local Interfaces = require("utility/interfaces")
local Events = require("utility/events")
local Logging = require("utility/logging")
local Rocket = {}

--[[
    rocketsLaunched = {
        tick = NUMBER,
        items = [
            itemName = STRING,
            itemCount = NUMBER
        ]
    }
]]
Rocket.CreateGlobals = function()
    global.rocket = global.rocket or {}
    global.rocket.rocketsLaunched = global.rocket.rocketsLaunched or {}
    global.rocket.startingGoal = global.rocket.startingGoal or 0
    global.rocket.goalIncrease = global.rocket.goalIncrease or 0
    global.rocket.goalTarget = global.rocket.goalTarget or 0
    global.rocket.goalProgress = global.rocket.goalProgress or 0
    global.rocket.goalIncreaseSupporters = global.rocket.goalIncreaseSupporters or {}
    global.rocket.goalItemName = global.rocket.goalItemName or ""
    global.rocket.showGoalTitleText = global.rocket.showGoalTitleText or false
    global.rocket.goalReached = global.rocket.goalReached or false
    global.rocket.winningTitle = global.rocket.winningTitle or ""
    global.rocket.winningMessage = global.rocket.winningMessage or ""
end

Rocket.OnLoad = function()
    Commands.Register("rocket_target_increase_goal", {"api-description.rocket_target_increase_goal"}, Rocket.OnCommandIncreaseGoal, true)
    Events.RegisterHandler(defines.events.on_rocket_launched, "Rocket.OnRocketLaunched", Rocket.OnRocketLaunched)
end

Rocket.Startup = function()
end

Rocket.OnSettingChanged = function(event)
    if event == nil or event.setting == "rocket_target-starting_goal" then
        global.rocket.startingGoal = tonumber(settings.global["rocket_target-starting_goal"].value)
        Rocket.UpdateGoalTarget()
    end
    if event == nil or event.setting == "rocket_target-goal_type" then
        local goalTypeString = settings.global["rocket_target-goal_type"].value
        global.rocket.goalItemName = goalTypeString
        Rocket.ResetRocketLaunchedGoalCount()
    end
    if event == nil or event.setting == "rocket_target-goal_title" then
        global.rocket.showGoalTitleText = settings.global["rocket_target-goal_title"].value
        Interfaces.Call("Gui.RecreateAllPlayers")
    end
    if event == nil or event.setting == "rocket_target-winning_title" then
        global.rocket.winningTitle = settings.global["rocket_target-winning_title"].value
    end
    if event == nil or event.setting == "rocket_target-winning_message" then
        global.rocket.winningMessage = settings.global["rocket_target-winning_message"].value
    end
end

Rocket.UpdateGoalTarget = function()
    global.rocket.goalTarget = global.rocket.startingGoal + global.rocket.goalIncrease
    Interfaces.Call("Gui.UpdateOverviewForAllPlayers")
end

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
        local id = #global.rocket.goalIncreaseSupporters + 1
        global.rocket.goalIncreaseSupporters[id] = {
            id = id,
            description = supporterName,
            done = false
        }
    end
    Rocket.UpdateGoalTarget()
end

Rocket.OnRocketLaunched = function(event)
    local rocket = event.rocket
    if rocket == nil or not rocket.valid then
        return
    end
    local rocketId = #global.rocket.rocketsLaunched + 1
    global.rocket.rocketsLaunched[rocketId] = {
        tick = rocketId,
        items = {}
    }
    for name, count in pairs(rocket.get_inventory(defines.inventory.rocket).get_contents()) do
        table.insert(
            global.rocket.rocketsLaunched[rocketId].items,
            {
                name = name,
                count = count
            }
        )
    end
    Rocket.AddRocketLaunchedGoalItems(rocketId)
    Interfaces.Call("Gui.UpdateOverviewForAllPlayers")
end

Rocket.AddRocketLaunchedGoalItems = function(rocketId)
    local done = 0
    if global.rocket.goalItemName == "rocket-silo-rocket" then
        done = 1
    else
        local items = global.rocket.rocketsLaunched[rocketId].items
        for _, item in pairs(items) do
            if item.name == global.rocket.goalItemName then
                done = done + item.count
            end
        end
    end
    global.rocket.goalProgress = global.rocket.goalProgress + done
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
    global.rocket.goalProgress = 0
    for _, supporter in pairs(global.rocket.goalIncreaseSupporters) do
        supporter.done = false
    end
    for id = 1, #global.rocket.rocketsLaunched do
        Rocket.AddRocketLaunchedGoalItems(id)
    end
    Rocket.UpdateGoalTarget()
    Interfaces.Call("Gui.RecreateAllPlayers")
end

Rocket.CheckGoalCompleted = function()
    if global.rocket.goalReached then
        return
    end
    if global.rocket.goalProgress >= global.rocket.goalTarget then
        global.rocket.goalReached = true
        Interfaces.Call("Gui.ShowWinningGuiAllPlayers")
    else
        global.rocket.goalReached = false
    end
end

return Rocket
