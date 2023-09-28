@tool
class_name panel3d
extends StaticBody3D
#extends RigidBody3D
@onready var viewport : SubViewport = %SubViewport
@onready var mesh : MeshInstance3D = $panel
@onready var colShape : CollisionShape3D = $CollisionShape3D
@onready var label_3d = $Label3D
var ui : Node
var hoverevent : InputEventMouseMotion
var clickevent : InputEventMouseButton
#var clickevent : InputEventScreenTouch
var hovered : bool = false
var clicked : bool = false
var tex:ViewportTexture

var is_panel_3d:bool = true

#now accepts packed scene was resources
@export var _auto_load_ui : PackedScene
@export var transparent : bool = true
@export var appear_in_local_uis : bool = false
@export var lock_global_position: bool = false

signal action(data:Dictionary)

func _ready():
	mesh.mesh.material.albedo_texture = viewport.get_texture()
	if lock_global_position:
		axis_lock_angular_x = true
		axis_lock_angular_y = true
		axis_lock_angular_z = true
		axis_lock_linear_x = true
		axis_lock_linear_y = true
		axis_lock_linear_z = true
	if transparent and OS.get_name() != "Android" and OS.get_name() != 'Web':
		viewport.transparent_bg = true
	else:
		viewport.transparent_bg = false
	viewport.gui_focus_changed.connect(func(node):
		LocalGlobals.player_state = LocalGlobals.PLAYER_STATE_TYPING
		)
	LocalGlobals.playerreleaseuifocus.connect(func():
		viewport.gui_release_focus()
		)
#	colShape.position.y = -colShape.shape.size.y/2.0
	if _auto_load_ui:
		set_ui(_auto_load_ui.instantiate())

func _process(delta):
	colShape.shape.size = Vector3(mesh.mesh.size.x,.01,mesh.mesh.size.y)

func laserClick(data:Dictionary):
	clickevent = InputEventMouseButton.new()
#	clickevent = InputEventScreenTouch.new()
	clickevent.pressed = data.pressed
#	clickevent.index = 0
	clickevent.button_index = 1
#	clickevent.button_mask = 1
	# Get mesh size to detect edges and make conversions. This code only support PlaneMesh and QuadMesh.
	var quad_mesh_size = mesh.mesh.size
	var mouse_pos3D = to_local(data.position)
	# convert the relative event position from 3D to 2D
	var mouse_pos2D = Vector2(mouse_pos3D.x, mouse_pos3D.z)
	# Right now the event position's range is the following: (-quad_size/2) -> (quad_size/2)
	# We need to convert it into the following range: 0 -> quad_size
	mouse_pos2D.x += quad_mesh_size.x / 2
	mouse_pos2D.y += quad_mesh_size.y / 2
	# Then we need to convert it into the following range: 0 -> 1
	mouse_pos2D.x = mouse_pos2D.x / quad_mesh_size.x
	mouse_pos2D.y = mouse_pos2D.y / quad_mesh_size.y
	# Finally, we convert the position to the following range: 0 -> viewport.size
	mouse_pos2D.x = mouse_pos2D.x * viewport.size.x
	mouse_pos2D.y = mouse_pos2D.y * viewport.size.y
	# We need to do these conversions so the event's position is in the viewport's coordinate system.
	# Set the event's position and global position.
	clickevent.position = mouse_pos2D
#	clickevent.global_position = mouse_pos2D
	clicked = true
	viewport.handle_input_locally = true
	viewport.call_thread_safe('push_input',clickevent,true)
	viewport.handle_input_locally = false
	clickevent = InputEventMouseButton.new()
#	clickevent = InputEventScreenTouch.new()
	clicked = false

func laserInput(data:Dictionary):
	var event = InputEventMouseButton.new()
	event.pressed = data.pressed
	if data.action == "scrollup":
		event.button_index = 4
	elif data.action == "scrolldown":
		event.button_index = 5
#	event.button_mask = 1
	# Get mesh size to detect edges and make conversions. This code only support PlaneMesh and QuadMesh.
	var quad_mesh_size = mesh.mesh.size
	var mouse_pos3D = to_local(data.position)
	# convert the relative event position from 3D to 2D
	var mouse_pos2D = Vector2(mouse_pos3D.x, mouse_pos3D.z)
	# Right now the event position's range is the following: (-quad_size/2) -> (quad_size/2)
	# We need to convert it into the following range: 0 -> quad_size
	mouse_pos2D.x += quad_mesh_size.x / 2
	mouse_pos2D.y += quad_mesh_size.y / 2
	# Then we need to convert it into the following range: 0 -> 1
	mouse_pos2D.x = mouse_pos2D.x / quad_mesh_size.x
	mouse_pos2D.y = mouse_pos2D.y / quad_mesh_size.y
	# Finally, we convert the position to the following range: 0 -> viewport.size
	mouse_pos2D.x = mouse_pos2D.x * viewport.size.x
	mouse_pos2D.y = mouse_pos2D.y * viewport.size.y
	# We need to do these conversions so the event's position is in the viewport's coordinate system.
	# Set the event's position and global position.
	event.position = mouse_pos2D
#	event.global_position = mouse_pos2D
	viewport.handle_input_locally = true
	viewport.call_thread_safe("push_input",event,true)
	viewport.handle_input_locally = false

func laserHover(data:Dictionary):
	if !hovered and !clicked and data.has("position"):
		# We need to fabricate a fake mouse input even for translating a raycast click to a simulated mouse click on the viewport.
		hoverevent = InputEventMouseMotion.new()
	#	event.pressed = data.pressed
	#	event.button_index = 1
	#	event.button_mask = 1
		var quad_mesh_size = mesh.mesh.size
		var mouse_pos3D = to_local(data.position)
		var mouse_pos2D = Vector2(mouse_pos3D.x, mouse_pos3D.z)
		mouse_pos2D.x += quad_mesh_size.x / 2
		mouse_pos2D.y += quad_mesh_size.y / 2
		mouse_pos2D.x = mouse_pos2D.x / quad_mesh_size.x
		mouse_pos2D.y = mouse_pos2D.y / quad_mesh_size.y
		mouse_pos2D.x = mouse_pos2D.x * viewport.size.x
		mouse_pos2D.y = mouse_pos2D.y * viewport.size.y
		hoverevent.position = mouse_pos2D
		hoverevent.global_position = mouse_pos2D
		hovered = true
		viewport.handle_input_locally = true
		viewport.call_thread_safe('push_input',hoverevent,true)
		viewport.handle_input_locally = false
		hovered = false

#func _input(event):
#	print(event)
#	viewport.push_input(event)

func set_ui(node):
	viewport.add_child(node)
	ui = node
	tex = viewport.get_texture()
	if appear_in_local_uis:
		LocalGlobals.local_uis.append({
			'name':name,
			'viewport_texture': tex
		})
	if node.has_signal('action'):
		node.action.connect(func(data):
			emit_signal('action',data)
			)
	mesh.mesh.surface_get_material(0).albedo_texture = tex
#	node.gui_input.connect(func(event):
#		label_3d.text = str(event)
#		)
