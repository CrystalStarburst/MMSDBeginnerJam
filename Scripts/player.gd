extends CharacterBody2D
class_name PlayerClass 

@export var rewind_particles: Texture2D
@export var rewind_player: Texture2D
@onready var player_sprite: AnimatedSprite2D = $PlayerSprite
@onready var player_hitbox: CollisionShape2D = $PlayerHitbox
@onready var dash_cd: Timer = $DashCD
@onready var dash_frames: Timer = $DashFrames
@onready var jump_coyote: Timer = $JumpCoyote
@onready var jump_buffer: Timer = $JumpBuffer
@onready var dash_buffer: Timer = $DashBuffer
@onready var bounce_coyote: Timer = $BounceCoyote
@onready var bounce_buffer: Timer = $BounceBuffer
@onready var timer_label: RichTextLabel = %"HUDLayer/TimerLabel"

const C = 550.0
const SPEED = 200.0
const JUMP_VELOCITY = -300.0
const ACCELERATION = 2500.0
const DASH_SPEED = 500.0
const GRAVITY = 980.0
const WALL_GRAVITY = GRAVITY * 0.4
const MAX_FALL_SPEED = 400.0
const MAX_WALL_SPEED = MAX_FALL_SPEED * 0.4
const WALL_JUMP_PUSHOFF = 300.0
const DASH_PENALTY = 3

var level_timer: float
var time_scale: float = 1
var gamma: float = (1-(velocity.length()/C)**2)**0.5

var dashing: bool = false
var can_dash: bool = true
var facing: int = 1
var can_jump: bool = false
var held_jump: bool = false

var has_jump_buffer: bool = false
var has_jump_coyote: bool = false
var has_dash_coyote: bool = false
var has_bounce_coyote: bool = false
var has_bounce_buffer: bool = false
var last_bounce_vec: Vector2 

var past_pos: PackedVector2Array
var past_vel: PackedVector2Array
var past_states: Array

var level_started: bool = false
var in_rewind: bool = false
var rewind_idx: int 
var max_rewind_idx: int

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
	#gamma = (1-(velocity.length()/C)**2)**0.5
	#Engine.time_scale = max(gamma, 0.01)
	#delta = delta/gamma
	
	# Get the input direction and handle the movement/deceleration.
	@warning_ignore("narrowing_conversion")
	var direction_x: int = Input.get_axis("left", "right")
	@warning_ignore("narrowing_conversion")
	var direction_y: int = Input.get_axis("up", "down")
	
	
	if in_rewind:
		rewind_idx = clampi(rewind_idx+direction_x, 0, max_rewind_idx)
		
		queue_redraw()
		
		if Input.is_action_just_pressed("rewind"):
			in_rewind = false
			position = past_pos[rewind_idx]
			velocity = past_vel[rewind_idx]
			past_pos.resize(rewind_idx)
			past_vel.resize(rewind_idx)
			queue_redraw()
			pass
		
	else:
		if level_started:
			level_timer -= delta
			timer_label.text = str(snappedf(level_timer,0.1))
			if  Engine.get_process_frames() % 3 == 0:
				past_pos.append(position)
				past_vel.append(velocity)
			
			if Input.is_action_just_pressed("rewind"):
				in_rewind = true
				max_rewind_idx = past_pos.size()-1
				rewind_idx = max_rewind_idx
				queue_redraw()
				pass
		
		
		if not state in [States.Dashing]:
			if direction_x:
				velocity.x = move_toward(velocity.x, SPEED*direction_x, ACCELERATION*delta)
				facing = direction_x
				
			else: 
				velocity.x = move_toward(velocity.x, 0, ACCELERATION*delta)
			if is_on_floor():
				if direction_x :
					state = States.Walking
				else:
					state = States.Idle
			elif is_on_wall_only():
				if velocity.y >= 0:
					state = States.WallSliding
			else:
				if velocity.y >= 0:
					state = States.Falling
		
		if not is_on_floor() and not dashing:
			if state == States.WallSliding:
				velocity.y = move_toward(velocity.y, MAX_WALL_SPEED, WALL_GRAVITY*delta)
			else:
				velocity.y = move_toward(velocity.y, MAX_FALL_SPEED, GRAVITY*delta)
		
		# Handle jump.
		
		if is_on_floor() or is_on_wall_only(): 
			can_jump = true
		elif can_jump and jump_coyote.is_stopped():
				jump_coyote.start()
			
		
		if Input.is_action_just_pressed("jump") or not jump_buffer.is_stopped():
			if can_jump:
				can_jump = false
				jump_buffer.stop()
				if is_on_wall_only():
					velocity.x = get_wall_normal().x * WALL_JUMP_PUSHOFF
				velocity.y = JUMP_VELOCITY
				state = States.Jumping
			elif Input.is_action_just_pressed("jump"):
				jump_buffer.start()

		
		if Input.is_action_just_pressed("dash") or not dash_buffer.is_stopped():
			if can_dash:
				velocity = Vector2(direction_x, direction_y).normalized() * DASH_SPEED
				facing = direction_x
				state = States.Dashing
				can_dash = false
				dash_frames.start()
				dash_cd.start()
				level_timer -= DASH_PENALTY*time_scale
			elif Input.is_action_just_pressed("dash"):
				dash_buffer.start()
			
		if Input.is_action_pressed("jump"):
			held_jump = true
			if has_bounce_coyote:
				bouncepad(last_bounce_vec)
		elif held_jump:
			held_jump = false
			bounce_buffer.start()
		print(held_jump)
		
		player_sprite.set_flip_h(facing!=1)
		
		
		
		#print((1-(velocity.length()/C)**2)**0.5)
		#print("state: ", state, "Velocity", velocity)
		move_and_slide()


func bouncepad(bounce_vec: Vector2):
	if held_jump or not bounce_buffer.is_stopped():
		velocity = JUMP_VELOCITY * bounce_vec * 2
	else:
		velocity = JUMP_VELOCITY * bounce_vec
		bounce_coyote.start()
		has_bounce_coyote = true
	last_bounce_vec = bounce_vec


func _on_dash_frames_timeout() -> void:
	velocity = velocity/2
	if is_on_wall_only():
		state = States.WallSliding
	elif is_on_floor():
		state = States.Walking
	else:
		state = States.Falling
	


func _on_dash_cd_timeout() -> void:
	can_dash = true


func _draw() -> void:
	if in_rewind:
		for pos in past_pos:
			if past_pos[rewind_idx] == pos:
				draw_texture(rewind_player, pos-position)
			else:
				draw_texture(rewind_particles, pos-position)


func _on_jump_coyote_timeout() -> void:
	can_jump = false


func _on_bounce_coyote_timeout() -> void:
	has_bounce_coyote = false
