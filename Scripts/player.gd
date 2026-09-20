extends CharacterBody2D

@onready var player_sprite: AnimatedSprite2D = $PlayerSprite
@onready var player_hitbox: CollisionShape2D = $PlayerHitbox
@onready var dash_cd: Timer = $DashCD
@onready var dash_frames: Timer = $DashFrames


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const ACCELERATION = 500.0
const DASH_SPEED = 500.0

var dashing: bool = false
var can_dash: bool = false
var facing: int = 1

enum States {
	Idle, 
	Walking,
	Dashing, 
	Jumping, 
	Falling,
	WallSliding, 
	WallJumping
}

var state: States = States.Idle

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor() and not dashing:
		velocity += get_gravity() * delta


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	@warning_ignore("narrowing_conversion")
	var direction_x: int = Input.get_axis("left", "right")
	@warning_ignore("narrowing_conversion")
	var direction_y: int = Input.get_axis("up", "down")
	
	if not dashing and not state == States.WallJumping:
		if direction_x:
			velocity.x = move_toward(velocity.x, SPEED*direction_x, ACCELERATION)
			facing = direction_x
			
		else: 
			velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor():
			if direction_x :
				state = States.Walking
			else:
				state = States.Idle
		elif is_on_wall_only():
			state = States.WallSliding
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	
	if Input.is_action_just_pressed("dash"):
		velocity = Vector2(direction_x, direction_y).normalized() * DASH_SPEED
		facing = direction_x
		state = States.Dashing
		dashing = true
		dash_frames.start()
		dash_cd.start()
		
		
	
	player_sprite.set_flip_h(facing!=1)
		
	print("state: ", state, "Velocity", velocity)
	move_and_slide()


func _on_dash_frames_timeout() -> void:
	velocity = velocity/2
	dashing = false
	


func _on_dash_cd_timeout() -> void:
	can_dash = true
