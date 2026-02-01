extends Control

signal transition_requested(next_screen_name)

# 효과음 리소스
var sound_button_next: AudioStream = preload("res://assets/sounds/sound_button_next.mp3")

# Result 이미지 리소스
var receipt_texture: Texture2D = preload("res://assets/screens/result/order_receipt.png")
var rank_s_texture: Texture2D = preload("res://assets/screens/result/order_rank_s.svg")
var rank_b_texture: Texture2D = preload("res://assets/screens/result/order_rank_b.svg")
var rank_c_texture: Texture2D = preload("res://assets/screens/result/order_rank_c.svg")
var rank_d_texture: Texture2D = preload("res://assets/screens/result/order_rank_d.svg")
var rank_f_texture: Texture2D = preload("res://assets/screens/result/order_rank_f.svg")

# 효과음 플레이어
var audio_player: AudioStreamPlayer

# Result UI 노드
var background: ColorRect
var receipt_image: TextureRect
var rank_image: TextureRect

# 게임 점수 (GameScreen에서 전달받을 값)
var final_score: int = 0

func _ready() -> void:
	# 효과음 플레이어 생성
	audio_player = AudioStreamPlayer.new()
	audio_player.volume_db = 0.0  # 볼륨 설정
	add_child(audio_player)
	
	# 회색 배경 생성
	background = ColorRect.new()
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.color = Color(0.5, 0.5, 0.5, 1.0)  # 회색
	add_child(background)
	background.z_index = -1  # 맨 뒤로
	
	# Receipt 이미지 생성
	receipt_image = TextureRect.new()
	receipt_image.texture = receipt_texture
	receipt_image.set_anchors_preset(Control.PRESET_FULL_RECT)
	receipt_image.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	receipt_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	add_child(receipt_image)
	
	# Rank 이미지 생성 (처음엔 숨김)
	rank_image = TextureRect.new()
	rank_image.set_anchors_preset(Control.PRESET_CENTER)
	rank_image.expand_mode = TextureRect.EXPAND_KEEP_SIZE
	rank_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rank_image.visible = false
	add_child(rank_image)
	
	# 1초 후 랭크 표시
	await get_tree().create_timer(1.0).timeout
	_show_rank()

func set_score(score: int) -> void:
	final_score = score
	print("ResultScreen: 최종 점수 = %d" % final_score)

func _show_rank() -> void:
	# 점수를 5등급으로 나눔 (총점 500점 가정)
	# S: 400~500, B: 300~399, C: 200~299, D: 100~199, F: 0~99
	var rank_texture: Texture2D
	
	if final_score >= 400:
		rank_texture = rank_s_texture
		print("랭크: S")
	elif final_score >= 300:
		rank_texture = rank_b_texture
		print("랭크: B")
	elif final_score >= 200:
		rank_texture = rank_c_texture
		print("랭크: C")
	elif final_score >= 100:
		rank_texture = rank_d_texture
		print("랭크: D")
	else:
		rank_texture = rank_f_texture
		print("랭크: F")
	
	rank_image.texture = rank_texture
	rank_image.visible = true

func _play_sound(sound: AudioStream) -> void:
	if audio_player and sound:
		audio_player.stream = sound
		audio_player.play()

# 예시: 결과 확인 후 클릭 시 다시 인트로 화면으로 전환 (백업)
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed):
		_play_sound(sound_button_next)
		transition_requested.emit("intro")