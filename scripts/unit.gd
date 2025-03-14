extends Control

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
        
        if (inRange and reqCount) or singleModel:
            for i in allModels:
                i.get_node('Sprite2D').modulate = Color(0,1,0)
        else:
            for i in allModels:
                i.get_node('Sprite2D').modulate = Color(1,0,0)
                
 
func _process(_float) -> void:
    queue_redraw()
        
                
        
