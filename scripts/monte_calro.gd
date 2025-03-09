extends TabBar

var attackerData = DataFrame.New([], [])
var defenderData = DataFrame.New([], [])

func _ready():
    print($AttackerWeaponType.selected)
        
        
func displayGraph():
    if (len(defenderData.data) > 0) and (len(attackerData.data) > 0):
        $Graph/Graph.data = globals.simulation(attackerData, defenderData)
        var context: String = ''
        
        var totalTrials: float = 0
        for value in $Graph/Graph.data.values():
            totalTrials += value
        var currTrials: float = 0
            
        var defendingModels: int = 0
        for i in defenderData.GetColumns('Count'):
            defendingModels += i
        
        if defendingModels > 1:
            #get the median amount of models slain
            for i in range(len($Graph/Graph.data.values())):
                currTrials += $Graph/Graph.data.values()[i]
                if currTrials/totalTrials > 0.5:
                    var newRow = '{n} model(s) slain on average \n'
                    context += newRow.format({'n': $Graph/Graph.data.keys()[i]})
                    break     
            #get the percent chance to wipe the defending unit   
            if $Graph/Graph.data.keys()[-1] >= defendingModels:
                var chance: float = $Graph/Graph.data.values()[-1]/totalTrials
                chance = snapped(chance * 100, 0.01)
                context += '{chance}% to OHKO \n'.format({'chance' : chance})
            else:
                context += '0% to OHKO \n'
        else:
            #get the median amount of wounds delt
            for i in range(len($Graph/Graph.data.values())):
                currTrials += $Graph/Graph.data.values()[i]
                if currTrials/totalTrials > 0.5:
                    var newRow = '{n} wound(s) delt in on average \n'
                    context += newRow.format({'n': $Graph/Graph.data.keys()[i]})
                    break
            var totalWounds = float(defenderData.GetColumns('W')[0])
            #get the percent chance to slay the defender
            if $Graph/Graph.data.keys()[-1] >= totalWounds:
                var chance: float = $Graph/Graph.data.values()[-1]/totalTrials
                chance = snapped(chance * 100, 0.01)
                context += '{chance}% to OHKO \n'.format({'chance' : chance})
            else:
                context += '0% to OHKO \n'
                
        var attackerName: String = attackerData.GetColumns('Datasheet')[0]
        var defendername: String = defenderData.GetColumns('Datasheet')[0]
        $Graph/Graph/GraphTitle.text = attackerName + " Vs. " + defendername
        $Graph/Graph/AttackerContext.text = context
        
func displayAttacker(id):
    var weaponData = globals.Weapons
    weaponData = weaponData.filter('id', id)
    #check wether fighting at range on in melee
    var range: bool = bool($AttackerWeaponType.selected)
    weaponData = weaponData.filter('Range', 'Melee', range)
    
    attackerData = weaponData
    weaponData = weaponData.GetColumns(globals.attackerCols).prettify()
    var attackerTable = $Subject/ModelData
    attackerTable.data = weaponData
    attackerTable.RenderCheck()
    
func displayDefender(id):
    var unitData = globals.Units
    unitData = unitData.filter('id', id)
    
    defenderData = unitData
    unitData = unitData.GetColumns(['Name', 'T', 'Sv', 'W', 'Count'])
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
    if $AttackerSelection.selected != -1:
        displayAttacker($AttackerSelection.selected + 1)
        displayGraph()

    
        
    
