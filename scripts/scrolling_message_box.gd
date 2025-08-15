extends PanelContainer

var font_size: int
var formatter: BBString = BBString.new("")
@onready var effects_label: RichTextLabel = %MessageEffectsLabel
@onready var message_label: RichTextLabel = %MessageLabel
@onready var scroll_label: RichTextLabel = %ScrollLabel
@onready var scroller: ScrollContainer = %MessageScroller

const default_font_size: int = 32
const default_padding_size: int = 8

func _ready() -> void:
	font_size = default_font_size
	set_message("")
	#test()


func test():
	get_tree().create_timer(3.0).timeout.connect(test)
	set_message("Huzzab")


func set_message(a_message: String):
	formatter.string = a_message
	formatter.base_string = a_message
	scroll_label.text = formatter.size(font_size).color("c4b570").center().string
	scroll()


func scroll():
	var tween: Tween = get_tree().create_tween()
	tween.finished.connect(reset_scroll)
	tween.tween_property(scroller, "scroll_vertical", 128, 0.25)


func reset_scroll():
	message_label.text = scroll_label.text
	scroller.scroll_vertical = 64
	bounce()


func bounce():
	var t_start: int = scroller.scroll_vertical
	var up_tween: Tween = get_tree().create_tween()
	up_tween.set_ease(Tween.EASE_OUT)
	up_tween.finished.connect(down_bounce.bind(t_start))
	up_tween.tween_property(scroller, "scroll_vertical", t_start + 6, 0.1)
	

func down_bounce(a_start: int):
	var down_tween: Tween = get_tree().create_tween()
	down_tween.set_ease(Tween.EASE_IN)
	down_tween.tween_property(scroller, "scroll_vertical", a_start, 0.1)
	down_tween.finished.connect(do_effect)
	
	
func do_effect():
	var t_duration: float = 1.5
	var t_scale: float = 4.0
	effects_label.visible = true
	effects_label.pivot_offset = Vector2(effects_label.size.x / 2.0, 0.0)
	#effects_label.text = formatter.clear_formatting().size(font_size).center().color("c4b570").string
	effects_label.text = message_label.text
	var tween_pos = get_tree().create_tween()
	tween_pos.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUINT)
	tween_pos.tween_property(effects_label, "position", Vector2(0.0, (-t_scale / 2.5) * effects_label.size.y), t_duration)
	var tween_scale = get_tree().create_tween()
	tween_scale.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUINT)
	tween_scale.set_ease(Tween.EASE_IN)
	tween_scale.tween_property(effects_label, 'scale', Vector2(t_scale, t_scale), t_duration)
	var tween_opacity = get_tree().create_tween()
	tween_opacity.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUINT)
	tween_opacity.tween_property(effects_label, 'modulate', Color(1.0, 1.0, 1.0, 0.0), t_duration)
	tween_opacity.finished.connect(reset_effect)


func reset_effect():
	effects_label.visible = false
	effects_label.scale = Vector2(1.0, 1.0)
	effects_label.position = Vector2.ZERO
	effects_label.modulate = Color(1.0, 1.0, 1.0, 1.0)
	
	
	
