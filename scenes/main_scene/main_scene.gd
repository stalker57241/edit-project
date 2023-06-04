extends VBoxContainer


var current_file: String:
	set(value):
		current_file = value
		if value != "":
			get_tree().root.title = "EditProject [{filename}]".format({
				"filename": current_file.get_file()
			})
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

@export var new_shortcut: Shortcut
@export var open_shortcut: Shortcut
@export var save_shortcut: Shortcut
@export var save_as_shortcut: Shortcut
@export var exit_shortcut: Shortcut

@export var undo_shortcut: Shortcut
@export var redo_shortcut: Shortcut

func _ready():
	# TODO: Write cmdargs reading for open last arg file


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


func file_btn_popup_id_pressed(id: int) -> void:
	match id:
		FileBtnMenu.NEW:
			current_file = ""
			%Edit.text = ""
		FileBtnMenu.OPEN:
			$OpenFile.popup_centered()
		FileBtnMenu.SAVE:
			if current_file == "":
				$SaveFile.popup_centered()
			else:
				save_file()
		FileBtnMenu.SAVE_AS:
			$SaveFile.popup_centered()
		FileBtnMenu.EXIT:
			get_tree().quit(0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
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
	%CursorPositionText.text = "{row}/{column}".format(
		{
			"row": row,
			"column": column
		}
	)


func _on_open_file_file_selected(path: String):
	current_file = path
	get_tree().root.title = "EditProject [{filename}]".format({
		"filename": current_file.get_file()
	})
	open_file()

func open_file():
	var fa: FileAccess = FileAccess.open(current_file, FileAccess.READ)
	
	%Edit.text = fa.get_as_text()

	fa.close()

func save_file():
	var fa: FileAccess = FileAccess.open(current_file, FileAccess.WRITE)
	fa.store_string(%Edit.text)
	fa.close()


func _on_save_file_file_selected(path: String):
	current_file = path
	save_file()
