extends Resource
class_name DataFrame

'https://www.youtube.com/@squadron_studio'

@export var data: Array
@export var columns: PackedStringArray


static func New(d: Array, c = false) -> DataFrame:
    var df = DataFrame.new()
    df.data = d
    if c:
        df.columns = c
    return df

# getters
func GetColumns(cols):
    #case where passed argument is a string, in which case, get single column
    if cols is String:
        assert(cols in columns)
        var x1 = columns.find(cols)
        var result = []
        for row in data:
            result.append(row[x1])
        return result
    elif cols is Array:
        var inds = []
        var newCols = []
        var result = []
        for col in cols:
            inds.append(columns.find(col))
            newCols.append(col)
        for row in data:
            var newRow = []
            for ind in inds:
                newRow.append(row[ind])
            result.append(newRow)
        return DataFrame.New(result, newCols)

func GetRow(i: int):
    assert(i < len(data))
    return data[i]

func GetUnits():
    var units = []
    for i in range(len(data)):
        var row = data[i].slice(0, 2)
        if row not in units:
            units.append(row)
    return units

func GetUnique():
    var result = []
    for row in data:
        if row not in result:
            result.append(row)
    return DataFrame.New(result, columns)

func Append(newDataFrame: DataFrame) -> void:
    assert(newDataFrame.columns == columns)
    for row in newDataFrame.data:
        data.append(row)

func filter(colName: String, arg, exclude = false) -> DataFrame:
    var filterData = []
    var filterColumn = GetColumns(colName)
    for i in len(filterColumn):
        if (filterColumn[i] == arg) and (exclude == false):
            filterData.append(data[i])
        elif (filterColumn[i] != arg) and (exclude == true):
            filterData.append(data[i])
            
    return DataFrame.New(filterData, columns)
                        
func Size():
    return len(data)

# adders 
func AddColumn(d: Array, colName: String):
    assert(len(d) == len(data))
    columns.append(colName)
    for i in range(len(data)):
        data[i].append(d[i])

static func EvalColumns(
    c1: Array,
    operand: String,
    c2: Array):
    
    assert(len(c1) == len(c2))
    
    var expression = Expression.new()
    
    if operand == '/':
        expression.parse("float(a) %s float(b)" % operand, ["a", "b"])
    else:
        expression.parse("a %s b" % operand, ["a", "b"])
    
    var result = []
    for i in range(len(c1)):
        result.append(
            expression.execute([c1[i], c2[i]])
        )
    return result

func _sort_by(row1, row2, Ix, desc) -> bool:
    var result: bool
    
    if desc:
        if row1[Ix] > row2[Ix]:
            result = true
        else:
            result = false
    else:
        if row1[Ix] < row2[Ix]:
            result = true
        else:
            result = false
    
    return result

func SortBy(colName: String, desc: bool = false):
    assert(colName in columns)
    
    var Ix = columns.find(colName)
    data.sort_custom(_sort_by.bind(Ix, desc))

func _to_string() -> String:
    if len(data) == 0:
        return  "<empty DataFrame>"
    
    var result = ' | '.join(columns) + '\n--------\n'
    for line in data:
        result += ' | '.join(line) + '\n'
    
    return result

func CollectWeapons():
    var result = []
    var SeenProfiles = []
    var weaponX = columns.find('Count')
    
    for row in data:
        var temp = row.duplicate(true)
        temp.pop_at(weaponX)
        if temp not in SeenProfiles:
            result.append(row)
            SeenProfiles.append(temp)
        else:
            var seenX = SeenProfiles.find(temp)
            result[seenX][weaponX] += row[weaponX]
    return DataFrame.New(result, columns)
        
func prettify():
    var newData = data.duplicate(true)
    var newCols = columns.duplicate()
    var maxLength = 0
    
    for column in len(newData[0]):
        maxLength = len(newCols[column])
        newCols[column] = ' ' + newCols[column]
        for row in len(newData):
            newData[row][column] = str(newData[row][column])
            maxLength = max(maxLength, len(newData[row][column]))
        for row in len(newData):
            newData[row][column] = ' ' + newData[row][column]
            for i in range(maxLength + 2 - len(newData[row][column])):
                newData[row][column] += ' '
        for i in range(maxLength + 2 - len(newCols[column])):
             newCols[column] += ' '
    return DataFrame.New(newData, newCols)
        
