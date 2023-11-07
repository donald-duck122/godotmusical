extends Node2D


@export var arena1:PackedScene

var player
# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_node("Player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func arenaWin():
	pass

func arenaButtonPresseeed(arenaName):
	if arenaName == "arena1":
		var Clone = arena1.instantiate()
		player.reparent(Clone)
		self.add_child(Clone)
		print("boop")
		$arenaSelector.visible = false
	
