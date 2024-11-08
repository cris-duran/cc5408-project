extends CanvasLayer

@onready var retry = %Retry
@onready var back_to_menu =%"back to menu"
@onready var exit = %exit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_retry_pressed() -> void:
	get_tree().paused =false
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")
	pass # Replace with function body.


func _on_back_to_menu_pressed() -> void:
	get_tree().paused =false
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")
	pass # Replace with function body.



func _on_exit_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.

func _on_character_body_3d_player_win() -> void:
	get_tree().paused
	visible = not visible
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	pass # Replace with function body.
