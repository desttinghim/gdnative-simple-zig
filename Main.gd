extends Control
var data
func _ready(): 
	var simple = load("res://simple.gdns")
	data = simple.new()

func _on_Button_pressed():
	$Label.text = "Data = " + data.get_data()
