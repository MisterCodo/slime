extends Button


@export var start_focused : bool = false


func _ready():
	if(start_focused):
		grab_focus()
	
	mouse_entered.connect(_on_Button_mouse_entered)


func _on_Button_mouse_entered():
	grab_focus()
