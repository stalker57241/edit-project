extends VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_edit_caret_changed():
	var row = %Edit.get_caret_line(0)
	var column = %Edit.get_caret_column(0)

	%CursorPositionText.text = "{0}/{1}".format([row, column])
