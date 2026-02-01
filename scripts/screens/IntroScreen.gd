extends Control

signal transition_requested(next_screen_name)

# 효과음 리소스
var sound_button_next: AudioStream = preload("res://assets/sounds/sound_button_next.mp3")

# 효과음 플레이어
var audio_player: AudioStreamPlayer

func _ready() -> void:
	print("IntroScreen: _ready")
	
	# 효과음 플레이어 생성
	audio_player = AudioStreamPlayer.new()
	audio_player.volume_db = 0.0  # 볼륨 설정 (0dB = 원본 볼륨)
	add_child(audio_player)
	
	if has_node("NextButton"):
		print("IntroScreen: NextButton found")
		$NextButton.pressed.connect(func(): 
			print("IntroScreen: NextButton pressed")
			_play_sound(sound_button_next)
			transition_requested.emit("menu")
		)
	else:
		print("IntroScreen: NextButton NOT found")

func _play_sound(sound: AudioStream) -> void:
	if audio_player and sound:
		audio_player.stream = sound
		audio_player.play()

# 예시: 클릭하거나 엔터 키를 누르면 메뉴 화면으로 전환
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		print("IntroScreen: Unhandled Click at ", event.position)

	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed):
		print("IntroScreen: Input triggers transition")
		_play_sound(sound_button_next)
		transition_requested.emit("menu")
