extends Node


## Flags that indicate whether or not a certain area has been completed.
## 1 = Purification Station
## 2 = Hydroponic Gardens
## 4 = Mechanical Assembly
var area_flags: int = 0

## Flags for which ending the player has chosen after reaching the Overseer
## 1 = The player sided with the shotgun
## 2 = The player sided with the Overseer
var ending_flags: int = 0

var dialogue_unpause_override = false

signal end_game


func set_area_flag(flag: int) -> void:
	area_flags |= flag


func set_ending_flag(flag: int) -> void:
	ending_flags |= flag
