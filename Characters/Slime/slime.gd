extends CharacterBody2D

@export var MAX_SPEED : float = 100
@export var ACCELERATION : float = 500
@export var FRICTION : float = 1000

@onready var animation_tree = $AnimationTree
@onready var animation_state = animation_tree.get("parameters/playback")

func _ready():
	pass
	
func _physics_process(delta):
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if input_direction == Vector2.ZERO:
		# player is not pressing any moving key
		animation_state.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	else:
		# player is pressing keys to move
		animation_state.travel("Walk")
		animation_tree.set("parameters/Idle/blend_position", input_direction)
		animation_tree.set("parameters/Walk/blend_position", input_direction)
		velocity = velocity.move_toward(input_direction * MAX_SPEED, ACCELERATION * delta)
		
	set_velocity(velocity)
	move_and_slide()
	
