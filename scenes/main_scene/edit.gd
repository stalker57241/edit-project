extends CodeEdit


func _handle_unicode_input(unicode_char: int, caret_index: int):
	get_parent().handle_unicode_input(unicode_char, caret_index)

