class_name roomClass
extends Node

@export var scene : Node2D
@export var north : bool
@export var east : bool
@export var south : bool
@export var west :bool
var x:int
var y:int
var visited:bool
var possibleRooms : Array[PackedScene]
var numberOfPossibleRooms:int
var placed : bool
var roomID: int

func _init():
	north = false
	east = false
	south = false
	west = false
