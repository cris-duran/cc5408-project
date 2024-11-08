class_name Enemy
extends StaticBody3D


signal enemy_killed()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func death():
	pass



func _on_area_3d_body_entered(body):
	if body is Personaje:
		enemy_killed.emit()
		queue_free()
	pass # Replace with function body.
