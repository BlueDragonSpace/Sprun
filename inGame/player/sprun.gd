extends Control

@export var visual_rotation = 0:
	set(new):
		self.rotation = new
		$Icon.rotation = -new
		# no matter what the Sprun's rotation is, the art will point upward
		
		visual_rotation = new
