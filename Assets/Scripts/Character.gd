extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const sensitibity = 0.002

var rotation_angle = deg_to_rad(-90)
var rotation_basis = Basis().rotated(Vector3.UP, rotation_angle)
var target=null
var has_object=false
var hooked=false
var hooked_again=false
var hook_position=Vector3(0,0,0)

@onready var character_test: MeshInstance3D = $CharacterTest
@onready var head: Node3D = $Head
@onready var camera_3d: Camera3D = $Head/Camera3D
@onready var ray: RayCast3D = $Head/Camera3D/RayCast3D
@onready var marker: Marker3D = $Head/Camera3D/Marker3D
@onready var timer: Timer = $Timer

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(sensitibity*-event.relative.x)
		camera_3d.rotate_x(sensitibity*-event.relative.y)
		camera_3d.rotation.x=clamp(camera_3d.rotation.x, deg_to_rad(-70), deg_to_rad(75))
	
func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("shoot"):
		ray.enabled=true
		if hooked:
				hooked_again=true
				marker.global_transform.origin=hook_position
		else:
			if ray.is_colliding() and ray.get_collider() is StaticBody3D and not target:
				marker.global_transform.origin=ray.get_collision_point()
				hook_position=ray.get_collision_point()
				hooked=true
			if ray.is_colliding() and ray.get_collider() is RigidBody3D:
				if has_object:
					var direction=target.global_transform.origin.direction_to(marker.global_transform.origin).normalized()
					if target.global_transform.origin.distance_to(marker.global_transform.origin) < 0.2:
						target.linear_velocity=Vector3(0,0,0)
					else:
						target.linear_velocity=direction*5
				else:
					target=ray.get_collider()
					marker.global_transform.origin=target.global_position
					has_object=true
	else:
		if hooked:
			marker.global_transform.origin=hook_position
			var direction = global_transform.origin.direction_to(hook_position).normalized()
			var distance = global_transform.origin.distance_to(marker.global_transform.origin)
			velocity=direction*delta*2000
			if hooked_again:
				charge(hook_position)
				hooked_again=false
		if target:
			target=null
			has_object=false
		ray.enabled=false
	if not is_on_floor():
		velocity += get_gravity() * delta
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	var input_dir := Input.get_vector("Move_left", "Move_right", "Move_forward", "Move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction = rotation_basis*direction
	if direction:
		if not hooked or Input.is_action_pressed("shoot"):
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x += direction.x * SPEED
			velocity.z += direction.z * SPEED
				
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()
	
func charge(hook_pos: Vector3):
	timer.wait_time=global_position.distance_to(hook_pos)/20
	timer.start()
	await timer.timeout
	hooked=false
	
