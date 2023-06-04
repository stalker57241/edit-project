extends VBoxContainer

var text_changed: bool = false:
	set(value):
		text_changed = value
		update_title()

var current_file: String:
	set(value):
		current_file = value
		update_title()
func update_title():
		if current_file != "":
			get_tree().root.title = "EditProject [{filename}{is_changed}]".format({
				"filename": current_file.get_file(),
				"is_changed": "*" if text_changed else ""
			})
			print("is_changed: ", text_changed)
			%Edit.placeholder_text = ""
		else:
			get_tree().root.title = "EditProject"
			%Edit.placeholder_text = "
>> Enter some text for beginning"

enum FileBtnMenu {
	NEW = 0,
	OPEN = 1,
	SAVE = 3,
	SAVE_AS = 4,
	EXIT = 6,
}

enum EditBtnMenu {
	UNDO = 0,
	REDO = 1,
}
enum HelpBtnMenu {
	AUTHORS = 0
}
@export_category("MainScene")
@export_group("syntax_data")
@export var syntax: Syntax
@export_group("Shortcuts")
@export var new_shortcut: Shortcut
@export var open_shortcut: Shortcut
@export var save_shortcut: Shortcut
@export var save_as_shortcut: Shortcut
@export var exit_shortcut: Shortcut

@export var undo_shortcut: Shortcut
@export var redo_shortcut: Shortcut

func _ready():
	
	var args = OS.get_cmdline_user_args()

	if args.size() > 0:
		var fname = args[args.size() - 1]

		current_file = fname
		open_file()

	update_syntax()

#	%Edit.syntax_highlighter = syntax.highlighter

	var file_btn_popup: PopupMenu = %FileBtn.get_popup()
	var edit_btn_popup: PopupMenu = %EditBtn.get_popup()
	var help_btn_popup: PopupMenu = %HelpBtn.get_popup()

	if self.new_shortcut != null: file_btn_popup.set_item_shortcut(0, self.new_shortcut, false)
	if self.open_shortcut != null: file_btn_popup.set_item_shortcut(1, self.open_shortcut, false)
	if self.save_shortcut != null: file_btn_popup.set_item_shortcut(3, self.save_shortcut, false)
	if self.save_as_shortcut != null: file_btn_popup.set_item_shortcut(4, self.save_as_shortcut, false)
	if self.exit_shortcut != null: file_btn_popup.set_item_shortcut(6, self.exit_shortcut, true)
	
	if self.undo_shortcut != null: edit_btn_popup.set_item_shortcut(0, self.undo_shortcut, false)
	if self.redo_shortcut != null: edit_btn_popup.set_item_shortcut(1, self.redo_shortcut, false)

	file_btn_popup.id_pressed.connect(file_btn_popup_id_pressed)
	edit_btn_popup.id_pressed.connect(edit_btn_popup_id_pressed)
	help_btn_popup.id_pressed.connect(help_btn_popup_id_pressed)

func update_syntax():
	%Edit.syntax_highlighter = syntax.highlighter
	%Edit.auto_brace_completion_pairs = syntax.pairs_to_dict()
	%Edit.code_completion_enabled = true
	%Edit.code_completion_prefixes = syntax.keywords
	
	%Edit.add_code_completion_option(
		CodeEdit.KIND_CLASS,
		"cls",
		"class"
	)
	%Edit.update_code_completion_options(false)
	
	syntax.add_color_regions()
#	%Edit.add_code_completion_option(
#		CodeEdit.KIND_PLAIN_TEXT, "class", "class"
#	)
	if syntax.single_line_comment_char != "":
		%Edit.add_comment_delimiter(
			syntax.single_line_comment_char,
			syntax.single_line_comment_char,
			true
		)
	if syntax.multiline_comment_char_pair != null:
		%Edit.add_comment_delimiter(
			syntax.multiline_comment_char_pair.left_side,
			syntax.multiline_comment_char_pair.right_side,
			false
		)
	
func handle_unicode_input(unicode_char: int, caret_index: int):
	if %Edit.get_selected_text(0) != "":
		print("selected")
	if char(unicode_char) in syntax.get_left_sides():
		if %Edit.get_selected_text(0) != "":
			%Edit.insert_text_at_caret("{open}{text}{close}".format({
				"open": char(unicode_char),
				"text": %Edit.get_selected_text(0),
				"close": syntax.get_right_side(char(unicode_char))
			}), 0)
		else:
			%Edit.insert_text_at_caret(char(unicode_char))
			var col = %Edit.get_caret_column()
			
			%Edit.insert_text_at_caret(syntax.get_right_side(char(unicode_char)), 0)
			%Edit.set_caret_column(col, true, 0)
	else:
		if char(unicode_char) in syntax.get_right_sides():
			%Edit.set_caret_column(%Edit.get_caret_column(0) + 1, true, 0)
		else:
			%Edit.insert_text_at_caret(char(unicode_char), caret_index)


func file_btn_popup_id_pressed(id: int) -> void:
	match id:
		FileBtnMenu.NEW:
			current_file = ""
			%Edit.text = ""
			text_changed = false
		FileBtnMenu.OPEN:
			$OpenFile.popup_centered()
			text_changed = false
		FileBtnMenu.SAVE:
			if current_file == "":
				$SaveFile.popup_centered()
			else:
				save_file()
			text_changed = false
		FileBtnMenu.SAVE_AS:
			$SaveFile.popup_centered()
		FileBtnMenu.EXIT:
			get_tree().quit(0)

func edit_btn_popup_id_pressed(id: int) -> void:
	match id:
		EditBtnMenu.UNDO:
			if %Edit.has_undo(): %Edit.undo()

		EditBtnMenu.REDO:
			if %Edit.has_redo(): %Edit.redo()

func help_btn_popup_id_pressed(id: int) -> void:
	match id:
		HelpBtnMenu.AUTHORS:
			pass

func _on_edit_caret_changed():
	var row = %Edit.get_caret_line(0)
	var column = %Edit.get_caret_column(0)
	%CursorPositionText.text = "{row}/{column}".format({
		"row": row,
		"column": column
	})


func _on_open_file_file_selected(path: String):
	current_file = path
	get_tree().root.title = "EditProject [{filename}]".format({
		"filename": current_file.get_file()
	})
	text_changed = false
	open_file()

func open_file():
	var fa: FileAccess = FileAccess.open(current_file, FileAccess.READ)
	
	%Edit.text = fa.get_as_text()

	fa.close()

func save_file():
	var fa: FileAccess = FileAccess.open(current_file, FileAccess.WRITE)
	fa.store_string(%Edit.text)
	fa.close()
	text_changed = false

func _on_save_file_file_selected(path: String):
	current_file = path
	save_file()


func _on_edit_text_changed():
	text_changed = true
	if current_file != "":
		current_file = current_file
