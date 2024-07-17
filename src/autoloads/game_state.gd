extends Node


## Flags that indicate whether or not a certain area has been completed.
## 1 = Purification Station
## 2 = Hydroponic Gardens
## 4 = Mechanical Assembly
var area_flags: int = 0

func set_area_flag(flag: int) -> void:
	area_flags |= flag
