extends MarginContainer

var coin_text = "x"

@export_group("Node References")
@export var health_bar: TextureProgressBar
@export var coin_label: Label
@export var coin_count_button: Button
@export var interact_tip: Label

@export var curse_icon_1: TextureRect
@export var curse_icon_2: TextureRect


func _ready():
	EventBus.display_interact_tip.connect(toggle_interact_visibility)
	interact_tip.modulate.a = 0


func set_up_healthbar(player: Player) -> void:
	player.healed.connect(_on_player_health_changed.bind(player))
	player.damaged.connect(_on_player_health_changed.bind(player))


func _on_player_health_changed(player: Player) -> void:
	health_bar.value = player.cur_health


func refresh_curse_UI(icon_1: Array, icon_2: Array) -> void:
	curse_icon_1.texture = icon_1[0]
	curse_icon_1.tooltip_text = icon_1[1]
	curse_icon_2.texture = icon_2[0]
	curse_icon_2.tooltip_text = icon_2[1]


func update_coin_tracker(amount: int):
	coin_label.text = coin_text + str(amount)
	coin_count_button.text = "%s" % amount


func toggle_interact_visibility(make_visible: bool) -> void:
	var tween:= create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	
	if make_visible:
		tween.tween_property(interact_tip, "modulate:a", 1, 0.4)
	else:
		tween.tween_property(interact_tip, "modulate:a", 0, 0.4)
		
	tween.play()

