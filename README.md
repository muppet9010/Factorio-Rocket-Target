# Factorio-Rocket-Target

A simple GUI that tracks rocket launches or a specific payload launched against an optional target number. Highly configurable tracking and target goal settings. Has a command to increase the goal to enable streaming integration support

![Rocket Target](https://thumbs.gfycat.com/UglyPlumpHagfish-size_restricted.gif)

Configurable behaviour
================

 - Per player shortcut to toggle the GUI on and off with the image of a bullseye.
 - Mod settings to set the goal type; rockets launched, satellites launched, fish launched or custom item name launched in to space.
 - Mod setting to set the starting target value.
 - If the target value is 0 or less then no target value is shown in the GUI, just the number launched. This is for usage as a counter, rather than a goal.
 - Mod setting to set if the goal type is shown as a title or not. The goal type icon and number launched out of target are always shown in the GUI.
 - Mod setting to set the winning GUI title and message for when the goal is reached. Both are optional and if both left blank no winning message is shown. Message GUI doesn't end game.
 - A list of rockets and their contents are kept by the mod so all settings can be changed mid game and will having previous efforts accounted for.
 - Mod setting to set a starting completed count. For use when adding the mod to an existing save.
 - Mod setting to disable the Freeplay win message on first rocket launched. Defaults to disable this Freeplay feature as its counteractive to the point of this mod.


Commands
==============

All commands that take strings support spaces if the strings are wrapped in quotes. i.e. "my name"

Rocket target Increase Goal
-------------------

Add a set number to the goal and an optional description text for this increase for some future use maybe.

- syntax: `/rocket_target_increase_goal [TARGET_INCREASE_NUMBER] ["OPTIONAL DESCRIPTION TEXT"]`
- example: `/rocket_target_increase_goal 1 "my supporter"`

At present the goal can be set and incremented by command as either whole or decimal numbers. The goal value will be rounded down to a whole number when checked for completion and when displayed in the GUI. So value of '1.9' will be treated as '1'.