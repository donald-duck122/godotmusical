extends RigidBody2D
signal enemyHit(damage)
signal playerHit(damage)

@export var damage = 1

func _on_life_time_timeout():
	queue_free()

func _ready():
	print("meleeing")


func _on_body_entered(body):
	if(self.is_in_group("playerProjectile") and body.is_in_group("enemy")):
		self.enemyHit.connect(body._on_bullet_enemy_hit)
		enemyHit.emit(damage)
		queue_free()
	elif(self.is_in_group("enemyProjectile") and body.is_in_group("player")):
		self.playerHit.connect(body.projectileHit)
		playerHit.emit(damage)
		queue_free()
	elif(body.is_in_group("hitable")):
		queue_free()
