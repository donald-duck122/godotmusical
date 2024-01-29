extends CanvasLayer

var player:Node2D
var currentHealth:int
var maxHealth:int
var currentGold:int
func _ready():
	hide()
	player = get_tree().get_first_node_in_group("player")
	player.playerMaxHealthChanged.connect(updateMaxHealth.bind())
	player.playerHealthChanged.connect(updateCurrentHealth.bind())
	player.playerGoldChanged.connect(updateCurrentGold.bind())

func updateCurrentGold(newTotalGold):
	currentGold = newTotalGold
	updateGoldbar()

func updateGoldbar():
	$goldText.text = str(currentGold)
	print("updated gold")

func updateCurrentHealth(newCurrentHealth):
	currentHealth = newCurrentHealth
	updateHealthBar()
	
func updateMaxHealth(newMaxHealth):
	maxHealth = newMaxHealth
	updateCurrentHealth(newMaxHealth)
	
func updateHealthBar():
	$healthText.text = str(currentHealth) + "/" + str(maxHealth)
	print("updatedHealth")
