extends TabBar

var attackerData = DataFrame.New([], [])
var defenderData = DataFrame.New([], [])

func _ready():
    print($SubjectWeaponType.selected)
        
func displayGraph():
    if (len(defenderData.data) > 0) and (len(attackerData.data) > 0):
        $Graph/Graph.data = globals.simulation(attackerData, defenderData)
        
func displayAttacker(id):
    var weaponData = globals.redTeamWeapons
    weaponData = weaponData.filter('id', id)
    weaponData = weaponData.filter('Range', 'Melee', bool($SubjectWeaponType.selected))
    weaponData = weaponData.GetColumns(['Name', 'A', 'BS/WS', 'S', 'AP', 'D', 'Abilities', 'Count'])
    attackerData = weaponData
    weaponData = weaponData.prettify()
    var attackerTable = $Subject/ModelData
    attackerTable.data = weaponData
    attackerTable.RenderCheck()
    
func displayDefender(id):
    var unitData = globals.blueTeamUnits
    unitData = unitData.filter('id', id)
    unitData = unitData.GetColumns(['Name', 'T', 'Sv', 'W', 'Count'])
    defenderData = unitData
    unitData = unitData.prettify()
    var defenderTable = $Target/ModelData
    defenderTable.data = unitData
    defenderTable.Render()

func _on_target_selection_item_selected(index: int) -> void:
    displayDefender(index + 1)
    displayGraph()

func _on_subject_selection_item_selected(index: int) -> void:
    displayAttacker(index + 1)
    displayGraph()

func _on_subject_weapon_type_item_selected(index: int) -> void:
    if $SubjectSelection.selected != -1:
        displayAttacker($SubjectSelection.selected + 1)
        displayGraph()

    
        
    
