# Factorio-Rocket-Target

A simple GUI that tracks rocket launches or a specific payload launched against a target number. Has a command to increase the goal to enable streaming integration support and a winning message is shown when the goal is reached.

INSERT EXAMPLE IMAGE HERE

Configurable behaviour
------------------

 - Mod settings to set the starting target value and the goal type, either rockets launched or satellites launched. A list of rockets and their contents are kept by the mod so both of these settings can be changed mid game and will having previous efforts accounted for.
 - Mod setting to set if the goal type is shown as a title or not.
 - Mod setting to set the winning GUI title and message. Both are optional and if both left blank no winning message is shown. Message GUI doesn't end game.
 
Commands
----------
All commands that take strings support spaces if the strings are wrapped in quotes. i.e. "my name"

 - Add a set number to the goal and option to record text for this increase for some future use ???.
   - syntax: rocket_target_increase_goal TARGET_INCREASE_NUMBER "TEXT"
   - example: rocket_target_increase_goal 1 "my supporter"