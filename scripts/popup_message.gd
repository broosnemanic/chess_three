extends PopupPanel

var message_label: RichTextLabel

func _ready() -> void:
	message_label = %PopupMessageLabel
	message_label.bbcode_enabled = true
	

func set_text(a_text: String):
	message_label.text = a_text
