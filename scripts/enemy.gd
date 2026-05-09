extends CharacterBody3D

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var current_state = State.ROAMING
enum State { ROAMING, AGRO, SEMIAGRO }
#raycasting variables
const RAY_LENGTH = 100
@onready var raycast = $RayCast3D

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_path"):
		var random_position := Vector3.ZERO
		random_position.z = randf_range(-30.0, 30.0)
		random_position.x = randf_range(-30.0, 30.0)
		navigation_agent_3d.set_target_position(random_position)


func _physics_process(delta: float) -> void:
	#logic to see the player
	var target = raycast.get_collider()
	if (target == $"../CharacterBody3D") and (current_state == State.ROAMING):
		current_state = State.AGRO
	if (target != $"../CharacterBody3D") and (current_state == State.AGRO):
		current_state = State.SEMIAGRO
		await get_tree().create_timer(2.0).timeout
		if (target != $"../CharacterBody3D") and (current_state == State.SEMIAGRO):
			current_state = State.ROAMING
		if (target == $"../CharacterBody3D") and (current_state == State.SEMIAGRO):
			current_state = State.AGRO
	#logic to choose the correct state
	match current_state:
		State.ROAMING:
			roaming()
		State.AGRO:
			agro()
		State.SEMIAGRO:
			semiagro()
	
	var destination = navigation_agent_3d.get_next_path_position()
	var local_destination = destination - global_position
	var direction = local_destination.normalized()
	
	velocity = direction * 5.0
	move_and_slide()


#functions of states(roaming, agro, semiagro)
func roaming():
	print("roaming")
	
func agro():
	print("agro")
		
func semiagro():
	print("semiagro")
