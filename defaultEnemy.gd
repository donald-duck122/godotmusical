extends CharacterBody2D

# Enemy's movement speed
@export var speed: float = 100
# Timer for how long the enemy will search for the player after losing sight
@export var lost_player_time: float = 3.0
# State
var chasing_player: bool = false
# Player reference
var player: CharacterBody2D
# PathFollow2D reference
@export var path_follow: PathFollow2D
# Timer to return to patrolling
var return_to_patrol_timer = Timer.new()
# RayCast2D for ground checking
@export var ground_checker: RayCast2D

var closest_path_point: Vector2
var gravity:float 

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().get_first_node_in_group("player")
	add_child(return_to_patrol_timer)
	return_to_patrol_timer.wait_time = lost_player_time
	return_to_patrol_timer.timeout.connect(_on_return_to_patrol_timeout.bind())
	gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	closest_path_point = path_follow.global_position

func _physics_process(delta):
	if chasing_player:
		move_towards_player(delta)
	else:
		move_along_path(delta)

func move_towards_player(delta):
	var direction_to_player = (player.global_position - global_position).normalized()
	self.velocity = direction_to_player * speed
	velocity.y += gravity * delta
	print(ground_checker.is_colliding())
	if ground_checker.is_colliding():
		move_and_slide()
	# Store the closest path point while chasing
	closest_path_point = path_follow.global_position

func move_along_path(delta):
	var direction_to_path = (closest_path_point - global_position).normalized()
	if global_position.distance_to(closest_path_point) > 10: # Threshold to start following the path
		self.velocity = direction_to_path * speed
		velocity.y += gravity * delta
		move_and_slide()
	else:
		# Follow the path normally
		path_follow.progress += speed * delta
		closest_path_point = path_follow.global_position
		global_position = closest_path_point

func _on_return_to_patrol_timeout():
	chasing_player = false


func _on_player_detector_body_entered(body):
	if body.is_in_group("player"):
		chasing_player = true
		return_to_patrol_timer.paused = true

func _on_player_detector_body_exited(body):
	if body.is_in_group("player"):
		return_to_patrol_timer.start()
		return_to_patrol_timer.paused = false
