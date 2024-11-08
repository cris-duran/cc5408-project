extends RigidBody3D

var hooked=false
var back_hook=false
@onready var character_body_3d: RigidBody3D = $".."
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	contact_monitor=true
	max_contacts_reported=1

func _process(delta: float) -> void:
	if back_hook:
		hooked=false
		top_level=false
		var direction=global_transform.origin.direction_to(character_body_3d.global_transform.origin).normalized()
		linear_velocity=direction*50
	if global_transform.origin.distance_to(character_body_3d.global_transform.origin)>15 and not back_hook:
		sleeping=true
		sleeping=false
		back_hook=true
	if global_transform.origin.distance_to(character_body_3d.global_transform.origin)<1 and back_hook:
		visible=false
		sleeping=true
		back_hook=false
	if get_contact_count()>0:
		hooked=true
		back_hook=true
		max_contacts_reported=0
