@tool
extends RichTextEffect
class_name JumpTextEffect

var bbcode := "jump_effect"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var text_server := TextServerManager.get_primary_interface()
	
	var fall = clamp(pow((char_fx.elapsed_time - char_fx.range.x / 40.0), 2.0) * 50.0 - 3, -3, 0)
	char_fx.offset.y = fall
	return true
	
