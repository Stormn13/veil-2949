extends CharacterBody3D

const SPEED = 3.0
const JUMP_VELOCITY = 2.0
const MOUSE_SENSTIVITY = 0.002
const RAY_LENGTH = 1

#get gravity
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
#camera as child node referecnce 
@onready var camera = $Camera3D
@onready var tv = $"../old tv"
func _ready() -> void:
	#roblox shift lock
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	var space_state = get_world_3d().direct_space_state
	var mousepos = get_viewport().get_mouse_position()
	#gravity
	if not is_on_floor():
		velocity.y -= gravity *delta
	#jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	#input direction
	var input_var = Input.get_vector("move_right", "move_left", "move_forward", "move_backward")
	#transform from local space to global space 
	var direction = (transform.basis * Vector3(input_var.x, 0, input_var.y)).normalized()
	#apply movement
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()
	#intract check
	if Input.is_action_just_pressed("intract"):
		pickup(space_state, mousepos)
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENSTIVITY)
		camera.rotate_x(-event.relative.y * MOUSE_SENSTIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))


func pickup(space_state, mousepos):
	var origin = camera.project_ray_origin(mousepos)
	var end = origin + camera.project_ray_normal(mousepos) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true
	var results = space_state.intersect_ray(query)
	print(results)
	if results == {}:
		pass
	elif results.collider == tv.get_child(0):
		tv.hide()
