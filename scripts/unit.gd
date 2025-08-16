extends Control

var movement: bool = false
var shooting: bool = false
var charge: bool = false
var team: bool
var selectedTeam: bool

func checkNeighbours(model, visited: Array):
    for i in model.neighbours:
        if i not in visited:
            visited.append(i)
            checkNeighbours(i, visited)

func _draw() -> void:
    var reqCount: bool = true
    var singleModel: bool = false
    for model in get_children():
        var currPos = model.position
        
        #variable of check whether each model has the right amount
        #of neighbours
        var allModels: Array = get_children()
        var requiredNeighbours: int = 0
        if len(allModels) >= 7:
            requiredNeighbours = 2
        elif len(allModels) > 1:
            requiredNeighbours = 1
        else:
            singleModel = true
        model.neighbours = []
        for otherModel in allModels:
            var dist = currPos.distance_to(otherModel.position)
            if (dist != 0) and (dist < (globals.inchesToPixels(2) + model.radius)):
                model.neighbours.append(otherModel)
                draw_line(model.position, otherModel.position, Color.WHITE)
        if len(model.neighbours) < requiredNeighbours:
            reqCount = false
             
        var currCheck: Array = []
        checkNeighbours(allModels[0], currCheck)
        var inRange: bool = len(currCheck) == len(allModels)     
        
        if team:
            for i in allModels:
                i.get_node('Sprite2D').modulate = Color.GHOST_WHITE
        else:
            for i in allModels:
                i.get_node('Sprite2D').modulate = Color.DARK_SLATE_GRAY
        
    
        if (inRange and reqCount) or singleModel:
            for i in allModels:
                i.get_node('Boarder').modulate = Color.LIME_GREEN
        else:
            for i in allModels:
                i.get_node('Boarder').modulate = Color.ORANGE_RED
        
                
func _process(_float) -> void:
    var thing = 0
    queue_redraw()
        
func update_selectedTeam(index: bool) -> void:
    selectedTeam = index
        
