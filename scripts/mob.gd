extends RigidBody2D

@export var minSpeed = 150
@export var maxSpeed = 250
@export var health = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	#returns a array of all animation names
	var mobTypes = $AnimatedSprite2D.sprite_frames.get_animation_names()
	#randomly picks between a integer of 0 to mobTypes.size()
	$AnimatedSprite2D.play(mobTypes[randi()% mobTypes.size()])

#signal from the visableOnScreenNotifier child
func onVisableScreenExited():
	#function to delete node
	queue_free()



func _on_bullet_enemy_hit(damage):
	health -= damage
	if(health <= 0):
		queue_free()
