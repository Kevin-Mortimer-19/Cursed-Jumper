class_name BaseEntity extends CharacterBody2D

signal damaged
signal healed
signal died

@export_category("Combat")
@export var max_health: int = 5
@export var cur_health: int = 5



func take_damage(amount: int) -> void:
	cur_health -= amount
	# TODO: Play sound effect of taking damage
	damaged.emit()
	
	if cur_health <= 0:
		died.emit()





