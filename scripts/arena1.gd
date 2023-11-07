extends Node2D

@export var mobScene: PackedScene
var score
var player


# Called when the node enters the scene tree for the first time.
func _ready():
	while !player:
		player = get_node("Player")
		await get_tree().create_timer(0.1).timeout
	player.start($StartPosition.global_position)

func gameOver():
	$HUD.showGameOver()
	$music.stop()
	$deathSound.play()

func newGame():
	score = 0
	$Player.show()
	$Player.position = $StartPosition.position
	$HUD.updateScore(score)
	$HUD.showMessage("Get Ready")
	#gets all the objects in the mob group and activates the function 
	#queue_free which places them in a queue to be deleted when possible
	get_tree().call_group("mobs", "queue_free")
	
	#Music code!
	$music.play()


func _on_mob_timer_timeout():
	var mobClone = mobScene.instantiate()
	
	#choose a random loccation on path2d
	var mobSpawnLocation = get_node("MobPath/MobSpawnLocation")
	mobSpawnLocation.progress_ratio = randf()
	var direction = mobSpawnLocation.rotation + PI/2
	mobClone.position = mobSpawnLocation.position
	
	#sets clone movement direction
	direction += randf_range(-PI/4, PI/4)
	mobClone.rotation = direction
	
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	mobClone.linear_velocity = velocity.rotated(direction)
	
	mobClone.add_to_group("enemy")
	#spawns the mob by adding to the main scene
	add_child(mobClone)
