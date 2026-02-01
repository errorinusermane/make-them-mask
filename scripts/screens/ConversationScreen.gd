extends Control

signal transition_requested(next_screen_name)

# 효과음 리소스
var sound_button_next: AudioStream = preload("res://assets/sounds/sound_button_next.mp3")

# 효과음 플레이어
var audio_player: AudioStreamPlayer

func _ready() -> void:
	print("ConversationScreen: _ready")
	
	# 효과음 플레이어 생성
	audio_player = AudioStreamPlayer.new()
	audio_player.volume_db = 0.0  # 볼륨 설정
	add_child(audio_player)
	
	# NextButton 연결 (이미지는 .tscn에서 설정)
	if has_node("NextButton"):
		print("ConversationScreen: NextButton found")
		$NextButton.pressed.connect(func(): 
			print("ConversationScreen: NextButton pressed, transitioning to game")
			_play_sound(sound_button_next)
			transition_requested.emit("game")
		)
	else:
		print("ConversationScreen: NextButton NOT found")
	
	# SkipButton 연결 (이미지는 .tscn에서 설정)
	if has_node("SkipButton"):
		print("ConversationScreen: SkipButton found")
		$SkipButton.pressed.connect(func():
			print("ConversationScreen: SkipButton pressed, transitioning to game")
			_play_sound(sound_button_next)
			transition_requested.emit("game")
		)
	else:
		print("ConversationScreen: SkipButton NOT found")

func _play_sound(sound: AudioStream) -> void:
	if audio_player and sound:
		audio_player.stream = sound
		audio_player.play()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		print("ConversationScreen: UI Accept pressed (keyboard), triggering transition.")
		_play_sound(sound_button_next)
		transition_requested.emit("game")