extends Node2D


var epoch = 0

var train = false

var iterator = 0
var drawing_letter = false

var error = 0
var pre_error = 0
var err_down = 0
var err_up = 0

func _ready():
	$NeuralNetwork._initialize()

var test_set = [
				preload('res://scenes/train_1.tscn'),
				preload('res://scenes/train_2.tscn'),
				preload('res://scenes/train_3.tscn'),
				preload('res://scenes/train_4.tscn'),
				preload('res://scenes/train_5.tscn'),
				preload('res://scenes/train_6.tscn'),
				preload('res://scenes/train_7.tscn'),
				preload('res://scenes/train_8.tscn'),
				preload('res://scenes/train_9.tscn'),
				preload('res://scenes/train_10.tscn'),
				preload('res://scenes/train_11.tscn'),
				preload('res://scenes/train_12.tscn'),
				preload('res://scenes/train_13.tscn'),
				preload('res://scenes/train_14.tscn'),
				preload('res://scenes/train_15.tscn'),
				preload('res://scenes/train_16.tscn')
				]
var target_set = [
				[1,0,0,0,0],
				[0,1,0,0,0],
				[0,0,1,0,0],
				[0,0,0,1,0],
				[1,0,0,0,0],
				[0,1,0,0,0],
				[0,0,1,0,0],
				[0,0,0,1,0],
				[1,0,0,0,0],
				[0,1,0,0,0],
				[0,0,1,0,0],
				[0,0,0,1,0],
				[1,0,0,0,0],
				[0,1,0,0,0],
				[0,0,1,0,0],
				[0,0,0,1,0]
				]

func train_letter(image,target):
	var tlmp = image.instance()
	$container.add_child(tlmp)
	var outputs = $NeuralNetwork._pass_training_data(tlmp.get_info(),target)
	$Label.text = 'Answer : ' + str(decision_maker(outputs))
	
	$Label3.text = "'A' certainty : " + str(outputs[0])
	$Label4.text = "'B' certainty : " + str(outputs[1])
	$Label5.text = "'C' certainty : " + str(outputs[2])
	$Label6.text = "'D' certainty : " + str(outputs[3])
	error += $NeuralNetwork.data['Average Error']

func decision_maker(results:Array):
	if results[0] > 0.9:
		return 'A'
	if results[1] > 0.9:
		return 'B'
	if results[2] > 0.9:
		return 'C'
	if results[3] > 0.9:
		return 'D'
	return 'UNCERTAIN'

func _process(delta):
	$Label7.text = 'Epoch : ' + str(epoch)
	if train:
		for i in range(0,16):
			train_letter(test_set[i],target_set[i])
			$container.get_child(0).queue_free()



func _on_train_button_up():
	train = true
	$Timer.stop()


func _on_stop_button_up():
	train = false
	$Timer.stop()


func _on_load_weights_button_up():
	$NeuralNetwork._load_data()


func _on_slow_button_up():
	$Timer.start()


func _on_Timer_timeout():
	train = false
	if $container.get_child(0) != null:
		$container.get_child(0).queue_free()
	train_letter(test_set[iterator],target_set[iterator])
	iterator += 1
	if iterator == 16:
		iterator = 0
		epoch += 1
		error = error/16
		if error > pre_error:
			$Label2.modulate = Color(1,0,0,1)
			err_up += 1
		else:
			$Label2.modulate = Color(0,1,0,1)
			err_down += 1
		$Label2.text = 'Error : ' + str(error)
		$Label8.text = 'INCREASE : ' +str(err_up) + '| DECREASE : ' + str(err_down) + '| RATE : ' + str(abs(error - pre_error))
		pre_error = error
		error = 0


func _on_new_button_up():
	if $container.get_child(0) != null:
		$container.get_child(0).queue_free()
	var tlmp = load('res://scenes/Infosheet.tscn').instance()
	$container.add_child(tlmp)
	drawing_letter = true

func _input(event):
	if !drawing_letter: return
	if event.is_action_pressed('mouse_click'):
		var x = int((event.position.x - 40)/10)
		var y = int((event.position.y - 40)/10)
		if x > 16 or y > 16: return
		if x < 0 or y < 0: return
		$container.get_child(0).set_cell(x,y,0)

func _on_test_button_up():
	var outputs = $NeuralNetwork.feed_forward($container.get_child(0).get_info())
	$Label3.text = "'A' certainty : " + str(outputs[0])
	$Label4.text = "'B' certainty : " + str(outputs[1])
	$Label5.text = "'C' certainty : " + str(outputs[2])
	$Label6.text = "'D' certainty : " + str(outputs[3])