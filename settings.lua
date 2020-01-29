data:extend(
    {
        {
            name = "rocket_target-starting_goal",
            type = "int-setting",
            default_value = 100,
            setting_type = "runtime-global",
            order = "1001"
        },
        {
            name = "rocket_target-goal_type",
            type = "string-setting",
            default_value = "rocket-silo-rocket",
            allowed_values = {"rocket-silo-rocket", "satellite"},
            setting_type = "runtime-global",
            order = "1001"
        }
    }
)
