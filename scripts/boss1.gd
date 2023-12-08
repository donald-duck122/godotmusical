extends RigidBody2D
signal playerHit

@export var health = 50
@export var speed = 300
@export var connectDamage = 1

@export_category("Position markers")
@export var leftMarker: Marker2D
@export var rightMarker: Marker2D
@export var topMarker: Marker2D
@export var leftShootMarker: Marker2D
@export var rightShootMarker: Marker2D

@export_category("Disk attack")
@export var disks: PackedScene
@export var diskSpeed = 400
@export var diskCount = 5
@export var shootCooldown = 0.5

@export_category("Spike attack")
@export var spikes:PackedScene
@export var numberOfSpikes = 5
@export var spikeCooldown = 1

var player
var gap = Vector2()
var canAction = true
var canMove = true
var inPlace = false
var destination = Vector2()
var actionNumber = 2
var prevActionNumber

func _ready():
	while !player:
		player = get_parent().get_node("Player")
		await get_tree().create_timer(0.1).timeout
	canMove = true
	canAction = false

func _process(_delta):
	if global_position == destination:
		linear_velocity = Vector2.ZERO
		inPlace = true
	else:
		inPlace = false
		gap = destination - global_position
	
	$AnimatedSprite2D.flip_h = player.global_position.x > global_position.x

func _physics_process(_delta):
	if canMove:
		canMove = false
		while prevActionNumber == actionNumber:
			actionNumber = randi_range(0, 2)
		prevActionNumber = actionNumber
		print("moving")
		print(actionNumber)
		if actionNumber == 0:
			destination = leftMarker.global_position
		elif actionNumber == 1:
			destination = rightMarker.global_position
		elif actionNumber == 2:
			destination = topMarker.global_position
		gap = destination - global_position
		linear_velocity = gap.normalized() * speed
		canAction = true
		await get_tree().create_timer(0.5).timeout
		action()
	position = position.clamp(Vector2.ZERO, get_viewport_rect().size)
	if gap.abs() < Vector2(10,10) and position != destination:
		global_position = destination
		gap = Vector2.ZERO

func action():
	while !inPlace:
		await get_tree().create_timer(0.5).timeout
		pass
	if actionNumber ==0 and canAction:
		shootDisks(rightShootMarker.global_position)
	elif actionNumber == 1 and canAction:
		shootDisks(leftShootMarker.global_position)
	elif actionNumber == 2 and canAction:
		spikeAttack()

func spikeAttack():
	canAction = false
	for i in numberOfSpikes:
		var Clone = spikes.instantiate()
		Clone.global_position = Vector2(player.global_position.x, 440)
		Clone.add_to_group("enemyProjectile")
		self.get_parent().add_child(Clone)
		await get_tree().create_timer(spikeCooldown).timeout
	canMove = true

func shootDisks(shootPoint):
	print("shooting")
	var tspeed
	canAction = false
	if(!$AnimatedSprite2D.flip_h):
		tspeed = -diskSpeed
	else:
		tspeed = diskSpeed
	for i in diskCount:
		var Clone = disks.instantiate()
		Clone.global_position = shootPoint
		Clone.linear_velocity = Vector2(tspeed, 0)
		Clone.add_to_group("enemyProjectile")
		self.get_parent().add_child(Clone)
		await get_tree().create_timer(shootCooldown).timeout
	canMove = true

func _on_bullet_enemy_hit(damage):
	health -= damage
	print("boss hit" + str(health))
	if(health <= 0):
		player.reparent(get_parent())
		queue_free()


func _on_body_entered(body):
	print(body)
	if(body.is_in_group("player")):
		self.playerHit.connect(body.projectileHit)
		playerHit.emit(connectDamage)
		self.playerHit.disconnect(body.projectileHit)
