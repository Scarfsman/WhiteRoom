extends Node

var rosterData = {}

@onready var monte_carlo = $"TabContainer/Monte Carlo"

#display data
func display_data(team: String, id = 0):
    var unitData
    var weaponData
    var path
    
    if team == 'Red':
        if id == 0:
            unitData = globals.redTeamUnits
            weaponData = globals.redTeamWeapons
        else:
            unitData = globals.redTeamUnits
            unitData = unitData.filter('id', id)
            weaponData = globals.redTeamWeapons
            weaponData = weaponData.filter('id', id)
        path = 'TabContainer/RedTeam/Background'
    elif team == 'Blue':
        if id == 0:
            unitData = globals.blueTeamUnits
            weaponData = globals.blueTeamWeapons
        else:
            unitData = globals.blueTeamUnits
            unitData = unitData.filter('id', id)
            weaponData = globals.blueTeamWeapons
            weaponData = weaponData.filter('id', id)
        path = 'TabContainer/BlueTeam/Background'
        
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
func _on_load_red_team_pressed() -> void:
    $FileDialogRed.popup()

#Red Team File Uploaded
func _on_file_dialog_red_file_selected(path: String) -> void:
    rosterData = globals.load_json_file(path)
    rosterData = globals.json_to_dataframe(rosterData)
    globals.redTeamUnits = rosterData[0]
    globals.redTeamWeapons = rosterData[1]
    
    $TabContainer/RedTeam/OptionButtonRed.clear()
    $"TabContainer/Monte Carlo/SubjectSelection".clear()
    var list = []
    for unit in globals.redTeamUnits.data:
        var unitString = str(unit[0]) + ' - ' + unit[1]
        if unitString not in list:
            $TabContainer/RedTeam/OptionButtonRed.add_item(unitString, unit[0])
            $"TabContainer/Monte Carlo/SubjectSelection".add_item(unitString, unit[0])
            list.append(unitString)
    display_data('Red', 1)
    monte_carlo.displayAttacker(1)
    
#Red Team Unit Selected from the drop down
func _on_option_button_red_item_selected(index: int) -> void:
    display_data('Red', index + 1)
    
#Blue Team
func _on_load_blue_team_pressed() -> void:
    $FileDialogBlue.popup()

#Blue Team File Uploaded
func _on_file_dialog_blue_file_selected(path: String) -> void:
    rosterData = globals.load_json_file(path)
    rosterData = globals.json_to_dataframe(rosterData)
    globals.blueTeamUnits = rosterData[0]
    globals.blueTeamWeapons = rosterData[1]
    
    $TabContainer/BlueTeam/OptionButtonBlue.clear()
    $"TabContainer/Monte Carlo/TargetSelection".clear()
    var list = []
    for unit in globals.blueTeamUnits.data:
        var unitString = str(unit[0]) + ' - ' + unit[1]
        if unitString not in list:
            $TabContainer/BlueTeam/OptionButtonBlue.add_item(unitString, unit[0])
            $"TabContainer/Monte Carlo/TargetSelection".add_item(unitString, unit[0])
            list.append(unitString)
    display_data('Blue', 1)
    monte_carlo.displayDefender(1)

#Blue Team Unit Selected from the drop down
func _on_option_button_blue_item_selected(index: int) -> void:
    display_data('Blue', index + 1)
