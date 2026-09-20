extends CharacterBody2D

@onready var player_sprite: AnimatedSprite2D = $PlayerSprite
@onready var player_hitbox: CollisionShape2D = $PlayerHitbox


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const ACCELERATION = 500.0

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
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	@warning_ignore("narrowing_conversion")
	var direction: int = Input.get_axis("left", "right")
	if direction:
		velocity.x = move_toward(velocity.x, SPEED*direction, ACCELERATION)
		facing = direction
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if is_on_floor() and states != Dashing:
	
	player_sprite.set_flip_h(facing!=1)
		
	
	move_and_slide()
