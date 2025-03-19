extends Control

@onready var TableRow = preload("res://Scenes/table_row.tscn")
@onready var TableCell = preload("res://Scenes/table_cell.tscn")
@onready var TickBox = preload("res://Scenes/check_box.tscn")
@onready var TextBox = preload("res://Scenes/TextField.tscn")

@export var data: DataFrame


func Render():
    if data:
        #clear the curent displayed table
        for n in $ScrollContainer/Rows.get_children():
            n.queue_free()
         
        var columns = TableRow.instantiate()
        $ScrollContainer/Rows.add_child(columns)
        
        for value in data.columns:
            var cell = TableCell.instantiate()
            cell.text = str(value)
            columns.add_child(cell)
           
        var row_count = data.Size()
        for r in range(row_count):
            var row = TableRow.instantiate()
            $ScrollContainer/Rows.add_child(row)
            
            for value in data.GetRow(r):
                var cell = TableCell.instantiate()
                cell.text = str(value)
                row.add_child(cell)
        
func RenderCheck():
    if data:
        #clear the curent displayed table
        for n in $ScrollContainer/Rows.get_children():
            n.queue_free()
            
        var columns = TableRow.instantiate()
        $ScrollContainer/Rows.add_child(columns)
        
        for value in data.columns:
            var cell = TableCell.instantiate()
            cell.text = str(value)
            columns.add_child(cell)
        
        var cell = TableCell.instantiate()
            
        var row_count = data.Size()
        for r in range(row_count):
            var row = TableRow.instantiate()
            $ScrollContainer/Rows.add_child(row)
            
            for value in data.GetRow(r):
                cell = TableCell.instantiate()
                cell.text = str(value)
                row.add_child(cell)
            var check = TickBox.instantiate()
            row.add_child(check)
            
func RenderText():
    if data:
        #clear the curent displayed table
        for n in $ScrollContainer/Rows.get_children():
            n.queue_free()
            
        var columns = TableRow.instantiate()
        $ScrollContainer/Rows.add_child(columns)
        
        for value in data.columns:
            var cell = TableCell.instantiate()
            cell.text = str(value)
            columns.add_child(cell)
            
        var row_count = data.Size()
        for r in range(row_count):
            var row = TableRow.instantiate()
            $ScrollContainer/Rows.add_child(row)
            
            for value in range(len(data.GetRow(r))):
                if value < len(data.GetRow(r)) - 1:
                    var cell = TableCell.instantiate()
                    cell.text = str(data.GetRow(r)[value])
                    row.add_child(cell)
                else:
                    var cell = TableCell.instantiate()
                    var newText = ''
                    for i in range(len(str(data.GetRow(r)[value]))):
                        newText += ' '
                    cell.text = newText
                    
                    row.add_child(cell)
                    var check = TextBox.instantiate()
                    check.get_node('LineEdit').text = str(data.GetRow(r)[value])
                    check.rowNumber = data.index[r]
                    cell.add_child(check)
                    #check.rowNumber = r
