extends Node2D

@export var mobScene: PackedScene
var score


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func gameOver():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.showGameOver()
	$music.stop()
	$deathSound.play()

func newGame():
	score = 0
	$Player.show()
	$Player.position = $StartPosition.position
	$StartTimer.start()
	$HUD.updateScore(score)
	$HUD.showMessage("Get Ready")
	#gets all the objects in the mob group and activates the function 
	#queue_free which places them in a queue to be deleted when possible
	get_tree().call_group("mobs", "queue_free")
	
	#Music code!
	$music.play()
	


func _on_score_timer_timeout():
	score += 1
	$HUD.updateScore(score)



func _on_start_timer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()


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
