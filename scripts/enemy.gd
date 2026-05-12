extends CharacterBody3D

@onready var player = $"../CharacterBody3D"
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var current_state = State.ROAMING
enum State { ROAMING, AGRO, SEMIAGRO }
#raycasting variables
const RAY_LENGTH = 100
@onready var raycast = $RayCast3D

var roaming_active:bool

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
			if !roaming_active:
				roaming()
		State.AGRO:
			agro()
		State.SEMIAGRO:
			semiagro()
	# program to move the cat where is is supposed to
	var destination = navigation_agent_3d.get_next_path_position()
	var local_destination = destination - global_position
	var direction = local_destination.normalized()
	
	velocity = direction * 5.0
	move_and_slide()


#functions of states(roaming, agro, semiagro)
func roaming():
	roaming_active = true
	#step one wait for a random time
	var random_time = randi_range(1,2)
	await get_tree().create_timer(random_time).timeout
	#step two get random positon for the enemy to travel to
	var random_pos := Vector3.ZERO
	random_pos.x = randf_range(-2.4, 1.4)
	random_pos.y = global_position.y
	random_pos.z = randf_range(-5.5, -0.1)
	navigation_agent_3d.set_target_position(random_pos)
	#check if the roaming is done only then go start it again
	while !navigation_agent_3d.is_navigation_finished():
		await get_tree().physics_frame
	roaming_active = false
func agro():
	print("agro")
	navigation_agent_3d.set_target_position(player.global_position)
		
func semiagro():
	print("semiagro")
