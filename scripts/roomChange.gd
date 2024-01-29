extends Area2D

var mapGenNode
@export var direction:String
# Called when the node enters the scene tree for the first time.
func _ready():
	mapGenNode = get_tree().get_nodes_in_group("mapGenerator")[0]
#	direction = self.get_meta("direction")
#	print("ready " + str(self.name) + " in " + str(self.get_parent().name))
#	print(direction)



func _on_area_entered(_area):
	mapGenNode.changeRoom(direction)
#	print("enter " + str(self.name) + " in " + str(self.get_parent().name))
#	print(self.get_meta("direction"))
