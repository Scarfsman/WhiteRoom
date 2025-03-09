extends Control


# Called when the node enters the scene tree for the first time.

var data = {}
var default_font

func _ready():
    default_font = ThemeDB.fallback_font

func _draw():
    var dims = get_parent().size
    var xpos = []
    var currPos = 0
    var n = len(data.keys())
    
    if n > 0:
        var interval = dims[0]/(n+1)
        for i in range(1, n+1):
            xpos.append(currPos + interval)
            currPos += interval
        
        var diff = dims[1] * 0.8
        var totalTrials = 0
        for i in data.values():
            totalTrials += i
        
        var perc = 0
        
        for i in range(len(xpos)): 
            var ratio =  float(data.values()[i]) / totalTrials
            var curDiff = diff * ratio
            perc += curDiff
            draw_line(Vector2(xpos[i], dims[1]), Vector2(xpos[i], dims[1] - curDiff), 
                      Color.WHITE,
                      25) 
            draw_string(default_font, Vector2(xpos[i]-6, dims[1]+20), str(data.keys()[i])) 

func _process(delta: float) -> void:
    queue_redraw()
