extends Control 

@onready var video_player = $VideoStreamPlayer

func _on_video_stream_player_finished():
	# looping
	video_player.play() 
	
	# looping
	video_player.stream_position = 1.11
