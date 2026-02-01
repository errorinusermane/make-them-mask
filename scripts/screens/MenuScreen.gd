extends Control

signal transition_requested(next_screen_name)

# 효과음 리소스
var sound_button_next: AudioStream = preload("res://assets/sounds/sound_button_next.mp3")

# Book 이미지 리소스
var book_image_texture: Texture2D = preload("res://assets/screens/menu/book_image.png")

# 효과음 플레이어
var audio_player: AudioStreamPlayer

# Book 팝업 노드
var book_popup_layer: Control
var book_popup_image: TextureRect

func _ready() -> void:
	print("MenuScreen: _ready")
	
	# 효과음 플레이어 생성
	audio_player = AudioStreamPlayer.new()
	audio_player.volume_db = 0.0  # 볼륨 설정
	add_child(audio_player)
	
	# Book 팝업 레이어 생성 (화면 전체 크기)
	book_popup_layer = Control.new()
	book_popup_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	book_popup_layer.mouse_filter = Control.MOUSE_FILTER_STOP  # 클릭 이벤트 받기
	book_popup_layer.visible = false  # 처음엔 숨김
	add_child(book_popup_layer)
	
	# 반투명 배경 (선택적)
	var background = ColorRect.new()
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.color = Color(0, 0, 0, 0.7)  # 검정 반투명
	book_popup_layer.add_child(background)
	
	# Book 이미지
	book_popup_image = TextureRect.new()
	book_popup_image.texture = book_image_texture
	book_popup_image.set_anchors_preset(Control.PRESET_FULL_RECT)  # 화면 전체 크기에 맞춤
	book_popup_image.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL  # 화면에 맞춤
	book_popup_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT  # 비율 유지
	book_popup_image.mouse_filter = Control.MOUSE_FILTER_PASS  # 클릭 이벤트가 부모로 전달되도록
	book_popup_layer.add_child(book_popup_image)
	
	# Book 팝업 클릭 시 닫기
	book_popup_layer.gui_input.connect(_on_book_popup_clicked)

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
			print("MenuScreen: BookButton pressed, showing book popup")
			_play_sound(sound_button_next)
			_show_book_popup()
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

func _show_book_popup() -> void:
	if book_popup_layer:
		book_popup_layer.visible = true
		print("Book popup opened")

func _hide_book_popup() -> void:
	if book_popup_layer:
		book_popup_layer.visible = false
		print("Book popup closed")

func _on_book_popup_clicked(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_hide_book_popup()

# 예시: 엔터 키를 누르면 대화 화면으로 전환
func _unhandled_input(event: InputEvent) -> void:
	# Book 팝업이 열려있으면 다른 입력 무시
	if book_popup_layer and book_popup_layer.visible:
		return
	
	if event.is_action_pressed("ui_accept"):
		print("MenuScreen: UI Accept pressed (keyboard) or unhandled mouse click, triggering transition.")
		_play_sound(sound_button_next)
		transition_requested.emit("conversation")