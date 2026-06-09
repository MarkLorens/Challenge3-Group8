extends TextureButton

func _ready():
	hide() # Hide it at the start

func _on_timer_timeout():
	show() # Show it when the timer goes off
