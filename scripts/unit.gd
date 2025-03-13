extends Control

func checkNeighbours(model, visited: Array):
    for i in model.neighbours:
        if i not in visited:
            visited.append(i)
            checkNeighbours(i, visited)
    
func _draw() -> void:
    for model in get_children():
        var currPos = model.position
        var target: Vector2
        var neighbours = []
        model.neighbours = []
        for otherModel in get_children():
            var dist = currPos.distance_to(otherModel.position)
            if (dist != 0) and (dist < globals.inchesToPixels(2)):
                model.neighbours.append(otherModel)
                draw_line(model.position, otherModel.position, Color.WHITE)
                
        var allModels: Array = get_children()
        var currCheck: Array = []
        checkNeighbours(allModels[0], currCheck)
        if len(currCheck) == len(allModels):
            for i in allModels:
                i.get_node('Sprite2D').modulate = Color(0,1,0)
        else:
            for i in allModels:
                print(i.get_children())
                i.get_node('Sprite2D').modulate = Color(1,0,0)
                
 
func _process(float) -> void:
    queue_redraw()
        
                
        
