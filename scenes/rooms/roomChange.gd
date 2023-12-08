extends Area2D

var mapGenNode
# Called when the node enters the scene tree for the first time.
func _ready():
	mapGenNode = get_tree().get_nodes_in_group("mapGenerator")
	print("map gen")
	print(true if mapGenNode else false)



func _on_area_entered(area):
	mapGenNode.changeRoom("north")
