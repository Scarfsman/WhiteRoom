extends Control

@onready var TableRow = preload("res://table_row.tscn")
@onready var TableCell = preload("res://table_cell.tscn")
@onready var TickBox = preload("res://check_box.tscn")

@export var data: DataFrame


func Render():
    if data:
        #clear the curent displayed table
        for n in $ScrollContainer/Rows.get_children():
            $ScrollContainer/Rows.remove_child(n)
         
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
    print('render Check')
    if data:
        #clear the curent displayed table
        for n in $ScrollContainer/Rows.get_children():
            $ScrollContainer/Rows.remove_child(n)
            
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
            var check = TickBox.instantiate()
            row.add_child(check)
