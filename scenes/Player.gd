extends KinematicBody2D

const Inventory = preload("Inventory.gd")

const DELAY_FRAME = 14
const WALK_SPEED = 400
const SPEED_FACTOR = 2
const RUN_THRESHOLD = 600
const JUMP_VELOCITY = 500
const JUMP_DELTA = 30
const JUMP_DELAY = 0.2
const FLOOR_ANGLE = 40
const MAX_FALLING_VEL = 800

var velocity = Vector2()
var cpt_frame = 0
var current_move = "rest"
var body
var crouch = false
var climb_left = false
var climb_right = false
var can_jump = true
var can_hide = false
var can_climb_left = false
var can_climb_right = false
var jumping = false
var jump_delay
var flip = false

var inventory_node

func _ready():
	body = get_node("Body")
	jump_delay = get_node("jump_delay")
	jump_delay.set_wait_time(JUMP_DELAY)
	set_process(true)
	inventory_node = get_node("Body/Inventory")

func change_player_sprite():
	var nxt_frame_delay = DELAY_FRAME
	if current_move == "run":
		nxt_frame_delay /= 2
	cpt_frame += 1
	if cpt_frame % nxt_frame_delay == 0:
		body.set_frame((cpt_frame / nxt_frame_delay) % body.get_hframes())

func fall():
	if velocity.y < MAX_FALLING_VEL:
		velocity.y += JUMP_VELOCITY / JUMP_DELTA

func move_body(delta):
	if Input.is_action_pressed("go_left"):
		flip = true
		velocity.x = -WALK_SPEED
	elif Input.is_action_pressed("go_right"):
		flip = false
		velocity.x = WALK_SPEED
	else:
		velocity.x = 0
	if Input.is_action_pressed("run"):
		velocity.x *= SPEED_FACTOR
	
	if current_move != "run" and abs(velocity.x) >= RUN_THRESHOLD:
		current_move = "run"
		body.set_texture(load("res://images/sprites/player_tuto_light/run.png"))
		body.set_hframes(8)
	elif current_move != "walk" and abs(velocity.x) > 0 and abs(velocity.x) < RUN_THRESHOLD:
		current_move = "walk"
		body.set_texture(load("res://images/sprites/player_tuto_light/walk.png"))
		body.set_hframes(8)
	elif current_move != "rest" and abs(velocity.x) == 0:
		current_move = "rest"
		body.set_texture(load("res://images/sprites/player_tuto_light/rest.png"))
		body.set_hframes(4)

	if can_jump and Input.is_action_pressed("jump"):
		can_jump = false
		jumping = true
		velocity.y -= JUMP_VELOCITY

	if not jumping and can_hide and Input.is_action_pressed("hide"):
		print("HIDDEN")

	if is_colliding():
		var n = get_collision_normal()
		if ( rad2deg(acos(n.dot( Vector2(0,-1)))) < FLOOR_ANGLE ):
			velocity.y = 0
			can_jump = true
			jumping = false
		else:
			fall()
			velocity = n.slide(velocity)
	else:
		fall()


	if jumping and can_climb_left and Input.is_action_pressed("go_left"):
		velocity = Vector2(0,-1050)
		jumping = false
		climb_left = true
	if climb_left and not Input.is_action_pressed("go_left"):
		climb_left = false
		velocity = Vector2(0,0)

	crouch = Input.is_action_pressed("hide")

	body.set_flip_h(flip)
	move(velocity * delta)

func trigger_collision():
	get_node("normal_collision").set_trigger(crouch)
	get_node("crouch_collision").set_trigger(!crouch)

func _process(delta):
	move_body(delta)
	change_player_sprite()
	trigger_collision()

func _on_jump_delay_timeout():
	if not jumping:
		can_jump = true
