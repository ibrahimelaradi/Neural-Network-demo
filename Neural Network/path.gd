extends Control

var points = []
var epoch = 0

func pass_point(value:float):
	if $Timer.is_stopped(): $Timer.start()
	value = value*100
	value = 60 - value
	points.push_back(Vector2(epoch,value))

func _draw():
	if points.size() == 2:
		draw_line(points[0],points[1], Color(1,1,1,1))
		points.remove(0)

func _on_Timer_timeout():
	epoch += 20
