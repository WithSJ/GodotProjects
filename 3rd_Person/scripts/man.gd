extends CharacterBody3D

@onready var player_camera = $camera
@onready var visual = $visual
@onready var animplayer = $visual/man/AnimationPlayer
var SPEED = 1.5
const JUMP_VELOCITY = 4.5
var mouse_senstivety = .25
var walking_speed = 1.5
var running_speed = 3.5
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	
	
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_senstivety))
		visual.rotate_y(deg_to_rad(event.relative.x * mouse_senstivety))
		player_camera.rotate_x(deg_to_rad((-event.relative.y * mouse_senstivety)))
func _physics_process(delta):
	if Input.is_action_pressed("exit_mouse"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	#Running
	if Input.is_action_pressed("run") and is_on_floor():
		if animplayer.current_animation != "running":
			animplayer.play("running")
		SPEED = running_speed
	else:
		if animplayer.current_animation != "walking" and is_on_floor():
			animplayer.play("walking")
		SPEED = walking_speed
	
	# Handle Jump.
	if Input.is_action_just_pressed("jump") :
		velocity.y = JUMP_VELOCITY
		print("Jump")
		if animplayer.current_animation != "jump":
			animplayer.play("jump")
		
		
		
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		
		
		visual.look_at(position + direction)
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		if animplayer.current_animation != "idle" and is_on_floor():
			animplayer.play("idle")
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
