extends TabBar

@onready var unit = preload("res://Scenes/unit.tscn")
@onready var model = preload("res://Scenes/model.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.

var models = [40, 40, 40, 40]

func _on_load_pressed() -> void:
    models = []
    print($UnitSelection.get_selected_id())
    #filter the units data frame for the unit based on the drop down box
    var unitData = globals.Units.filter('id', $UnitSelection.get_selected_id())
    unitData = unitData.GetColumns(['Count', 'Base Size', 'M']).data
    for row in unitData:
        for i in range(row[0]):
            models.append([row[1], row[2]])
    
    var newUnit = unit.instantiate()
    for indx in range(len(models)):
        #create a new model class object and add it to the unit
        var newModel = model.instantiate()
        newUnit.add_child(newModel)
        
        #set the models movement
        newModel.maxDist = models[indx][1]
        
        #resolve models radius
        var radius: float = models[indx][0]
        #convert milimeters to inches
        radius = radius/25.4
        #convert inches to pixels
        radius = globals.inchesToPixels(radius)
        #get the scale factor for the sprite
        radius = radius/100
        var rowCount: int = 0
        #set the sprite scale accordingly
        newModel.get_node('Sprite2D').scale = Vector2(radius, radius)
        rowCount = indx/5
        
        #spawn the model
        var x = (indx*radius*150) + 150 - ((indx/5)*radius*150*5)
        var y = 150 + (radius * 150 * rowCount)
        newModel.position = Vector2(x, y)
        
    $Panel.add_child(newUnit)

func _on_clear_units_pressed() -> void:
    for child in $Panel.get_children():
        child.queue_free()
