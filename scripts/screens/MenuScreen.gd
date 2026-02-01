extends Control

signal transition_requested(next_screen_name)

# 효과음 리소스
var sound_button_next: AudioStream = preload("res://assets/sounds/sound_button_next.mp3")

# 효과음 플레이어
var audio_player: AudioStreamPlayer

func _ready() -> void:
	print("MenuScreen: _ready")
	
	# 효과음 플레이어 생성
	audio_player = AudioStreamPlayer.new()
	audio_player.volume_db = 0.0  # 볼륨 설정
	add_child(audio_player)

	# 배경 이미지는 MenuScreen.tscn에서 직접 설정됩니다.

	# StartButton 연결
	if has_node("ActionButtons/StartButton"):
		print("MenuScreen: StartButton found")
		$ActionButtons/StartButton.pressed.connect(func():
			print("MenuScreen: StartButton pressed, transitioning to conversation")
			_play_sound(sound_button_next)
			transition_requested.emit("conversation")
		)
	else:
		print("MenuScreen: StartButton NOT found")
	# BookButton 연결
	if has_node("ActionButtons/BookButton"):
		print("MenuScreen: BookButton found")
		$ActionButtons/BookButton.pressed.connect(func():
			print("MenuScreen: BookButton pressed, transitioning to conversation")
			_play_sound(sound_button_next)
			transition_requested.emit("conversation")
		)
	else:
		print("MenuScreen: BookButton NOT found")
	# ExitButton 연결
	if has_node("ActionButtons/ExitButton"):
		print("MenuScreen: ExitButton found")
		$ActionButtons/ExitButton.pressed.connect(func():
			print("MenuScreen: ExitButton pressed, transitioning to conversation")
			_play_sound(sound_button_next)
			transition_requested.emit("conversation")
		)
	else:
		print("MenuScreen: ExitButton NOT found")

func _play_sound(sound: AudioStream) -> void:
	if audio_player and sound:
		audio_player.stream = sound
		audio_player.play()

# 예시: 엔터 키를 누르면 대화 화면으로 전환
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		print("MenuScreen: UI Accept pressed (keyboard) or unhandled mouse click, triggering transition.")
		_play_sound(sound_button_next)
		transition_requested.emit("conversation")