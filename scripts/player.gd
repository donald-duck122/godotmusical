extends CharacterBody2D
signal playerHit()
signal playerGoldChanged(totalGold)
signal playerMaxHealthChanged(maxHealth)
signal playerHealthChanged(currentHealth)


@export var playerSpeed = 400
@export var maxHealth = 10
var health = maxHealth
@export var jumpForce = 10
@export var invincibleTime = 0.5

@export var bullet : PackedScene
@export var bulletSpeed = 40

@export var dashSpeed = 10
@export var dashCooldown = 2

@export var melee : PackedScene

@export var startingGold:int = 10
var currentGold = startingGold

var screenSize
var invincible = false
var jumping = false
var canShoot = false
var canDash = false
var canMelee = false
var canAttack = true
var direction = Vector2.ZERO
var gravity = 0
var playerUI:CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	#hide()
	await get_parent().is_node_ready()
	screenSize = get_viewport_rect().size
	var mapGenNode = get_tree().get_first_node_in_group("mapGenerator")
	if mapGenNode:
		mapGenNode.mapGenerationCompleted.connect(onMapLoaded.bind())
	playerUI = get_tree().get_first_node_in_group("playerUI")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	direction.x = 0
	if Input.is_action_pressed("moveRight"):
		direction.x += 1
	if Input.is_action_pressed("moveLeft"):
		direction.x -= 1
	if Input.is_action_pressed("shoot") and canShoot and canAttack:
		canShoot = false
		$shootCooldown.start()
		action(bullet, bulletSpeed)
		$attackCooldown.wait_time = 0.5
	elif Input.is_action_pressed("melee") and canMelee and canAttack:
		canMelee = false
		$meleeCooldown.start()
		$attackCooldown.wait_time = $meleeCooldown.wait_time
		action(melee, 0)
		
	if Input.is_action_pressed("dash") and canDash:
		canDash = false
		$dashCooldown.start()
		if direction.x == 0 and $AnimatedSprite2D.flip_h:
			direction.x = -1
		elif direction.x==0:
			direction.x = 1
		velocity.x = dashSpeed *1000 * direction.x
		move_and_slide()
	
	
	if direction.x != 0:
		$AnimatedSprite2D.animation = "walk"
		#assigning a boolean expression, instead of using if
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = direction.x < 0

func _physics_process(delta):
	velocity.y += gravity * delta
	# Handle Jump.
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = -jumpForce*50
	self.velocity.x = (direction.x*delta*500*playerSpeed)
	#position = position.clamp(Vector2.ZERO, screenSize)
	move_and_slide()

func projectileHit(damage):
	if invincible:
		return
	invincible = true
	health -= damage
	playerHit.emit()
	playerHealthChanged.emit(health)
	if health <= 0:
		hide()
		#used deferred to avoid problems setting it until safe
		$CollisionShape2D.set_deferred("disabled", true)
	await get_tree().create_timer(invincibleTime).timeout
	invincible = false

func _on_shoot_cooldown_timeout():
	canShoot = true

func action(projectile, speed):
	canAttack = false
	var Clone = projectile.instantiate()
	var shootPoint
	if($AnimatedSprite2D.flip_h):
		speed = -speed
		shootPoint = $shootPointL.global_position
	else:
		shootPoint = $shootPointR.global_position
	Clone.global_position = shootPoint
	Clone.linear_velocity = Vector2(speed, 0)
	Clone.add_to_group("playerProjectile")
	self.get_parent().add_child(Clone)
	await get_tree().create_timer(0.05).timeout
	$attackCooldown.start()

func _on_dash_cooldown_timeout():
	canDash = true


func _on_melee_cooldown_timeout():
	canMelee = true


func _on_attack_cooldown_timeout():
	canAttack = true

func changeGold(amount):
	print("got gold emit " + str(amount))
	currentGold += amount
	playerGoldChanged.emit(currentGold)

func changeMaxHealth(amount):
	print("got health emit " + str(amount))
	maxHealth += amount
	health = maxHealth
	playerMaxHealthChanged.emit(maxHealth)

func connectChests():
	var chestList = get_tree().get_nodes_in_group("chest")
	for chest in chestList:
		if hasSignal(chest, "playerMaxHealthChanged"):
			chest.playerMaxHealthChanged.connect(changeMaxHealth.bind())
		if hasSignal(chest, "playerGoldChanged"):
			chest.playerGoldChanged.connect(changeGold.bind())

func hasSignal(node : Node, signalName : String) -> bool:
	var signalList = node.get_signal_list()
	for signalDictionary in signalList:
		if signalDictionary.name == signalName:
			return true
	print(str(node.name) + " has no signal " + str(signalName))
	return false

func onMapLoaded():
	connectChests()
	changeGold(0)
	changeMaxHealth(0)
	playerUI.show()
	self.show()
	gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
