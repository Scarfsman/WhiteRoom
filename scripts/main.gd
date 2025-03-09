extends Node

var rosterData = {}

@onready var monte_carlo = $"TabContainer/Monte Carlo"

var file_access_web: FileAccessWeb = FileAccessWeb.new()

func _ready() -> void:
    file_access_web.loaded.connect(_on_file_loaded)
    file_access_web.load_started.connect(_on_file_load_started)
    file_access_web.progress.connect(_on_progress)

#display data
func display_data(id = 0) -> void:
    var unitData
    var weaponData
    var path

    if id == 0:
        unitData = globals.Units
        weaponData = globals.Weapons
    else:
        unitData = globals.Units
        unitData = unitData.filter('id', id)
        weaponData = globals.Weapons
        weaponData = weaponData.filter('id', id)
    path = 'TabContainer/LoadData/Background'
    
    unitData = unitData.prettify()
    var unitTable = get_node(path + '/ModelData')
    unitTable.data = unitData
    unitTable.Render()
    
    weaponData = weaponData.prettify()
    var weapponTable = get_node(path + '/WeaponData')
    weapponTable.data = weaponData
    weapponTable.Render()

#singal functions
#Red Team
func _on_load_pressed() -> void:
    $FileDialogRed.popup()
    #file_access_web.open()

#Red Team File Uploaded
func _on_file_dialog_red_file_selected(path: String) -> void:
    rosterData = globals.load_json_file(path)
    rosterData = globals.json_to_dataframe(rosterData)
    globals.Units.Append(rosterData[0])
    globals.Weapons.Append(rosterData[1])
    
    $TabContainer/LoadData/OptionButton.clear()
    $"TabContainer/Monte Carlo/AttackerSelection".clear()
    $"TabContainer/Monte Carlo/DefenderSelection".clear()
    
    print(globals.Units.GetColumns('id'))
    
    var list = []
    for unit in globals.Units.data:
        var unitString = str(unit[0]) + ' - ' + unit[1]
        if unitString not in list:
            $TabContainer/LoadData/OptionButton.add_item(unitString, unit[0])
            $"TabContainer/Monte Carlo/AttackerSelection".add_item(unitString, unit[0])
            $"TabContainer/Monte Carlo/DefenderSelection".add_item(unitString, unit[0])
            list.append(unitString)
    display_data(1)
    monte_carlo.displayAttacker(1)
    monte_carlo.displayDefender(1)
    
#Red Team Unit Selected from the drop down
func _on_option_button_item_selected(index: int) -> void:
    display_data(index + 1)
    
func _on_file_loaded(file_name: String, type: String, base64_data: String):
    var rawData : String = Marshalls.base64_to_utf8(base64_data)
    rosterData = JSON.parse_string(rawData)
    rosterData = globals.json_to_dataframe(rosterData)
    globals.Units.Append(rosterData[0])
    globals.Weapons.Append(rosterData[1])
    
    $TabContainer/LoadData/OptionButton.clear()
    $"TabContainer/Monte Carlo/AttackerSelection".clear()
    $"TabContainer/Monte Carlo/DefenderSelection".clear()
    
    var list = []
    for unit in globals.Units.data:
        var unitString = str(unit[0]) + ' - ' + unit[1]
        if unitString not in list:
            $TabContainer/LoadData/OptionButton.add_item(unitString, unit[0])
            $"TabContainer/Monte Carlo/AttackerSelection".add_item(unitString, unit[0])
            $"TabContainer/Monte Carlo/DefenderSelection".add_item(unitString, unit[0])
            list.append(unitString)
    display_data(1)
    monte_carlo.displayAttacker(1)
    monte_carlo.displayDefender(1)

#DONT DELETE
func _on_file_load_started(file_name: String) -> void:
    print('loading file')
    
#DONT DELETE
func _on_progress(current_bytes: int, total_bytes: int) -> void:
    var percentage: float = float(current_bytes) / float(total_bytes) * 100
