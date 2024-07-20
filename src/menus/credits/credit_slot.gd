@tool
class_name CreditSlot extends HBoxContainer

signal meta_clicked(meta)

@export var persons_name: String : set = _set_person_name
@export_multiline var role_details: String :
	set(val):
		role_details = val
		if label_roles:
			label_roles.text = val

@export var embed_url: bool = false :
	set(value):
		embed_url = value
		notify_property_list_changed()

@export var url_to_embed: String = ""

@export_group("Node References")
@export var label_name: RichTextLabel
@export var label_roles: Label

func _validate_property(property: Dictionary):
	if property.name == "url_to_embed" and not embed_url:
		property.usage = PROPERTY_HINT_NONE

func _ready() -> void:
	if not Engine.is_editor_hint() and OS.get_name() != "Web":
		add_to_group("credit_slots")
		label_name.meta_clicked.connect(_on_label_meta_clicked)
		_set_person_name(persons_name)

func _on_label_meta_clicked(meta) -> void:
	meta_clicked.emit(meta)

func _set_person_name(value: String) -> void:
	persons_name = value
	if label_name:
		if not embed_url:
			label_name.text = "[center][b][i]%s[/i][/b][/center]" % value
		elif embed_url and url_to_embed:
			label_name.text = "[url=%s][center][b][i]%s[/i][/b][/center][/url]" % [url_to_embed, value]








