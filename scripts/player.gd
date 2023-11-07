extends CharacterBody2D
signal playerHit(currentHealth)

@export var playerSpeed = 400
@export var health = 10
@export var jumpForce = 10
@export var invincibleTime = 0.5

@export var bullet : PackedScene
@export var bulletSpeed = 40

@export var dashSpeed = 10
@export var dashCooldown = 2

var screenSize
var invincible = false
var jumping = false
var canShoot = false
var canDash = false
var direction = Vector2.ZERO
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


# Called when the node enters the scene tree for the first time.
func _ready():
	screenSize = get_viewport_rect().size
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	direction.x = 0
	if Input.is_action_pressed("moveRight"):
		direction.x += 1
	if Input.is_action_pressed("moveLeft"):
		direction.x -= 1
	if Input.is_action_pressed("shoot") and canShoot:
		canShoot = false
		$shootCooldown.start()
		action(bullet, bulletSpeed)
	if Input.is_action_pressed("dash") and canDash:
		canDash = false
		$dashCooldown.start()
		velocity.x = dashSpeed *100 * direction.x
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
	position = position.clamp(Vector2.ZERO, screenSize)
	move_and_slide()

func projectileHit(damage):
	if invincible:
		return
	invincible = true
	health -= damage
	playerHit.emit(health)
	print("player hit" + str(health))
	if health <= 0:
		hide()
		#used deferred to avoid problems setting it until safe
		$CollisionShape2D.set_deferred("disabled", true)
	await get_tree().create_timer(invincibleTime).timeout
	invincible = false

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false


func _on_shoot_cooldown_timeout():
	canShoot = true

func action(projectile, speed):
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


func _on_dash_cooldown_timeout():
	canDash = true
