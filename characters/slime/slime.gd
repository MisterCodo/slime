extends CharacterBody2D


enum SlimeClass {
	NORMAL,
	RADIOACTIVE
}


@export var MAX_SPEED : float = 120
@export var ACCELERATION : float = 700
@export var FRICTION : float = 1000


var slime_class = SlimeClass.NORMAL
var texture_normal = preload("res://assets/slime.png")
var texture_radioactive = preload("res://assets/slime_radioactive.png")


@onready var sprite2d_texture = $Sprite2d
@onready var animation_tree = $AnimationTree
@onready var animation_state = animation_tree.get("parameters/playback")


func _physics_process(delta):
	# Look for change slime class action
	if Input.is_action_just_pressed("change_slime_class"):
		match slime_class:
			SlimeClass.NORMAL:
				slime_class = SlimeClass.RADIOACTIVE
				sprite2d_texture.set_texture(texture_radioactive)
			SlimeClass.RADIOACTIVE:
				slime_class = SlimeClass.NORMAL
				sprite2d_texture.set_texture(texture_normal)
		
	# Move slime based on input direction
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if input_direction == Vector2.ZERO:
		# Player is not pressing any moving key
		animation_state.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	else:
		# Player is pressing keys to move
		animation_state.travel("Walk")
		animation_tree.set("parameters/Idle/blend_position", input_direction)
		animation_tree.set("parameters/Walk/blend_position", input_direction)
		velocity = velocity.move_toward(input_direction * MAX_SPEED, ACCELERATION * delta)
		
	set_velocity(velocity)
	move_and_slide()
