extends Node

const SAVE_PATH = 'res://data.json'

export(int) var input_units = 256
export(Array,int) var hidden_layers = [7]
export(int) var output_units = 4
export(float, 0,1.0) var learning_rate = 0.4

var units_p_layer = []
var delta_arr = []
var weights = []

var data = {
			'Highest Certainty': 0.0,
			'Average Error': 0.0,
			'Epochs': 0,
			'Saved Weights': null,
			
			}


func _initialize():
	var input_layer = []
	for input_unit in range(0,input_units):
		input_layer.push_back(0.0)
	input_layer.push_back(1.0)
	units_p_layer.push_back(input_layer)
	delta_arr.push_back(input_layer)
	for layer in hidden_layers:
		var hidden_layer = []
		for i in range(0,layer):
			hidden_layer.push_back(0.0)
		hidden_layer.push_back(1.0)
		units_p_layer.push_back(hidden_layer)
		delta_arr.push_back(hidden_layer)
	var output_layer = []
	for i in range(0,output_units):
		output_layer.push_back(0)
	units_p_layer.push_back(output_layer)
	delta_arr.push_back(output_layer)
	_initialize_weights()

func _initialize_weights():
	for layer in range(0, units_p_layer.size()):
		if layer == units_p_layer.size()-1:
			break
		var weight_layer = []
		for unit in range(0, units_p_layer[layer].size()):
			var unit_weights = []
			for next_layer_unit in range(0, units_p_layer[layer+1].size()):
				if layer != units_p_layer.size()-2:
					if next_layer_unit == units_p_layer[layer+1].size()-1:
						break
				var rand = rand_range(-0.3, 0.3)
				unit_weights.push_back(rand)
				
			weight_layer.push_back(unit_weights)
		weights.push_back(weight_layer)

func _pass_training_data(test_data, target_data):
	var output = feed_forward(test_data)
	_backpropagation(target_data)
	return output

func feed_forward(input_units:Array):
	
	for input_unit in range(0,input_units.size()):
		units_p_layer[0][input_unit] = input_units[input_unit]
	
	for layer in range(1,units_p_layer.size()):
		for unit in range(0,units_p_layer[layer].size()):
			if unit == units_p_layer[layer].size()-1 and layer != units_p_layer.size()-1:
				break
			var net = 0.0
			for unit_in_player in range(0,units_p_layer[layer-1].size()):
				
				if layer == 1:
					net += weights[layer-1][unit_in_player][unit] * units_p_layer[0][unit_in_player]
				else:
					net += weights[layer-1][unit_in_player][unit] * sigmoid(units_p_layer[layer-1][unit_in_player])
					
			units_p_layer[layer][unit] = net
	
	var outputs = []
	for unit in units_p_layer[units_p_layer.size()-1]:
		outputs.push_back(sigmoid(unit))

	return outputs

func _backpropagation(target:Array):
	
	set_error(target)
	
	for layer in dec_range(units_p_layer.size(),1):
		
		for unit in range(0,units_p_layer[layer].size()):
			var delta = 0.0
			if layer == (units_p_layer.size() - 1):
				var output = sigmoid(units_p_layer[layer][unit])
				delta = (target[unit] - output) * output * (1 - output)
				
			else:
				var output = sigmoid(units_p_layer[layer][unit])
				var net = 0.0
				for weight in range(0, units_p_layer[layer+1].size()):
					if weight == units_p_layer[layer+1].size()-1:break
					net += delta_arr[layer+1][weight] * weights[layer][unit][weight]
				delta = output * (1 - output) * net
			delta_arr[layer][unit] = delta
	
	for layer in range(0,units_p_layer.size()-1):
		for curr_layer_unit in range(0,units_p_layer[layer].size()):
			var size = (units_p_layer[layer+1].size()-1) if layer != (units_p_layer.size()-2) else units_p_layer[layer+1].size()

			for next_layer_unit in range(0, size):
				weights[layer][curr_layer_unit][next_layer_unit] += learning_rate * delta_arr[layer+1][next_layer_unit] * sigmoid(units_p_layer[layer][curr_layer_unit])

	data['Saved Weights'] = weights
	save_data()

func set_error(target:Array):
	var net_err = 0.0
	for unit in range(0,units_p_layer[units_p_layer.size()-1].size()):
		net_err += pow(target[unit] - sigmoid(units_p_layer[units_p_layer.size()-1][unit]),2)
	data['Average Error'] = 0.5 * net_err

func dec_range(from,to):
	var temp = range(to,from)
	temp.invert()
	return temp

func save_data():
	var save_file = File.new()
	save_file.open(SAVE_PATH, File.WRITE)
	save_file.store_line(to_json(data))
	save_file.close()

func _load_data():
	var save_file = File.new()
	if !save_file.file_exists(SAVE_PATH):return
	save_file.open(SAVE_PATH,File.READ)
	data = parse_json(save_file.get_as_text())
	weights = data['Saved Weights']
	
	save_file.close()

func sigmoid(net:float) -> float:
	return 1/(1+exp(-net))