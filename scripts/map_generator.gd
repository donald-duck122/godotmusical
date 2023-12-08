extends Node2D

const roomClass = preload("res://scripts/roomClass.gd")
@export var roomSceneArray:Array[PackedScene]
@export var blankScene : PackedScene
@export var startScene : PackedScene
@export var endScene : PackedScene
var startx
var endx
var resetCount =0
var numberOfRooms = 0

var rng = RandomNumberGenerator.new()
var vertical
var horizontal   
var Map :Array
var lowestTiles = []

var totalrooms
var playerCords

# Called when the node enters the scene tree for the first time.
func setMap(horizontalLength, verticalLength, minRooms, maxRooms):
	vertical = verticalLength
	horizontal = horizontalLength
	resetMap()
	
	var possible = false
	while not possible:
		#randomly assign a start and finish room
		startx = rng.randi_range(0,horizontal-1)
		Map[startx][0].scene = startScene.instantiate()
		Map[startx][0].placed = true
		Map[startx][0].numberOfPossibleRooms = 0
		Map[startx][0].north = Map[startx][0].scene.get_meta("northPath")
		Map[startx][0].east = Map[startx][0].scene.get_meta("eastPath")
		Map[startx][0].south = Map[startx][0].scene.get_meta("southPath")
		Map[startx][0].west = Map[startx][0].scene.get_meta("westPath")
		updateNeighbours(startx,0)
		print("start x: " + str(startx))
		endx = rng.randi_range(0, horizontal-1)
#		while endx == startx or endx == startx-1 or endx == startx + 1:
#			endx = rng.randi_range(0, horizontal-1)
		Map[endx][vertical-1].scene = endScene.instantiate()
		Map[endx][vertical-1].placed = true
		Map[endx][vertical-1].numberOfPossibleRooms = 0
		Map[endx][vertical-1].north = Map[endx][vertical-1].scene.get_meta("northPath")
		Map[endx][vertical-1].east = Map[endx][vertical-1].scene.get_meta("eastPath")
		Map[endx][vertical-1].south = Map[endx][vertical-1].scene.get_meta("southPath")
		Map[endx][vertical-1].west = Map[endx][vertical-1].scene.get_meta("westPath")
		updateNeighbours(endx,vertical-1)
		print("end x: " + str(endx))
		#array for possibilities, room, and canVisit
		#repeat getting the lowest tiles until array is empty meaning no possibilities left to fill
		getLowestTiles()
		while not lowestTiles.is_empty():
			var cords = lowestTiles[rng.randi_range(0,lowestTiles.size()-1)]
			var possibleRooms=Map[cords[0]][cords[1]].possibleRooms
			var totalWeighting = 0
			for i in possibleRooms.size():
				totalWeighting = totalWeighting + possibleRooms[i].instantiate().get_meta("weighting")
			var possibilities =[]
			for i in possibleRooms.size():
				possibilities.append(possibleRooms[i].instantiate().get_meta("weighting")/totalWeighting)
			var roll = rng.randf()
			var rollTotal = 0
			for i in possibilities.size():
				rollTotal = rollTotal + possibilities[i]
				if rollTotal > roll:
					Map[cords[0]][cords[1]].scene = possibleRooms[i].instantiate()
					break
			Map[cords[0]][cords[1]].placed = true
			Map[cords[0]][cords[1]].numberOfPossibleRooms = 0
			Map[cords[0]][cords[1]].north = Map[cords[0]][cords[1]].scene.get_meta("northPath")
			Map[cords[0]][cords[1]].east = Map[cords[0]][cords[1]].scene.get_meta("eastPath")
			Map[cords[0]][cords[1]].south = Map[cords[0]][cords[1]].scene.get_meta("southPath")
			Map[cords[0]][cords[1]].west = Map[cords[0]][cords[1]].scene.get_meta("westPath")
			updateNeighbours(cords[0],cords[1])
			getLowestTiles()
		
		#once filled test if possible
		#if possible then only clone room rooms which can be visited
		#else restart process
		testPossible()
		if Map[endx][vertical-1].visited == true:
			print(str(resetCount) + "reset count")
			possible = true
		else:
			resetMap()
			resetCount = resetCount + 1
		for i in len(Map):
			for s in len(Map[i]):
				if Map[i][s].visited == true:
					numberOfRooms = numberOfRooms + 1
		if numberOfRooms > maxRooms or numberOfRooms < minRooms:
			resetMap()
			resetCount = resetCount +1
			print("Too much rooms")
			possible = false
			numberOfRooms = 0
	
	#place all possible visited maps into correct location
	for i in len(Map):
		for s in len(Map[i]):
			if Map[i][s].visited == true:
				var node = Map[i][s].scene
				self.get_parent().add_child(node)
				node.global_position = Vector2(Map[i][s].x * 1000, Map[i][s].y *-650)
	print(numberOfRooms)
	playerCords = [startx,0]
	return Vector2(Map[startx][0].x * 1000 + 500, Map[startx][0].y * -650 + 300)

func testing():
		print("testing")

func resetMap():
	totalrooms = len(roomSceneArray)
	Map.clear()
	Map.resize(horizontal)
	for i in horizontal:
		Map[i] = []
		Map[i].resize(vertical)
	for i in len(Map):
		for s in len(Map[i]):
			Map[i][s] = roomClass.new()
			Map[i][s].scene = blankScene.instantiate()
			Map[i][s].north = true
			Map[i][s].east = true
			Map[i][s].south = true
			Map[i][s].west = true
			Map[i][s].x = i
			Map[i][s].y = s
			Map[i][s].visited = false
			Map[i][s].placed = false
			Map[i][s].numberOfPossibleRooms = totalrooms

func getLowestTiles():
	#determining where to place
	#iterate through all tiles which has not been assigned and store the indexs of all tiles with the 
	#lowest value into lowestTiles
	lowestTiles.resize(0)
	var lowestValue = totalrooms
	for i in len(Map):
		for s in len(Map[i]):
			if Map[i][s].placed == true:
				continue
			if Map[i][s].numberOfPossibleRooms < lowestValue:
				lowestTiles.resize(0)
				lowestValue = Map[i][s].numberOfPossibleRooms
			if Map[i][s].numberOfPossibleRooms == lowestValue:
				lowestTiles.append([i,s])
	

func updatePossibilities(x,y):
	#using the coordinates of a tile, examine all walls/enterences around, assign the direction variables if path is 
	#possible then determine all possible next rooms based on the directons avaliable using groups
	if Map[x][y].placed == true:
		return
	var currentNorth= false
	var currentEast=false 
	var currentSouth= false
	var currentWest= false
	var blankNorth = false
	var blankEast = false
	var blankSouth = false
	var blankWest = false
	#testing north
	if y != vertical -1 and Map[x][y+1].placed == false:
		blankNorth = true
	elif y != vertical-1 and Map[x][y+1].south == true:
		currentNorth = true
	
	#testing east
	if  x != horizontal-1 and Map[x+1][y].placed == false:
		blankEast = true
	elif x != horizontal-1 and Map[x+1][y].west == true:
		currentEast = true
	
	if y != 0 and Map[x][y-1].placed == false:
		blankSouth = true  
	elif y != 0 and Map[x][y-1].north == true:
		currentSouth = true
	
	if x != 0 and Map[x-1][y].placed == false:
		blankWest = true
	elif x != 0 and Map[x-1][y].east == true:
		currentWest = true
	
	Map[x][y].possibleRooms.resize(0)
	for i in range(roomSceneArray.size()):
		var room = Node2D
		room = roomSceneArray[i].instantiate()
		if (
		(room.get_meta("northPath") == currentNorth or blankNorth) 
		and (room.get_meta("eastPath") == currentEast or blankEast) 
		and (room.get_meta("southPath") == currentSouth or blankSouth) 
		and (room.get_meta("westPath") == currentWest or blankWest)
		):
			Map[x][y].possibleRooms.append(roomSceneArray[i])
	Map[x][y].numberOfPossibleRooms = Map[x][y].possibleRooms.size()

func updateNeighbours(x,y):
	#after placing room
	#update the number of possible rooms avaliable for neighbouring tiles of tile placed by calling getpossibilities
	#on all indexs directly connect to current coordinate\
	if x != horizontal-1 and Map[x+1][y].placed == false: updatePossibilities(x+1, y)
	if x != 0 and Map[x-1][y].placed == false: updatePossibilities(x-1, y)
	if y != vertical-1 and Map[x][y+1].placed == false: updatePossibilities(x, y+1)
	if y != 0 and Map[x][y-1].placed == false: updatePossibilities(x, y-1)

func testPossible():
	#test there is a valid route from start to finish and assign boolean in array
	#if not possible then reset and try again from beginning
	#if possible
	var currentCords = [startx, 0]
	var count = horizontal * vertical * 50
	while count > 0:
		var direction = rng.randi_range(1,4)
		count = count - 1
		if direction == 1 and Map[currentCords[0]][currentCords[1]].north == true and currentCords[1] < vertical -1:
			currentCords[1] = currentCords[1] + 1
		if direction == 2 and Map[currentCords[0]][currentCords[1]].east == true and currentCords[0] < horizontal -1:
			currentCords[0] = currentCords[0] + 1
		if direction == 3 and Map[currentCords[0]][currentCords[1]].south == true and currentCords[1] > 0:
			currentCords[1] = currentCords[1] - 1
		if direction == 4 and Map[currentCords[0]][currentCords[1]].west == true and currentCords[0] >0:
			currentCords[0] = currentCords[0] - 1
		Map[currentCords[0]][currentCords[1]].visited = true

