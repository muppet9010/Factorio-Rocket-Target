# Factorio-Rocket-Target

A simple GUI that tracks rocket launches or a specific payload launched against an optional target number. Highly configurable tracking and target goal settings. Has a command to increase the goal to enable streaming integration support

![Rocket Target](https://thumbs.gfycat.com/UglyPlumpHagfish-size_restricted.gif)

Functionality
=============

 - Supports different goal types; rockets launched, satellites launched, fish launched or custom item name launched in to space.
 - GUI shows the goal type icon, number launched and the optional target if set. Mod setting to control if a title for the goal type is shown or not (great for streamers).
 - Per player shortcut to toggle the GUI on and off with the image of a bullseye.
 - A list of rockets and their contents are kept by the mod so all settings can be changed mid game and it will review previous rocket launches to see how many were done. Can only review launches done while the mod was active; for launches done before that there is a mod setting to set a previously launched number.
 - Configurable starting target value via mod setting. If the target value is 0 or less then no target number is shown in the GUI, just the number launched. Command can be used by streamers to increase the goal target, see the Commands section.
 - Mod setting to set the winning GUI title and message for when the goal is reached. Both are optional and if both left blank no winning message is shown. Message GUI doesn't end game.
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