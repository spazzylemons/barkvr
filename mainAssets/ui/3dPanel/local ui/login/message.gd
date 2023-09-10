@tool
class_name message_bubble
extends Control

var panel:Panel
var label:Label

@export var text = ''

@export var leftside:bool = true

func _enter_tree():
	panel = $Panel
	label = $Panel/Label
	if text:
		label.text = text

func _process(delta):
	panel.size.x = size.x/2.0
	panel.custom_minimum_size.y = label.size.y+20.0
	custom_minimum_size.y = label.size.y+20.0
	panel.size.y = label.size.y+20.0
	size.y = label.size.y+20.0
	panel.position.y = 0.0
	if leftside:
		panel.position.x = 0.0
	else:
		panel.position.x = size.x/2.0