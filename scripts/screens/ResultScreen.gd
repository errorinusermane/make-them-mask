extends Control

signal transition_requested(next_screen_name)

# 효과음 리소스
var sound_button_next: AudioStream = preload("res://assets/sounds/sound_button_next.mp3")

# 효과음 플레이어
var audio_player: AudioStreamPlayer

func _ready() -> void:
	# 효과음 플레이어 생성
	audio_player = AudioStreamPlayer.new()
	audio_player.volume_db = 0.0  # 볼륨 설정
	add_child(audio_player)
	
	$Background.texture = load("res://assets/screens/result/background_result.svg")
	$NextButton.icon = load("res://assets/global/button_next.svg")
	
	if has_node("NextButton"):
		$NextButton.pressed.connect(func(): 
			_play_sound(sound_button_next)
			transition_requested.emit("intro")
		)

func _play_sound(sound: AudioStream) -> void:
	if audio_player and sound:
		audio_player.stream = sound
		audio_player.play()

# 예시: 결과 확인 후 클릭 시 다시 인트로 화면으로 전환 (백업)
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_play_sound(sound_button_next)
		transition_requested.emit("intro")