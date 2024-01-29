extends Node2D
signal playerMaxHealthChanged(amount)
signal playerGoldChanged(amount)

var player
func _ready():
	player = get_tree().get_first_node_in_group("player")

func onHit():
	#remember range is inclusive upper and lower
	var roll = randi_range(1,3)
	print(roll)
	match roll:
		1,2:
			changePlayerGold(10)
		3:
			changePlayerMaxHealth(1)
		_:
			print("invalid roll")

func changePlayerMaxHealth(amount:int):
	playerMaxHealthChanged.emit(amount)

func changePlayerGold(amount:int):
	playerGoldChanged.emit(amount)
