extends Node2D

@onready var bg_music: AudioStreamPlayer = $bg_music
var is_playing = false

func play_music():
	if is_playing == false:
		bg_music.play()
		is_playing = true
	
func stop_music():
	bg_music.stop()
	is_playing = false

func change_volume(value):
	bg_music.volume_db = value
