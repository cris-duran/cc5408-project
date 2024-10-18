extends Control


func _ready() -> void:
	AudioController.play_music()

func _on_play_pressed() -> void:
	AudioController.stop_music()
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")


func _on_options_pressed() -> void:
	AudioController.stop_music()
	get_tree().change_scene_to_file("res://Scenes/options.tscn")


func _on_credits_pressed() -> void:
	pass # Replace with function body.


func _on_quit_pressed() -> void:
	get_tree().quit()
