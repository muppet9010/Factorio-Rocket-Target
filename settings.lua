data:extend(
    {
        {
            name = "rocket_target-disable_freeplay_rocket_win",
            type = "bool-setting",
            default_value = true,
            setting_type = "startup",
            order = "1001"
        }
    }
)

data:extend(
    {
        {
            name = "rocket_target-starting_goal",
            type = "int-setting",
            default_value = 0,
            setting_type = "runtime-global",
            order = "1001"
        },
        {
            name = "rocket_target-goal_type",
            type = "string-setting",
            default_value = "satellite",
            allowed_values = {"rocket-silo-rocket", "satellite", "raw-fish", "custom"},
            setting_type = "runtime-global",
            order = "1002"
        },
        {
            name = "rocket_target-custom_item_tracked",
            type = "string-setting",
            default_value = "",
            allow_blank = true,
            setting_type = "runtime-global",
            order = "1003"
        },
        {
            name = "rocket_target-goal_title",
            type = "bool-setting",
            default_value = false,
            setting_type = "runtime-global",
            order = "1004"
        },
        {
            name = "rocket_target-starting_completed_count",
            type = "int-setting",
            default_value = 0,
            setting_type = "runtime-global",
            order = "1005"
        },
        {
            name = "rocket_target-winning_title",
            type = "string-setting",
            default_value = "WINNER!",
            allow_blank = true,
            setting_type = "runtime-global",
            order = "2001"
        },
        {
            name = "rocket_target-winning_message",
            type = "string-setting",
            default_value = "Congrats you are freaking AWESOME",
            allow_blank = true,
            setting_type = "runtime-global",
            order = "2002"
        }
    }
)
