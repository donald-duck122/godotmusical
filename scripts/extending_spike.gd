extends Area2D
signal enemyHit(damage)
signal playerHit(damage)

@export var damage = 1
@export var hiddenTime = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	$mediumCollider.disabled = true
	$extendedCollider.disabled = true
	await get_tree().create_timer(hiddenTime).timeout
	$lifeTime.start()
	$AnimatedSprite2D.play("default")

func _process(_delta):
	if $AnimatedSprite2D.frame == 1:
		$mediumCollider.disabled = false
	if $AnimatedSprite2D.frame == 2:
		$mediumCollider.disabled = true
		$extendedCollider.disabled = false

func attack(body):
	if(body.is_in_group("player")):
		self.playerHit.connect(body.projectileHit)
		playerHit.emit(damage)
		self.playerHit.disconnect(body.projectileHit)


func _on_life_time_timeout():
	queue_free()
