extends TileMap

func _ready():
	# Create a simple ground platform
	for x in range(-10, 10):
		set_cell(0, Vector2i(x, 5), 0, Vector2i(0, 0))
	
	# Add some platforms
	for x in range(-5, -2):
		set_cell(0, Vector2i(x, 3), 0, Vector2i(0, 0))
	
	for x in range(2, 5):
		set_cell(0, Vector2i(x, 3), 0, Vector2i(0, 0)) 