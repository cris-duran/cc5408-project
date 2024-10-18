class_name Personaje
extends RigidBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const sensitibity = 0.002

var rotation_angle = deg_to_rad(-90)
var rotation_basis = Basis().rotated(Vector3.UP, rotation_angle)
var target=null
var has_object=false
var hooked=false
var hook_position=Vector3(0,0,0)
var mouse_input=Vector2()
var hooked_der=false
var hook_position_der=Vector3(0,0,0)
var free_pinJoint

@onready var rigid_marker = $Head/Camera3D/Rigid_marker
@onready var character_test: MeshInstance3D = $CharacterTest
@onready var head: Node3D = $Head
@onready var camera_3d: Camera3D = $Head/Camera3D
@onready var ray: RayCast3D = $Head/Camera3D/RayCast3D
@onready var marker: Marker3D = $Head/Camera3D/Marker3D
@onready var timer: Timer = $Timer
@onready var sprite_3d = $Head/Camera3D/Sprite3D
@onready var pin_joint_3d: PinJoint3D
@onready var chain = $Chain
@onready var chain_2 = $Chain2
@onready var Bounce_velocity= 600
func _ready() -> void:
	ray.enabled=true
	chain.visible=false
	chain_2.visible=false
	marker.visible=false
	rigid_marker.visible=false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _physics_process(delta: float) -> void:
	if ray.is_colliding():
		sprite_3d.modulate=Color.RED
	else:
		sprite_3d.modulate=Color.BLACK
	if Input.is_action_pressed("shoot_der"):
		if hooked_der:
			chain_2.visible=true
			rigid_marker.visible=true
			rigid_marker.global_transform.origin=hook_position_der
			chain_stretch(chain_2, global_transform.origin, rigid_marker.global_transform.origin)
			pin_joint_3d.position=hook_position_der
		else:
			if ray.is_colliding():
				sprite_3d.modulate=Color.RED
				pin_joint_3d=PinJoint3D.new()
				add_child(pin_joint_3d)
				rigid_marker.global_transform.origin=ray.get_collision_point()
				hook_position_der=ray.get_collision_point()
				pin_joint_3d.node_a=self.get_path()
				pin_joint_3d.node_b=rigid_marker.get_path()
				pin_joint_3d.position=hook_position_der
				hooked_der=true
				free_pinJoint=true
	else:
		if free_pinJoint:
			pin_joint_3d.queue_free()
			free_pinJoint=false
		hooked_der=false
		chain_2.visible=false
		rigid_marker.visible=false
	if Input.is_action_pressed("shoot"):
		if hooked:
			chain.visible=true
			marker.visible=true
			chain_stretch(chain, global_transform.origin, marker.global_transform.origin)
			marker.global_transform.origin=hook_position
		else:
			if ray.is_colliding() and ray.get_collider() is StaticBody3D and not target:
				sprite_3d.modulate=Color.RED
				marker.global_transform.origin=ray.get_collision_point()
				hook_position=ray.get_collision_point()
				hooked=true
			if ray.is_colliding() and ray.get_collider() is RigidBody3D:
				sprite_3d.modulate=Color.RED
				if has_object:
					var direction=target.global_transform.origin.direction_to(marker.global_transform.origin).normalized()
					if target.global_transform.origin.distance_to(marker.global_transform.origin) < 0.2:
						target.linear_velocity=Vector3(0,0,0)
					else:
						target.linear_velocity=direction*20
				else:
					target=ray.get_collider()
					marker.global_transform.origin=target.global_position
					has_object=true
			if has_object:
				var direction=target.global_transform.origin.direction_to(marker.global_transform.origin).normalized()
				if target.global_transform.origin.distance_to(marker.global_transform.origin) < 0.2:
					target.linear_velocity=Vector3(0,0,0)
				else:
					target.linear_velocity=direction*20
	else:
		chain.visible=false
		marker.visible=false
		if hooked:
			marker.global_transform.origin=hook_position
			var direction = (marker.global_transform.origin-global_transform.origin).normalized()
			var distance = global_transform.origin.distance_to(marker.global_transform.origin)
			apply_central_impulse(direction*distance*3)
			hooked=false
		if target:
			target=null
			has_object=false
	camera_3d.rotation_degrees.x-=mouse_input.y*delta*10.0
	camera_3d.rotation_degrees.x=clamp(camera_3d.rotation_degrees.x, -80,80)
	rotation_degrees.y-=mouse_input.x*delta*10.0
	mouse_input=Vector2.ZERO
	
func _input(event):
	if event is InputEventMouseMotion:
		mouse_input=event.relative
	if event.is_action_pressed("Restart"):
		get_tree().change_scene_to_file("res://Scenes/Main.tscn")
		
func chain_stretch(object: MeshInstance3D, origin: Vector3, marker: Vector3):
	var distance=origin.distance_to(marker)
	var middle=origin.lerp(marker,0.5)
	var direction=(origin-marker).normalized()
	object.scale=Vector3(0.05,0.05,distance)
	object.look_at(marker, Vector3.UP)
	object.global_transform.origin=middle





func _on_animatable_body_3d_enemy_killed() -> void:
	linear_velocity.y=Bounce_velocity
	print("JIJIJA")
