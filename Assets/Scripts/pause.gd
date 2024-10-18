extends CanvasLayer

@onready var resume = $VBoxContainer/Resume
@onready var quit = $VBoxContainer/Quit
@onready var restart = $VBoxContainer/Restart
@onready var menu = $VBoxContainer/Menu

func _ready():
	resume.pressed.connect(_on_resume_pressed)
	quit.pressed.connect(get_tree().quit)
	restart.pressed.connect(_on_restart_pressed)
	menu.pressed.connect(_on_menu_pressed)
	hide()

func _input(event: InputEvent):
	if event.is_action_pressed("Restart"):
		_on_restart_pressed()
	if event.is_action_pressed("Pause"):
		visible = not visible
		get_tree().paused = visible
		if visible:
			AudioController.play_music()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			AudioController.stop_music()
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
func _on_resume_pressed():
	AudioController.stop_music()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	hide()
	get_tree().paused = false
	
func _on_restart_pressed():
	hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")
	
func _on_menu_pressed():
	hide()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")
