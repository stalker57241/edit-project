extends VBoxContainer


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
@export
var undo_shortcut: Shortcut
@export
var redo_shortcut: Shortcut

# Called when the node enters the scene tree for the first time.
func _ready():
	var file_btn_popup: PopupMenu = %FileBtn.get_popup()
	var edit_btn_popup: PopupMenu = %EditBtn.get_popup()
	var help_btn_popup: PopupMenu = %HelpBtn.get_popup()
	
	if self.undo_shortcut != null: edit_btn_popup.set_item_shortcut(0, self.undo_shortcut, false)
	if self.redo_shortcut != null: edit_btn_popup.set_item_shortcut(1, self.redo_shortcut, false)

	file_btn_popup.id_pressed.connect(file_btn_popup_id_pressed)
	edit_btn_popup.id_pressed.connect(edit_btn_popup_id_pressed)
	help_btn_popup.id_pressed.connect(help_btn_popup_id_pressed)


func file_btn_popup_id_pressed(id: int) -> void:
	match id:
		FileBtnMenu.NEW:
			%Edit.text = ""
		FileBtnMenu.OPEN:
			pass
		FileBtnMenu.SAVE:
			pass
		FileBtnMenu.SAVE_AS:
			pass
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

	%CursorPositionText.text = "{0}/{1}".format([row, column])
