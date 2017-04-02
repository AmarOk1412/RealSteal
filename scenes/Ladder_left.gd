extends Area2D

var player_class = preload("res://scenes/Player.gd")

func _ready():
	pass

func _on_Ladder_body_enter( body ):
	if (body extends player_class):
		body.can_climb_left = true

func _on_Ladder_body_exit( body ):
	if (body extends player_class):
		body.can_climb_left = false
