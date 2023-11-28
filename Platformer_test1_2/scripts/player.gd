extends CharacterBody2D

@onready var anim = $AnimatedSprite2D
@onready var jump_timer = $JumpTimer
@onready var tilemap = $"../Background"

var SPEED = 300.0
const JUMP_VELOCITY = -500.0
const ACCELERATION = 2000
const FRICTION = 1000

var jump_count = 1
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()

	apply_gravity(delta)
	jump_check()
	var left_right_axis = Input.get_axis("move_left", "move_right")
	var up_down_axis = Input.get_axis("jump", "crouch")
	acceleration_check(left_right_axis, delta)
	friction_check(left_right_axis, delta)
	update_anim(left_right_axis, up_down_axis)
	var was_on_floor = is_on_floor()
	move_and_slide()
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ledge:
		jump_timer.start()
	
func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		
func jump_check():
	if is_on_floor() or jump_timer.time_left > 0.0:
		if Input.is_action_just_pressed( "jump"):
			velocity.y = JUMP_VELOCITY
	if not is_on_floor():
		if Input.is_action_just_released("jump") and velocity.y < JUMP_VELOCITY/2:
			velocity.y = JUMP_VELOCITY/2
			
func update_anim(input_axis, up_down_axis):
	if not is_crouching(up_down_axis):
		SPEED = 300
	if not is_on_floor():
		anim.play("jump")
		anim.flip_h = (input_axis < 0)
	elif is_crouching(up_down_axis) and input_axis != 0:
		SPEED = 50
		anim.play("crawl")
		anim.flip_h = (input_axis < 0)
	elif is_crouching(up_down_axis):
		drop()
		var current_frame = anim.get_frame()
		var frame_prog = anim.get_frame_progress()
		anim.play("crouch")
		anim.set_frame_and_progress(current_frame, frame_prog)
	elif input_axis != 0:
		anim.flip_h = (input_axis < 0)
		anim.play("run_right")	
	else:
		anim.play("idle")
		
func acceleration_check(input_axis, delta):
	if input_axis != 0:
		velocity.x = move_toward(velocity.x, input_axis * SPEED, ACCELERATION * delta)
		
func friction_check(input_axis, delta):
	if input_axis == 0:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	
func is_crouching(input_axis) -> bool:
	if is_on_floor() and input_axis == 1:
		return true	
	else:
		return false

func drop():
	position.y += 1
