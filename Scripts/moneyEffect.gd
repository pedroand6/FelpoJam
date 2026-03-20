@tool
extends RichTextEffect
class_name ScrollTextEffect

var bbcode := "scroll_effect"
var linear_coeff := 0.0
var delta_time := 0.0
var time := 0.0
var reset_times := 0
var run_effect := false

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	if not run_effect: return true
	
	delta_time = char_fx.elapsed_time - time
	var _text_server := TextServerManager.get_primary_interface()
	
	var scroll = -linear_coeff * 50.0
	
	char_fx.color = Color(0.0, 0.639, 0.0, 1.0)
	
	var glyph := ord("R$ +++++++++"[char_fx.range.x % 12])
	char_fx.glyph_index = _text_server.font_get_glyph_index(char_fx.font, 1, glyph, 0)
	char_fx.offset.y += scroll
	
	if char_fx.offset.y < 1e-3 and reset_times >= 1:
		run_effect = false
		reset_times = 0
		time = 0
		delta_time = 0
		linear_coeff = 0
		char_fx.offset.y = 0
		return true
	
	if char_fx.offset.y < -40.0:
		char_fx.offset.y += 120.0
		linear_coeff = -2.0
		reset_times += 1
		
	linear_coeff += delta_time
	time = char_fx.elapsed_time
	
	return true
