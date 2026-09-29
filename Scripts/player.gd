extends CharacterBody2D
class_name PlayerClass 

@export var rewind_particles: Texture2D
@export var rewind_player: Texture2D
@onready var player_sprite: AnimatedSprite2D = $PlayerSprite
@onready var player_hitbox: CollisionShape2D = $PlayerHitbox
@onready var dash_frames: Timer = $Timers/DashFrames
@onready var dash_cd: Timer = $Timers/DashCD
@onready var jump_coyote: Timer = $Timers/JumpCoyote
@onready var jump_buffer: Timer = $Timers/JumpBuffer
@onready var dash_buffer: Timer = $Timers/DashBuffer
@onready var bounce_coyote: Timer = $Timers/BounceCoyote
@onready var bounce_buffer: Timer = $Timers/BounceBuffer
@onready var get_rewind_points: Timer = $Timers/GetRewindPoints
@onready var label: Label = $CanvasLayer/Label
#@onready var timer_label: RichTextLabel = %"HUDLayer/TimerLabel"

var rewind_curve: Curve2D

const C = 550.0
const SPEED = 100.0
const JUMP_VELOCITY = -250.0
const ACCELERATION = 2500.0
const DASH_SPEED = 400.0
const GRAVITY = 980.0
const WALL_GRAVITY = GRAVITY * 0.3
const UP_GRAVITY = GRAVITY * 0.8
const PEAK_THRES = 30.0
const PEAK_GRAVITY = GRAVITY * 0.6
const MAX_FALL_SPEED = 400.0
const MAX_WALL_SPEED = MAX_FALL_SPEED * 0.4
const WALL_JUMP_PUSHOFF = 250.0
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
	
	# Get the input direction and handle the movement/deceleration.
	@warning_ignore("narrowing_conversion")
	var direction_x: int = Input.get_axis("left", "right")
	@warning_ignore("narrowing_conversion")
	var direction_y: int = Input.get_axis("up", "down")
	
	if in_rewind:
		if Engine.get_physics_frames() % 2 == 0:
			rewind_idx = clampi(rewind_idx+direction_x, 0, max_rewind_idx)
		
		queue_redraw()
		
		if Input.is_action_just_pressed("time phase"):
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
			label.text = str(level_timer)
			#timer_label.text = str(snappedf(level_timer,0.1))
			if get_rewind_points.is_stopped():
				get_rewind_point()
				
			
			if Input.is_action_just_pressed("time phase"):
				start_rewind()
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
				if abs(velocity.y) <= PEAK_THRES:
					velocity.y += PEAK_GRAVITY*delta
				elif velocity.y > 0:
					velocity.y = move_toward(velocity.y, MAX_FALL_SPEED, GRAVITY*delta)
				elif velocity.y <= 0:
					velocity.y += UP_GRAVITY*delta
		
		# Handle jump.
		
		if is_on_floor() or is_on_wall_only(): 
			can_jump = true
		elif can_jump and jump_coyote.is_stopped():
				jump_coyote.start()
			
		
		if Input.is_action_just_pressed("jump") or not jump_buffer.is_stopped():
			if can_jump:
				can_jump = false
				jump_buffer.stop()
				state = States.Jumping
				if is_on_wall_only():
					velocity.x = get_wall_normal().x * WALL_JUMP_PUSHOFF
					state = States.WallJumping
				velocity.y = JUMP_VELOCITY
			elif Input.is_action_just_pressed("jump"):
				jump_buffer.start()
		
		
		if dash_cd.is_stopped() and is_on_floor():
			can_dash = true
		
		
		if Input.is_action_just_pressed("dash") or not dash_buffer.is_stopped():
			if can_dash:
				if direction_x or direction_y:
					velocity = Vector2(direction_x, direction_y).normalized() * DASH_SPEED
					facing = direction_x
				else:
					velocity = Vector2(facing, 0).normalized() * DASH_SPEED
				state = States.Dashing
				can_dash = false
				dash_frames.start()
				dash_cd.start()
				level_timer -= DASH_PENALTY*time_scale
			elif Input.is_action_just_pressed("dash"):
				dash_buffer.start()
				
		if state == States.Dashing:
			velocity -= velocity*(dash_frames.wait_time)*0.5*delta
			
			
			
		
		if Input.is_action_pressed("jump"):
			held_jump = true
			if has_bounce_coyote:
				bouncepad(last_bounce_vec)
		elif held_jump:
			held_jump = false
			bounce_buffer.start()
		
		player_sprite.set_flip_h(facing!=1)
		
		match state:
			States.Idle: 
				player_sprite.play("Idle")
			States.Walking: 
				player_sprite.play("Walking")
			States.Dashing: 
				player_sprite.play("Dashing")
			States.Jumping: 
				player_sprite.play("Jumping")
			States.Falling: 
				player_sprite.play("Falling")
			States.WallSliding: 
				player_sprite.play("WallCling")
			States.WallJumping: 
				player_sprite.play("WallJumping")
		
		#print("state: ", state, "Velocity", velocity)
		move_and_slide()


func bouncepad(bounce_vec: Vector2):
	if held_jump or not bounce_buffer.is_stopped():
		velocity = JUMP_VELOCITY * bounce_vec * 1.5
	else:
		velocity = JUMP_VELOCITY * bounce_vec
		bounce_coyote.start()
		has_bounce_coyote = true
	last_bounce_vec = bounce_vec
	state = States.Jumping
	can_dash = true



func start_rewind():
	in_rewind = true
	max_rewind_idx = past_pos.size()-1
	past_pos.resize(max_rewind_idx)
	past_vel.resize(max_rewind_idx)
	max_rewind_idx = past_pos.size()-1
	rewind_idx = max_rewind_idx
	queue_redraw()


func _on_dash_frames_timeout() -> void:
	velocity = velocity/2
	if is_on_wall_only():
		state = States.WallSliding
	elif is_on_floor():
		state = States.Walking
	else:
		state = States.Falling
	


func _on_dash_cd_timeout() -> void:
	pass


func _draw() -> void:
	if in_rewind:
		for i in range(past_pos.size()):
			var pos = past_pos[i]
			if past_pos[rewind_idx] == pos:
				draw_texture(rewind_player, pos-position - rewind_player.get_size()/2)
			else:
				var modulate_colour = Color(1.0, 1.0, 1.0, exp(-abs(rewind_idx-i)/8))
				draw_texture(rewind_particles, pos-position - rewind_particles.get_size()/2, modulate_colour)


func _on_jump_coyote_timeout() -> void:
	can_jump = false


func _on_bounce_coyote_timeout() -> void:
	has_bounce_coyote = false


func _on_get_rewind_points_timeout() -> void:
	get_rewind_point()

	
func get_rewind_point() ->void:
	if past_pos.size() == 0 or (position - past_pos[past_pos.size()-1]).length() >= 16:
		past_pos.append(position)
		past_vel.append(velocity)
		get_rewind_points.start()
		if past_pos.size() == 1: 
			rewind_curve = Curve2D.new()
		
