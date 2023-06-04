class_name Syntax extends Resource


@export var delimiters: String = "\n\t\\/.,*+-="
@export var highlighter: CodeHighlighter
@export var single_line_comment_char: String = "#"
@export var multiline_comment_char_pair: DoubleSidedCharacterPairs = null
@export var keywords: Array[StringName] = []
@export var doublesided_characters: Array[DoubleSidedCharacterPairs] = []

func get_left_sides() -> Array[String]:
	var left_sides: Array[String] = []
	
	for chr in doublesided_characters:
		left_sides.append(chr.left_side)
	
	return left_sides

func get_right_sides() -> Array[String]:
	var right_sides: Array[String] = []
	
	for chr in doublesided_characters:
		right_sides.append(chr.right_side)
	
	return right_sides

func get_right_side(left_side: String) -> String:
	for chr in doublesided_characters:
		if chr.left_side == left_side:
			return chr.right_side
	return ""

func pairs_to_dict() -> Dictionary:
	var d: Dictionary = {}
	
	for ds_char in doublesided_characters:
		d[ds_char.left_side] = ds_char.right_side
	return d

func add_color_regions():
	if highlighter == null:
		highlighter = CodeHighlighter.new()
	highlighter.add_color_region(single_line_comment_char, "", Color.RED, true)
