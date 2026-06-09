extends TextureButton

func _ready():
	hide() # Hide at start

func _on_timer_timeout():
	show() # Show when the timer off
