extends Control

@onready var h_slider: HSlider = $VBoxContainer/HSlider

func _ready() -> void:
	var volume = ProjectSettings.get_setting("audio/volume_music", 0.5)
	h_slider.value = volume
	var new_value = linear_to_db(volume)
	AudioController.change_volume(new_value)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")

func _on_h_slider_value_changed(value: float) -> void:
	ProjectSettings.set_setting("audio/volume_music", value)
	ProjectSettings.save()
	var new_value = linear_to_db(value)
	AudioController.change_volume(new_value)
