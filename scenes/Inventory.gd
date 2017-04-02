extends Node

class Inventory:
	var items = {}

	func add_item(name, quantity):
		var base_quantity = 0
		if self.items.has(name):
			base_quantity = self.items[name]
		self.items[name] = base_quantity + quantity

	func get_item(name):
		return self.items[name]

var inventory

func _ready():
	inventory = Inventory.new()