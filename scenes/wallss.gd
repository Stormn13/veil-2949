extends Node3D

@export_enum("Trimesh", "Convex") var collision_type: String = "Trimesh"

func _ready() -> void:
	_process_node(self)

func _process_node(node: Node) -> void:
	# 1. Check if this node has a 'mesh' property (common in imported MeshInstances)
	if "mesh" in node and node.mesh != null:
		_create_collision_for_mesh(node)
	
	# 2. Recursively check all children
	for child in node.get_children():
		_process_node(child)

func _create_collision_for_mesh(parent_node: Node3D) -> void:
	# Create the StaticBody (The physics object)
	var static_body = StaticBody3D.new()
	parent_node.add_child(static_body)
	
	# Create the CollisionShape (The actual 'hitbox')
	var collision_shape = CollisionShape3D.new()
	static_body.add_child(collision_shape)
	
	# Generate the specific shape from the mesh data
	var mesh_data = parent_node.mesh
	if collision_type == "Trimesh":
		collision_shape.shape = mesh_data.create_trimesh_shape()
	else:
		collision_shape.shape = mesh_data.create_convex_shape()
		
	print("Added collision to: ", parent_node.name)
