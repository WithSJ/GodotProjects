extends CharacterBody3D

@onready var player_camera = $camera
@onready var visual = $visual
@onready var animplayer = $visual/man/AnimationPlayer
@onready var animTree = $visual/man/AnimationTree
@onready var headRay = $visual/Rays/Head_ray
@onready var shoulderRay = $visual/Rays/Sholder_ray
@onready var facingRay = $visual/Rays/Facing_ray
@onready var ledgeRay = $visual/Rays/Ledge_holder/Ledge_ray
@onready var ledgeMarker = $visual/Rays/Ledge_holder/MeshInstance3D
@onready var ledgeHolder = $visual/Rays/Ledge_holder

var SPEED = 1.5
const JUMP_VELOCITY = 4
var mouse_senstivety = .25
var walking_speed = 1.5
var running_speed = 3.5
var jump = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _input(event):
	if event.is_action_pressed("exit_mouse"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED		
	
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_senstivety))
		visual.rotate_y(deg_to_rad(event.relative.x * mouse_senstivety))
		player_camera.rotate_x(deg_to_rad((-event.relative.y * mouse_senstivety)))
	
func _physics_process(delta):
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	#Running
	if Input.is_action_pressed("run") and is_on_floor():
		SPEED = running_speed
	else:
		SPEED = walking_speed
	
	# Handle Jump.
#	if Input.is_action_just_pressed("jump") and is_on_floor():
#		jump_hold = Time.get_ticks_msec()
#		print(jump_hold)
	
	jump_and_climb()
	ledge_detect()
		#$CollisionShape3D.scale.y -= .500

		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		
		
		visual.look_at(position + direction)
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	#animations
	animTree.set("parameters/conditions/idle",input_dir == Vector2.ZERO)
	animTree.set("parameters/conditions/walk",input_dir != Vector2.ZERO and not Input.is_action_pressed(("run")))
	animTree.set("parameters/conditions/run",input_dir != Vector2.ZERO and SPEED == running_speed )
	#animTree.set("parameters/conditions/ready_for_jump",Input.is_action_just_pressed("jump"))
	animTree.set("parameters/conditions/jump",Input.is_action_just_pressed("jump"))
	#animTree.set("parameters/conditions/turn_right",Input.is_action_pressed("ui_right"))
	#animTree.set("parameters/conditions/turn_left",Input.is_action_pressed("ui_left"))
	#animTree.set("parameters/conditions/turn_back",Input.is_action_pressed("ui_down"))
	
	move_and_slide()


func ledge_detect():
	var hit1 = facingRay.get_collision_point()
	var hit2 = ledgeRay.get_collision_point()
	var offset = Vector3(0,2.5,0)
	if facingRay.is_colliding():
		ledgeHolder.global_transform.origin = hit1 + offset
		ledgeMarker.global_transform.origin = hit2
		print(ledgeMarker.position)
		ledgeMarker.visible = true
		ledgeRay.enabled = true
	else:
		ledgeMarker.visible = false
		ledgeRay.enabled = false
func jump_and_climb():
	if Input.is_action_just_pressed("jump") and is_on_floor():
#		print(Time.get_ticks_msec() - jump_hold) 
		velocity.y = JUMP_VELOCITY
		
		jump = true
	
	if not headRay.is_colliding() and  shoulderRay.is_colliding():
			#print("Climb")
			velocity = Vector3.ZERO
			gravity = 0
	else:
		gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
