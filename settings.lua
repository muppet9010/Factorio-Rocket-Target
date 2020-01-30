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
            order = "1002"
        },
        {
            name = "rocket_target-goal_title",
            type = "bool-setting",
            default_value = false,
            setting_type = "runtime-global",
            order = "1003"
        },
        {
            name = "rocket_target-winning_title",
            type = "string-setting",
            default_value = "WINNER!",
            allow_blank = true,
            setting_type = "runtime-global",
            order = "1004"
        },
        {
            name = "rocket_target-winning_message",
            type = "string-setting",
            default_value = "Congrats you are freaking AWESOME",
            allow_blank = true,
            setting_type = "runtime-global",
            order = "1005"
        }
    }
)
