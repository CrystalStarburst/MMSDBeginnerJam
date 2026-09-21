extends CharacterBody2D
class_name PlayerClass 

@export var rewind_particles: Texture2D
@export var rewind_player: Texture2D
@onready var player_sprite: AnimatedSprite2D = $PlayerSprite
@onready var player_hitbox: CollisionShape2D = $PlayerHitbox
@onready var dash_cd: Timer = $DashCD
@onready var dash_frames: Timer = $DashFrames
@onready var timer_label: RichTextLabel = %"HUDLayer/TimerLabel"

const C = 550.0
const SPEED = 200.0
const JUMP_VELOCITY = -300.0
const ACCELERATION = 2500.0
const DASH_SPEED = 500.0
const GRAVITY = 980.0
const MAX_FALL_SPEED = 400.0
const WALL_JUMP_PUSHOFF = 300.0
const DASH_PENALTY = 3

var level_timer: float
var gamma: float = (1-(velocity.length()/C)**2)**0.5

var dashing: bool = false
var can_dash: bool = true
var facing: int = 1
var can_jump: bool = false

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
		
		if not is_on_floor() and not dashing:
			velocity.y = move_toward(velocity.y, MAX_FALL_SPEED, GRAVITY*delta)
		
		if not dashing and not state == States.WallJumping:
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
				state = States.WallSliding
		
		# Handle jump.
		
		if is_on_floor() or is_on_wall_only(): 
			can_jump = true
		
		if Input.is_action_just_pressed("jump") and can_jump:
			can_jump = false
			if is_on_wall_only():
				velocity.x = get_wall_normal().x * WALL_JUMP_PUSHOFF
			velocity.y = JUMP_VELOCITY

		
		if Input.is_action_just_pressed("dash") and can_dash:
			velocity = Vector2(direction_x, direction_y).normalized() * DASH_SPEED
			facing = direction_x
			state = States.Dashing
			dashing = true
			can_dash = false
			dash_frames.start()
			dash_cd.start()
			level_timer -= DASH_PENALTY
			
			
		
		player_sprite.set_flip_h(facing!=1)
		
		
		
		#print((1-(velocity.length()/C)**2)**0.5)
		#print("state: ", state, "Velocity", velocity)
		move_and_slide()





func _on_dash_frames_timeout() -> void:
	velocity = velocity/4
	dashing = false
	


func _on_dash_cd_timeout() -> void:
	can_dash = true


func _draw() -> void:
	if in_rewind:
		for pos in past_pos:
			if past_pos[rewind_idx] == pos:
				draw_texture(rewind_player, pos-position)
			else:
				draw_texture(rewind_particles, pos-position)
