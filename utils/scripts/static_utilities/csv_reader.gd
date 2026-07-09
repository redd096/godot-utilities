class_name  CsvReader

## Return a dictionary with the contents of a CSV file 
## key: String (header, the strings inside the first row of the csv), 
## value: Array (every cell in column)
static func read_csv(csv_path: String) -> Dictionary[String, Array]:
	# be sure file exists
	if not FileAccess.file_exists(csv_path):
		print("File does not exist: ", csv_path)
		return {}
	
	# key: String (header), value: Array (every cell in column)
	var dictionary: Dictionary[String, Array]
	var headers: PackedStringArray
	var has_already_headers: bool = false
	
	# read every row
	var file: FileAccess = FileAccess.open(csv_path, FileAccess.READ)
	while not file.eof_reached():
		var line: PackedStringArray = file.get_csv_line()
		# create headers
		if not has_already_headers:
			has_already_headers = true
			headers = line
			for i in range(headers.size()):
				dictionary[headers[i]] = []
		# fill dictionary
		else:
			for i in range(line.size()):
				var field: String = line[i]
				# add value
				if field.contains("%"):
					# from 50% to 0.5
					field = field.replace("%", "")
					var f: float = field.to_float() / 100
					dictionary[headers[i]].append(f)				# percentage as float
				elif field.is_valid_float():
					dictionary[headers[i]].append(field.to_float())	# float
				elif field.is_valid_int():
					dictionary[headers[i]].append(field.to_int())	# int
				elif field.nocasecmp_to("true") == 0:
					dictionary[headers[i]].append(true)				# true
				elif field.nocasecmp_to("false") == 0:
					dictionary[headers[i]].append(false)			# false
				else:
					dictionary[headers[i]].append(field)			# string
	
	# for key in dictionary.keys():
	# 	print("key: \t", key, "\nvalue: \t", dictionary[key])

	return dictionary


## Return an array with every row of CSV file 
## e.g. result[0][0] is the first cell on top left, 
## result[0][1] in the first row is the second cell (column 1), 
## result [1][0] in the second row is the first cell (column 0)
static func read_csv_array_rows(csv_path: String) -> Array[PackedStringArray]:
	# be sure file exists
	if not FileAccess.file_exists(csv_path):
		print("File does not exist: ", csv_path)
		return []
	
	var array: Array[PackedStringArray]

	# add every row to array
	var file: FileAccess = FileAccess.open(csv_path, FileAccess.READ)
	while not file.eof_reached():
		var line: PackedStringArray = file.get_csv_line()
		array.append(line)
	
	# for row in array:
	# 	print(row)
	
	return array