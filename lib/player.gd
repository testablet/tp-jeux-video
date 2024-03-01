extends CharacterBody3D

@onready var camera:Camera3D = $Camera

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
#const ANIM_WALK = "player/walking"
#const ANIM_IDLE = "player/standing_idle"

const mouse_sensitivity:float = 0.002
const max_camera_angle_up:float = deg_to_rad(0)
const max_camera_angle_down:float = -deg_to_rad(30)

var mouse_captured:bool = false
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	capture_mouse()
	
func _unhandled_input(event):
	if event is InputEventMouseMotion and mouse_captured:
		if is_instance_valid(camera):
			rotate_y(-event.relative.x * mouse_sensitivity)
			camera.rotate_x(event.relative.y * mouse_sensitivity)
			camera.rotation.x = clampf(camera.rotation.x, max_camera_angle_down, max_camera_angle_up)
	if (event is InputEventKey) and Input.is_action_just_pressed("cancel"):
		release_mouse()


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("player_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if mouse_captured:
		var joypad_dir: Vector2 = Input.get_vector("player_look_left", "player_look_right", "player_look_up", "player_look_down")
		if joypad_dir.length() > 0:
			var look_dir = joypad_dir * delta
			rotate_y(-look_dir.x * 2.0)
			camera.rotate_x(-look_dir.y)
			camera.rotation.x = clamp(camera.rotation.x - look_dir.y,  max_camera_angle_down, max_camera_angle_up)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("player_right", "player_left", "player_backward", "player_forward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false
