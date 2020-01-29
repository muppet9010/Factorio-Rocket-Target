local Constants = require("constants")

data:extend(
    {
        {
            type = "shortcut",
            name = "rocket_target-overview_toggle",
            action = "lua",
            icon = {
                filename = Constants.AssetModName .. "/graphics/gui/target-button.png",
                width = 36,
                height = 36
            },
            small_icon = {
                filename = Constants.AssetModName .. "/graphics/gui/target-button.png",
                width = 36,
                height = 36
            },
            disabled_small_icon = {
                filename = Constants.AssetModName .. "/graphics/gui/target-button-disabled.png",
                width = 36,
                height = 36
            }
        }
    }
)
