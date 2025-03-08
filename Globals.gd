extends Node

var redTeamUnits = DataFrame.New([], [])
var redTeamWeapons = DataFrame.New([], [])
var blueTeamUnits = DataFrame.New([], [])
var blueTeamWeapons = DataFrame.New([], [])
var rng = RandomNumberGenerator.new()
var expression = Expression.new()

#variables for the monte carlo simulation
var hits
var wounds
var damage = 0

var unitCols = ['id',
                'Datasheet',
                'Name',
                'M',
                'T',
                'Sv',
                'W',
                'Ld',
                'OC',
                'Count']

var weaponCols = ['id',
                  'Datasheet',
                  'Name',
                  'Range',
                  'A',
                  'BS/WS',
                  'S',
                  'AP',
                  'D',
                  'Abilities',
                  'Count']

#load and prepare data from json files

func _ready():
    
    print(float("-4"))

func addModels(idnumber, datasheetName, modelName, profile, count):
    var chars = [idnumber, datasheetName, modelName]
    
    for characteristic in profile['characteristics']:
        chars.append(characteristic['$text'])
        
    chars.append(count)
    return chars
    
func addWeapons(idnumber, datasheetName, weaponName, profile, count):
    var chars = [idnumber, datasheetName, weaponName.replace('➤ ', '')]
    
    for characteristic in profile['characteristics']:
        chars.append(characteristic['$text'])
    
    if len(chars) > 8:
        chars[9] = chars[9].split(',')
    chars.append(count)
    return chars

func json_to_dataframe(json):
    assert(json is Dictionary)
    var roster = json['roster']['forces'][0]['selections']
    var datasheetName = 'null'
    var weaponProfile = 'null' 
    var newRow = []
    
    var unitRows = []
    var weaponRows = []
    
    for i in range(3, len(roster)):
        var idnumber = i-2
        datasheetName = roster[i]['name']
        
        if roster[i]['type'] == 'model':
            for profile in roster[i]['profiles']:
                if profile['typeName'] == 'Unit':
                    newRow = addModels(idnumber, 
                                       datasheetName, 
                                       datasheetName, 
                                       profile,
                                       1)
                    unitRows.append(newRow)
        
        var unitChars = 'null'
        for profile in roster[i]['profiles']:
            if profile['typeName'] == 'Unit':
                unitChars = profile
                for selection in roster[i]['selections']:
                        if selection['type'] == 'model':
                            newRow = addModels(idnumber, 
                                               datasheetName, 
                                               selection['name'], 
                                               unitChars, 
                                               selection['number'])
                            unitRows.append(newRow)
                                                                                 
                            for selection2 in selection['selections']:
                                if selection2['type'] == 'upgrade':
                                    weaponProfile = selection2['profiles'][0]
                                    newRow = addWeapons(idnumber, 
                                                        datasheetName, 
                                                        selection2['name'], 
                                                        weaponProfile, 
                                                        selection2['number'])
                                    if len(newRow) == 11:
                                        weaponRows.append(newRow)
                        else:
                            if 'profiles' in selection.keys():
                                for profile2 in selection['profiles']:
                                    newRow = addWeapons(idnumber, 
                                                        datasheetName, 
                                                        profile2['name'], 
                                                        profile2, 
                                                        selection['number'])
                                    if len(newRow) == 11:
                                        weaponRows.append(newRow)
                            elif 'selections' in selection.keys():
                                for profile2 in selection['selections']:
                                    weaponProfile = profile2['profiles'][0]
                                    newRow = addWeapons(idnumber, 
                                                        datasheetName, 
                                                        profile2['name'], 
                                                        weaponProfile, 
                                                        profile2['number'])
                                    if len(newRow) == 11:
                                        weaponRows.append(newRow)
                                        
        if unitChars is String:
            for selection in roster[i]['selections']:
                
                for weapon in selection['selections']:
                    if 'profiles' in weapon.keys():
                        for profile in weapon['profiles']:
                            newRow = addWeapons(idnumber, 
                                                datasheetName, 
                                                profile['name'], 
                                                profile, 
                                                selection['number'])
                            if len(newRow) == 11:
                                weaponRows.append(newRow)
                    elif 'selections' in weapon.keys():
                        for profile in weapon['selections']:
                            weaponProfile = profile['profiles'][0]
                            newRow = addWeapons(idnumber, 
                                                datasheetName, 
                                                profile['name'], 
                                                weaponProfile, 
                                                profile['number'])
                            if len(newRow) == 11:
                                weaponRows.append(newRow)
                    
                for profile in selection['profiles']:
                    if profile['typeName'] == 'Unit':
                        unitChars = profile
                newRow = addModels(idnumber, 
                                   datasheetName, 
                                   selection['name'], 
                                   unitChars, 
                                   selection['number'])
                unitRows.append(newRow)
        
    unitRows = DataFrame.New(unitRows, unitCols)
    weaponRows = DataFrame.New(weaponRows, weaponCols)
    weaponRows = weaponRows.CollectWeapons()
    
    return [unitRows, weaponRows]   

func load_json_file(path: String):
    
    if FileAccess.file_exists(path):
        var dataFile = FileAccess.open(path, FileAccess.READ)
        var parsedResult = JSON.parse_string(dataFile.get_as_text())
        
        if parsedResult is Dictionary:
            return parsedResult
        else:
            print('Whooops')
    else:
        print("File Doesn't exist")

func getAttacks(attacks, count, abilities):
    var totalAttacks = 0
    if attacks is String:
        if 'D6' in attacks:
            for i in range(count):
                var temp = attacks
                temp = temp.replace('D6', str(rng.randi_range(1, 6)))
                expression.parse(temp)
                totalAttacks += expression.execute()           
        elif 'D3' in attacks:
            for i in range(count):
                var temp = attacks
                temp = temp.replace('D3', str(rng.randi_range(1, 6)))
                expression.parse(temp)
                totalAttacks += expression.execute()
        else:
            totalAttacks = float(attacks) * float(count)
    else:
        totalAttacks = float(attacks) * float(count)
    return totalAttacks
    
func getHits(HitOn, attacks, abilities, debug):
    var hits = 0
    var crits = 0
    
    var lethalHits = 0
    var SustainedHits = 0
    
    for ability in abilities:
        if 'Lethal Hits' in ability:
            lethalHits = 1
            continue
        if 'Sustained' in ability:
            ability = ability.replace('Sustained Hits', '')
            SustainedHits = float(ability)
    
    if HitOn > 0:
        for shot in range(attacks):
            hits += int(rng.randi_range(1, 6) >= HitOn)
        # if the weapon has abilities that matter for crits, calculate
        if (lethalHits > 0) or (SustainedHits > 0):
            for hit in range(hits):
                crits += int(rng.randi_range(1, 6) >= 6)
        hits = attacks - crits * lethalHits
        hits += crits * SustainedHits
        wounds += crits * lethalHits
    else:
        #weapon auto hits
        hits = attacks
  
    if debug:
        print('Abilities')
        print('Lethal Hits')
        print(lethalHits)
        print('Sustained Hits')
        print(SustainedHits)
        print('Hits')
        print(hits)
        print('crits')
        print(crits)
        
    return hits
    
func getWounds(WoundOn, Hits):
    var temp = 0
    for roll in Hits:
        temp += int(rng.randi_range(1, 6) >= WoundOn)   
    return temp
    
func GetWoundOn(S, T):
    var WoundOn = S/T
    if WoundOn >= 2:
        WoundOn = 2
    elif WoundOn > 1:
        WoundOn = 3
    elif WoundOn == 1:
        WoundOn = 4
    elif WoundOn > 0.5:
        WoundOn = 5
    else:
        WoundOn = 6
    print('WoundOn')
    print(WoundOn)
    return WoundOn
    
func simulation(attackerdf: DataFrame, defenderdf: DataFrame, n = 1, debug = true):
    print('----------------------------------------')
    print('Starting Simulation')
    var damages = []
    var totalDamage = {}
    for weapon in range(len(attackerdf.data)):
        if debug:
            print('-----------------')
            print(attackerdf.GetColumns('Name')[weapon])
            print('-----------------')
        var Torrent = false
        var abilities = attackerdf.GetColumns('Abilities')[weapon]
        var attacks = attackerdf.GetColumns('A')[weapon]
        var count =  float(attackerdf.GetColumns('Count')[weapon])
        var HitOn = 0
        var regex = RegEx.new()
        regex.compile("\\d+")
        var Dams = []
        
        if ' Torrent' not in abilities:
            #get the hit on value
            HitOn = attackerdf.GetColumns('BS/WS')[weapon]
            var all_numbers_found = regex.search_all(HitOn)
            HitOn = int(all_numbers_found[0].get_string())
        
        var WoundOn = GetWoundOn(float(attackerdf.GetColumns('S')[weapon]),
                                 float(defenderdf.GetColumns('T')[0]))
        
        var ap = attackerdf.GetColumns('AP')[weapon]
        var save = float(defenderdf.GetColumns('Sv')[0]) - float(ap)
        if debug:
            print('calculating svae')
            print(save)
    
        damage = 0
        
        if save > 6:
            for i in range(n): 
                hits = 0
                wounds = 0  
                damage = 0
                var totalAttacks = getAttacks(attacks, count, abilities)
                hits = getHits(HitOn, totalAttacks, abilities, debug)
                if debug:
                    print('Total Hits')
                    print(hits)
                    print(wounds)
                wounds = getWounds(WoundOn, hits)
                Dams.append(wounds)
                
        else:
            for i in range(n):
                hits = 0
                wounds = 0  
                damage = 0
                var totalAttacks = getAttacks(attacks, count, abilities)
                hits = getHits(HitOn, totalAttacks, abilities, debug)
                if debug:
                    print('Total Hits')
                    print(hits)
                    print(wounds)
                wounds = getWounds(WoundOn, hits)
                if debug:
                    print('TotalWounds')
                    print(wounds)
                for wound in range(wounds):
                    damage += int(rng.randi_range(1, 6) < save)
                Dams.append(damage)
        damages.append(Dams)
    
    print('All Fired')

    #get the number of wounds of each model in the defending unit so we
    #can calculate the amount that will die
    var defenderModels = []
    for row in range(len(defenderdf.data)):
        for model in range(defenderdf.GetColumns('Count')[row]):
            defenderModels.append(int(defenderdf.GetColumns('W')[row]))
    
    if debug:
        print(damages)
        print(defenderModels)
    
    #calculate the number of slain models
    if len(defenderModels) > 1:
        #calculate the amount of models slain
        for trial in range(n):
            var destroyedModels = 0
            var currDamage = defenderModels[destroyedModels]
            while destroyedModels < len(defenderModels):
                for weapon in range(len(damages)):
                    var dam = float(attackerdf.GetColumns('D')[weapon])
                    if debug:
                        print('Damage per shot')
                        print(dam)
                    for shot in range(damages[weapon][trial]):
                        currDamage -= dam
                        print(currDamage)
                        if currDamage <= 0:
                            destroyedModels += 1
                            #if the most recent shot kills the unit, 
                            #break out of this loop
                            if destroyedModels >= len(defenderModels):
                                break
                            currDamage = defenderModels[destroyedModels]
                            print('nextM mdoel')
                    #if the unit is already dead, break here
                    if destroyedModels >= len(defenderModels):
                                break
                break
            if destroyedModels not in totalDamage.keys():
                totalDamage[destroyedModels] = 1
            else:
                totalDamage[destroyedModels] = totalDamage[destroyedModels] + 1
    else:
        #if there is onl one model ni the defending unit, return the inflicted wounds
        for trial in range(n):
            var currDamage = 0
            var maxDamage = defenderModels[0]
            while currDamage < maxDamage:
                for weapon in range(len(damages)):
                    var dam = float(attackerdf.GetColumns('D')[weapon])
                    for shot in range(damages[weapon][trial]):
                        currDamage += dam
                        if currDamage >= maxDamage:
                            break
                    #if the unit is already dead, break here
                    if currDamage >= maxDamage:
                        break
                break
            if currDamage not in totalDamage.keys():
                totalDamage[currDamage] = 1
            else:
                totalDamage[currDamage] = totalDamage[currDamage] + 1
    
    var keys = totalDamage.keys()
    keys.sort()
    var sortedDict = {}
    for key in keys:
        sortedDict[key] = totalDamage[key]
    print('----------------------------------------')
    return sortedDict

                    
                    
                
                
            

        
        
