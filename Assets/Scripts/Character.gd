extends RigidBody3D

signal player_death()

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const sensitibity = 0.002
const SIDE_IMPULSE = 2.0

var rotation_angle = deg_to_rad(-90)
var rotation_basis = Basis().rotated(Vector3.UP, rotation_angle)
var target=null
var has_object=false
var hook_position=Vector3(0,0,0)
var mouse_input=Vector2()
var hooked_der=false
var hook_position_der=Vector3(0,0,0)
var free_pinJoint

var hook_in_air=false

var chain_len=3


@export var chain_mesh: Mesh
@export var chain_cell_scene: PackedScene

@onready var chain_general_target: Marker3D = $Head/Camera3D/Chain_General_Target
@onready var rigid_marker = $Head/Camera3D/Rigid_marker
@onready var character_test: MeshInstance3D = $CharacterTest
@onready var head: Node3D = $Head
@onready var camera_3d: Camera3D = $Head/Camera3D
@onready var ray: RayCast3D = $Head/Camera3D/RayCast3D
@onready var sprite_3d = $Head/Camera3D/Sprite3D
@onready var pin_joint_3d: PinJoint3D
@onready var chain = $Chain
@onready var chain_2 = $Chain2

@onready var Bounce_velocity= 15
@onready var raycast_down: RayCast3D = $RayCastDown



@onready var left_chain: RigidBody3D = $Left_Chain
@onready var left_chain_target: MeshInstance3D = $Head/Camera3D/Left_Chain_Target
@onready var left_chain_childs: Node3D = $Left_Chain/Left_Chain_Childs




@onready var too_low = -100


func _ready() -> void:
	ray.enabled=true
	chain.visible=false
	chain_2.visible=false
	rigid_marker.visible=false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	raycast_down.enabled = false
	await get_tree().create_timer(0.01).timeout
	raycast_down.enabled = true
	
func _physics_process(delta: float) -> void:

	if is_in_air():
		hook_in_air = true
	elif !is_in_air():
		hook_in_air = false


	# Indica si la cadena llega o nó a la pared

	if position.y < too_low or null:
		player_death.emit()
		queue_free()

	if ray.is_colliding():
		sprite_3d.modulate=Color.RED
	else:
		sprite_3d.modulate=Color.BLACK
		
	if Input.is_action_pressed("Shoot_R"):
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


	# Maneja el impulso cuando la cadena izquierda se engancha a una pared
	if left_chain.hooked and not has_object:
		left_chain.back_hook=true
		var direction = (left_chain.global_transform.origin-global_transform.origin).normalized()
		var distance = global_transform.origin.distance_to(left_chain.global_transform.origin)
		apply_central_impulse(direction*distance*3)
		left_chain.hooked=false
	
	# Maneja el movimiento del objeto cuando la cadena izquierda se angancha a uno
	if has_object:
		var direction=target.global_transform.origin.direction_to(left_chain_target.global_transform.origin).normalized()
		if target.global_transform.origin.distance_to(left_chain_target.global_transform.origin) < 0.2:
			target.linear_velocity=Vector3(0,0,0)
		else:
			target.linear_velocity=direction*20
			
	# Destruye y reconstruye la cadena
	chain_len=global_transform.origin.distance_to(left_chain.global_transform.origin)
	var cell_num=roundf(chain_len/3)+1
	for child in left_chain_childs.get_children():
		child.queue_free()  
	for num in range(cell_num):
		var chain_cell_instance=chain_cell_scene.instantiate()
		left_chain_childs.add_child(chain_cell_instance)
		var distance=global_transform.origin.distance_to(left_chain.global_transform.origin)
		var direction=(left_chain.global_transform.origin-global_transform.origin).normalized()
		chain_cell_instance.global_transform.origin=global_transform.origin+direction*(num+1)
		chain_cell_instance.look_at(left_chain.global_transform.origin, Vector3.UP)
		
	# Lanzador del gancho izquierdo, el que atrae
	if Input.is_action_just_pressed("Shoot_L"):
		left_chain.visible=true
		left_chain_target.global_transform.origin=chain_general_target.global_transform.origin
		left_chain.global_transform.origin=global_transform.origin
		left_chain.back_hook=false
		left_chain.sleeping=true
		left_chain.sleeping=false
		left_chain.apply_central_impulse((global_transform.origin-left_chain_target.global_transform.origin).normalized()*-50)
		left_chain.max_contacts_reported=1
		#left_chain.sleeping=false
		#left_chain.back_hook=false
		#left_chain.top_level=true
		#if ray.is_colliding() and ray.get_collider() is StaticBody3D and not has_object:
			#left_chain_target.global_transform.origin=ray.get_collision_point()
			#left_chain.global_transform.origin=global_transform.origin
			#left_chain.collision_shape_3d.disabled=false
			#left_chain.sleeping=true
			#left_chain.sleeping=false
			#left_chain.apply_central_impulse((global_transform.origin-left_chain_target.global_transform.origin).normalized()*-50)
			#left_chain.max_contacts_reported=1
		#if ray.is_colliding() and ray.get_collider() is RigidBody3D:
			#if has_object:
				#target=null
				#has_object=false
			#else:
				#target=ray.get_collider()
				#left_chain_target.global_transform.origin=target.global_transform.origin
				#has_object=true
		#if not ray.is_colliding():
			#if has_object:
				#target=null
				#has_object=false
			#else:
				#left_chain_target.global_transform.origin=chain_general_target.global_transform.origin
				#left_chain.global_transform.origin=global_transform.origin
				#left_chain.collision_shape_3d.disabled=false
				#left_chain.sleeping=true
				#left_chain.sleeping=false
				#left_chain.apply_central_impulse((global_transform.origin-left_chain_target.global_transform.origin).normalized()*-50)
				#left_chain.max_contacts_reported=1
				
	camera_3d.rotation_degrees.x-=mouse_input.y*delta*10.0
	camera_3d.rotation_degrees.x=clamp(camera_3d.rotation_degrees.x, -80,80)
	rotation_degrees.y-=mouse_input.x*delta*10.0
	mouse_input=Vector2.ZERO
	
	if hook_in_air:
		if Input.is_action_just_pressed("Move_left"):
			print("Impulso Izquierda detectado")
			apply_side_impulse(Vector3(-SIDE_IMPULSE, 0, 0))
		elif Input.is_action_just_pressed("Move_right"):
			print("Impulso Derecha detectado")
			apply_side_impulse(Vector3(SIDE_IMPULSE, 0, 0))
	
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





func apply_side_impulse(velocity: Vector3):
	linear_velocity += velocity

func is_in_air() -> bool:
	return not raycast_down.is_colliding()


func _on_enemy_1_enemy_killed() -> void:
	var direction=Vector3.UP
	apply_central_impulse(direction*2)
	pass # Replace with function body.
