extends Node2D


@export var arena1:PackedScene

var player
# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().get_first_node_in_group("player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func generateMap(horizontal:int, vertical:int, minimumRooms:int, maximumRooms:int):
	var startRoom:Node2D = $mapGenerator.setMap(horizontal, vertical, minimumRooms, maximumRooms)
	player.global_position = startRoom.get_node("startPosition").global_position
	player.visible = true
