extends Control

signal transition_requested(next_screen_name)

enum Step {
	SKIN,
	EYE,
	NOSE,
	MOUTH,
	EAR,
	HAIR,
	COMPLETED
}

var current_step: Step = Step.SKIN
var mask_data: Dictionary = {}
var payout: int = 0

# Skin 단계 변수
var player_r: int = 0
var player_g: int = 0
var player_b: int = 0
var target_r: int = 100
var target_g: int = 150
var target_b: int = 200

# Eye 단계 변수
var player_eye_shape: String = "cat"  # cat, dog, rabbit
var player_eye_color: String = "black"  # black, blue, red
var player_eye_brow: String = "flat"  # down, flat, up
var player_eye_lash: String = "no"  # in, no, out
var player_eye_size: int = 2  # 0=S, 1=M, 2=L, 3=XL, 4=XXL
var target_eye_shape: String = "dog"
var target_eye_color: String = "blue"
var target_eye_brow: String = "up"
var target_eye_lash: String = "out"
var target_eye_size: int = 3

# 노드 참조
@onready var total_play_timer: Timer = $TotalPlayTimer
@onready var mask_creation_timer: Timer = $MaskCreationTimer
@onready var done_button: Button = $DoneButton
@onready var okay_button: Button = $PreviewLayer/OkayButton
@onready var reset_button: Button = $ResetButton

# SKIN 단계 노드
@onready var skin_layer: Control = $SkinLayer
@onready var red_slider: HSlider = $SkinLayer/RedSlider
@onready var green_slider: HSlider = $SkinLayer/GreenSlider
@onready var blue_slider: HSlider = $SkinLayer/BlueSlider
@onready var red_handle: TextureRect = $SkinLayer/RedSlider/RedHandle
@onready var green_handle: TextureRect = $SkinLayer/GreenSlider/GreenHandle
@onready var blue_handle: TextureRect = $SkinLayer/BlueSlider/BlueHandle

# EYE 단계 노드
@onready var eye_layer: TextureRect = $EyeLayer
@onready var eye_size_slider: HSlider = $EyeLayer/EyeSizeSlider
@onready var eye_size_handle: TextureRect = $EyeLayer/EyeSizeSlider/EyeSizeHandle

@onready var eye_shape_cat_btn: Button = $EyeLayer/ShapeCatButton
@onready var eye_shape_dog_btn: Button = $EyeLayer/ShapeDogButton
@onready var eye_shape_rabbit_btn: Button = $EyeLayer/ShapeRabbitButton

@onready var eye_color_black_btn: Button = $EyeLayer/ColorBlackButton
@onready var eye_color_blue_btn: Button = $EyeLayer/ColorBlueButton
@onready var eye_color_red_btn: Button = $EyeLayer/ColorRedButton

@onready var eye_brow_down_btn: Button = $EyeLayer/BrowDownButton
@onready var eye_brow_flat_btn: Button = $EyeLayer/BrowFlatButton
@onready var eye_brow_up_btn: Button = $EyeLayer/BrowUpButton

@onready var eye_lash_in_btn: Button = $EyeLayer/LashInButton
@onready var eye_lash_no_btn: Button = $EyeLayer/LashNoButton
@onready var eye_lash_out_btn: Button = $EyeLayer/LashOutButton
@onready var preview_head: TextureRect = $PreviewLayer/PreviewHead

# 텍스처 리소스
var skin_handle_texture: Texture2D = preload("res://assets/production/skin/skin_handle.svg")

var eye_shape_cat: Texture2D = preload("res://assets/production/eye/eye_shape_cat.png")
var eye_shape_dog: Texture2D = preload("res://assets/production/eye/eye_shape_dog.png")
var eye_shape_rabbit: Texture2D = preload("res://assets/production/eye/eye_shape_rabbit.png")
var eye_color_black: Texture2D = preload("res://assets/production/eye/eye_color_black.png")
var eye_color_blue: Texture2D = preload("res://assets/production/eye/eye_color_blue.png")
var eye_color_red: Texture2D = preload("res://assets/production/eye/eye_color_red.png")
var eye_brow_down: Texture2D = preload("res://assets/production/eye/eye_brow_down.png")
var eye_brow_flat: Texture2D = preload("res://assets/production/eye/eye_brow_flat.png")
var eye_brow_up: Texture2D = preload("res://assets/production/eye/eye_brow_up.png")
var eye_lash_in: Texture2D = preload("res://assets/production/eye/eye_lash_in.png")
var eye_lash_no: Texture2D = preload("res://assets/production/eye/eye_lash_no.png")
var eye_lash_out: Texture2D = preload("res://assets/production/eye/eye_lash_out.png")
var eye_size_handle_texture: Texture2D = preload("res://assets/production/eye/eye_size_handle.svg")

func _ready() -> void:
	# 타이머 시작
	total_play_timer.start()
	mask_creation_timer.start()
	
	# 버튼 시그널 연결
	done_button.pressed.connect(_on_done_button_pressed)
	okay_button.pressed.connect(_on_okay_button_pressed)
	reset_button.pressed.connect(_on_reset_button_pressed)
	
	# 타이머 시그널 연결
	total_play_timer.timeout.connect(_on_total_play_timer_timeout)
	mask_creation_timer.timeout.connect(_on_mask_creation_timer_timeout)
	
	# 슬라이더 시그널 연결
	red_slider.value_changed.connect(_on_slider_value_changed)
	green_slider.value_changed.connect(_on_slider_value_changed)
	blue_slider.value_changed.connect(_on_slider_value_changed)
	
	red_slider.drag_ended.connect(_on_slider_drag_ended.bind(red_slider))
	green_slider.drag_ended.connect(_on_slider_drag_ended.bind(green_slider))
	blue_slider.drag_ended.connect(_on_slider_drag_ended.bind(blue_slider))
	
	# 핸들 텍스처 설정
	red_handle.texture = skin_handle_texture
	green_handle.texture = skin_handle_texture
	blue_handle.texture = skin_handle_texture
	eye_size_handle.texture = eye_size_handle_texture
	
	# EYE 버튼 시그널 연결
	eye_shape_cat_btn.pressed.connect(_on_eye_shape_changed.bind("cat"))
	eye_shape_dog_btn.pressed.connect(_on_eye_shape_changed.bind("dog"))
	eye_shape_rabbit_btn.pressed.connect(_on_eye_shape_changed.bind("rabbit"))
	
	eye_color_black_btn.pressed.connect(_on_eye_color_changed.bind("black"))
	eye_color_blue_btn.pressed.connect(_on_eye_color_changed.bind("blue"))
	eye_color_red_btn.pressed.connect(_on_eye_color_changed.bind("red"))
	
	eye_brow_down_btn.pressed.connect(_on_eye_brow_changed.bind("down"))
	eye_brow_flat_btn.pressed.connect(_on_eye_brow_changed.bind("flat"))
	eye_brow_up_btn.pressed.connect(_on_eye_brow_changed.bind("up"))
	
	eye_lash_in_btn.pressed.connect(_on_eye_lash_changed.bind("in"))
	eye_lash_no_btn.pressed.connect(_on_eye_lash_changed.bind("no"))
	eye_lash_out_btn.pressed.connect(_on_eye_lash_changed.bind("out"))
	
	eye_size_slider.value_changed.connect(_on_eye_size_value_changed)
	eye_size_slider.drag_ended.connect(_on_eye_size_drag_ended)
	
	# EYE 버튼 아이콘 설정
	eye_shape_cat_btn.icon = eye_shape_cat
	eye_shape_dog_btn.icon = eye_shape_dog
	eye_shape_rabbit_btn.icon = eye_shape_rabbit
	eye_color_black_btn.icon = eye_color_black
	eye_color_blue_btn.icon = eye_color_blue
	eye_color_red_btn.icon = eye_color_red
	eye_brow_down_btn.icon = eye_brow_down
	eye_brow_flat_btn.icon = eye_brow_flat
	eye_brow_up_btn.icon = eye_brow_up
	eye_lash_in_btn.icon = eye_lash_in
	eye_lash_no_btn.icon = eye_lash_no
	eye_lash_out_btn.icon = eye_lash_out
	
	# 초기화
	_initialize_skin_ui()
	_initialize_eye_ui()
	_update_ui_for_step()


func _initialize_skin_ui() -> void:
	# 슬라이더 범위: 0~250 (5단계: 0, 50, 100, 150, 200, 250)
	red_slider.min_value = 0
	red_slider.max_value = 250
	red_slider.step = 1
	red_slider.tick_count = 6
	red_slider.ticks_on_borders = true
	
	green_slider.min_value = 0
	green_slider.max_value = 250
	green_slider.step = 1
	green_slider.tick_count = 6
	green_slider.ticks_on_borders = true
	
	blue_slider.min_value = 0
	blue_slider.max_value = 250
	blue_slider.step = 1
	blue_slider.tick_count = 6
	blue_slider.ticks_on_borders = true
	
	# 초기값 설정
	red_slider.value = 0
	green_slider.value = 0
	blue_slider.value = 0
	
	# 초기 핸들 위치 및 head 색상 업데이트
	_update_all_sliders()

func _initialize_eye_ui() -> void:
	# 슬라이더 범위: 0~4 (5단계: S/M/L/XL/XXL)
	eye_size_slider.min_value = 0
	eye_size_slider.max_value = 4
	eye_size_slider.step = 1
	eye_size_slider.tick_count = 5
	eye_size_slider.ticks_on_borders = true
	
	# 초기값 설정
	eye_size_slider.value = player_eye_size
	
	# 초기 핸들 위치 업데이트
	_update_handle_position(eye_size_slider, eye_size_handle)

func _update_ui_for_step() -> void:
	done_button.visible = false  # Done 버튼은 사용하지 않음
	okay_button.disabled = (current_step == Step.COMPLETED)
	
	# SKIN 단계
	var is_skin_step = (current_step == Step.SKIN)
	if skin_layer:
		skin_layer.visible = is_skin_step
	red_slider.editable = is_skin_step
	green_slider.editable = is_skin_step
	blue_slider.editable = is_skin_step
	
	# EYE 단계
	var is_eye_step = (current_step == Step.EYE)
	if eye_layer:
		eye_layer.visible = is_eye_step
	if is_eye_step:
		eye_size_slider.editable = true
		eye_shape_cat_btn.disabled = false
		eye_shape_dog_btn.disabled = false
		eye_shape_rabbit_btn.disabled = false
		eye_color_black_btn.disabled = false
		eye_color_blue_btn.disabled = false
		eye_color_red_btn.disabled = false
		eye_brow_down_btn.disabled = false
		eye_brow_flat_btn.disabled = false
		eye_brow_up_btn.disabled = false
		eye_lash_in_btn.disabled = false
		eye_lash_no_btn.disabled = false
		eye_lash_out_btn.disabled = false
	
	# COMPLETED 단계면 Result 씬으로 전환
	if current_step == Step.COMPLETED:
		print("모든 단계 완료! 총점: %d - Result 씬으로 이동" % payout)
		transition_requested.emit("result")
		return
	
	print("현재 단계: ", Step.keys()[current_step])

func _on_slider_value_changed(value: float) -> void:
	if current_step != Step.SKIN:
		return
	
	# 슬라이더 값 읽기 (0~250 범위)
	player_r = int(red_slider.value)
	player_g = int(green_slider.value)
	player_b = int(blue_slider.value)
	
	# PreviewHead 색상 업데이트 (0~1 범위로 변환)
	var current_color = Color(player_r / 255.0, player_g / 255.0, player_b / 255.0)
	preview_head.modulate = current_color
	
	# 핸들 위치 업데이트
	_update_handle_position(red_slider, red_handle)
	_update_handle_position(green_slider, green_handle)
	_update_handle_position(blue_slider, blue_handle)
	
	# 디버그 출력
	var distance = _calculate_rgb_distance(player_r, player_g, player_b, target_r, target_g, target_b)
	print("현재 피부색: R%d G%d B%d (거리: %d)" % [
		player_r, player_g, player_b, distance
	])

func _on_slider_drag_ended(_value_changed: bool, slider: HSlider) -> void:
	if current_step != Step.SKIN:
		return
	
	# 드래그 끝나면 5단계로 스냅
	var snapped_value = _snap_to_5_steps(slider.value)
	slider.value = snapped_value

func _snap_to_5_steps(value: float) -> float:
	var steps = [0.0, 50.0, 100.0, 150.0, 200.0, 250.0]
	var closest_step = steps[0]
	var min_distance = abs(value - closest_step)
	
	for step in steps:
		var distance = abs(value - step)
		if distance < min_distance:
			min_distance = distance
			closest_step = step
	
	return closest_step

func _update_handle_position(slider: HSlider, handle: TextureRect) -> void:
	if not slider or not handle:
		return
	
	var slider_range = slider.max_value - slider.min_value
	if slider_range == 0:
		return
	
	var normalized_value = (slider.value - slider.min_value) / slider_range
	var track_length = slider.size.x
	var handle_width = handle.size.x
	
	handle.position.x = normalized_value * (track_length - handle_width)
	handle.position.y = (slider.size.y - handle.size.y) / 2

func _update_all_sliders() -> void:
	_on_slider_value_changed(0)

func _calculate_rgb_distance(r1: int, g1: int, b1: int, r2: int, g2: int, b2: int) -> int:
	return abs(r1 - r2) + abs(g1 - g2) + abs(b1 - b2)

# === EYE 단계 함수 ===

func _on_eye_shape_changed(shape: String) -> void:
	if current_step != Step.EYE:
		return
	player_eye_shape = shape
	print("눈 모양 변경: %s" % shape)
	# TODO: PreviewHead에 실시간 반영

func _on_eye_color_changed(color: String) -> void:
	if current_step != Step.EYE:
		return
	player_eye_color = color
	print("눈 색상 변경: %s" % color)
	# TODO: PreviewHead에 실시간 반영

func _on_eye_brow_changed(brow: String) -> void:
	if current_step != Step.EYE:
		return
	player_eye_brow = brow
	print("눈썹 변경: %s" % brow)
	# TODO: PreviewHead에 실시간 반영

func _on_eye_lash_changed(lash: String) -> void:
	if current_step != Step.EYE:
		return
	player_eye_lash = lash
	print("속눈썹 변경: %s" % lash)
	# TODO: PreviewHead에 실시간 반영

func _on_eye_size_value_changed(value: float) -> void:
	if current_step != Step.EYE:
		return
	player_eye_size = int(value)
	_update_handle_position(eye_size_slider, eye_size_handle)
	var size_names = ["S", "M", "L", "XL", "XXL"]
	print("눈 크기 변경: %s (%d)" % [size_names[player_eye_size], player_eye_size])
	# TODO: PreviewHead에 실시간 반영

func _on_eye_size_drag_ended(_value_changed: bool) -> void:
	if current_step != Step.EYE:
		return
	# 이미 step=1이므로 정수값으로 스냅됨
	pass


func _on_done_button_pressed() -> void:
	# Done 버튼은 더 이상 사용하지 않음
	pass

func _on_okay_button_pressed() -> void:
	if current_step == Step.SKIN:
		# 조건 체크 없이 현재 선택한 값 저장
		var distance = _calculate_rgb_distance(player_r, player_g, player_b, target_r, target_g, target_b)
		
		# 최종 값 저장
		mask_data["skin_color"] = Color(player_r / 255.0, player_g / 255.0, player_b / 255.0)
		mask_data["skin_r"] = player_r
		mask_data["skin_g"] = player_g
		mask_data["skin_b"] = player_b
		
		# 점수 계산: 거리가 가까울수록 높은 점수 (0~100점)
		var skin_score = max(0, 100 - distance * 3)
		mask_data["skin_score"] = skin_score
		mask_data["skin_distance"] = distance
		payout += skin_score
		
		print("피부색 저장: R%d G%d B%d | 거리: %d | 점수: %d | 총점: %d" % [
			player_r, player_g, player_b, distance, skin_score, payout
		])
		
		current_step = Step.EYE
		_update_ui_for_step()
	
	elif current_step == Step.EYE:
		# 점수 계산
		var eye_score = 0
		var correct_count = 0
		
		if player_eye_shape == target_eye_shape:
			eye_score += 20
			correct_count += 1
		if player_eye_color == target_eye_color:
			eye_score += 20
			correct_count += 1
		if player_eye_brow == target_eye_brow:
			eye_score += 20
			correct_count += 1
		if player_eye_lash == target_eye_lash:
			eye_score += 20
			correct_count += 1
		if player_eye_size == target_eye_size:
			eye_score += 20
			correct_count += 1
		
		# 최종 값 저장
		mask_data["eye_shape"] = player_eye_shape
		mask_data["eye_color"] = player_eye_color
		mask_data["eye_brow"] = player_eye_brow
		mask_data["eye_lash"] = player_eye_lash
		mask_data["eye_size"] = player_eye_size
		mask_data["eye_score"] = eye_score
		mask_data["eye_correct_count"] = correct_count
		payout += eye_score
		
		var size_names = ["S", "M", "L", "XL", "XXL"]
		print("눈 저장: 모양=%s 색상=%s 눈썹=%s 속눈썹=%s 크기=%s | 정답: %d/5 | 점수: %d | 총점: %d" % [
			player_eye_shape, player_eye_color, player_eye_brow, player_eye_lash, 
			size_names[player_eye_size], correct_count, eye_score, payout
		])
		
		current_step = Step.NOSE
		_update_ui_for_step()
	
	elif current_step == Step.NOSE:
		# TODO: NOSE 커스터마이징 값 저장 및 점수 계산
		print("코 단계 완료 - 다음 단계로 진행")
		current_step = Step.MOUTH
		_update_ui_for_step()
	
	elif current_step == Step.MOUTH:
		# TODO: MOUTH 커스터마이징 값 저장 및 점수 계산
		print("입 단계 완료 - 다음 단계로 진행")
		current_step = Step.EAR
		_update_ui_for_step()
	
	elif current_step == Step.EAR:
		# TODO: EAR 커스터마이징 값 저장 및 점수 계산
		print("귀 단계 완료 - 다음 단계로 진행")
		current_step = Step.HAIR
		_update_ui_for_step()
	
	elif current_step == Step.HAIR:
		# TODO: HAIR 커스터마이징 값 저장 및 점수 계산
		print("머리 단계 완료 - 모든 커스터마이징 완료!")
		current_step = Step.COMPLETED
		_update_ui_for_step()

func _on_reset_button_pressed() -> void:
	print("마스크 제작 리셋 - 모든 점수 초기화")
	current_step = Step.SKIN
	mask_data.clear()
	payout = 0  # 점수 리셋
	
	# SKIN 리셋
	red_handle.visible = true
	green_handle.visible = true
	blue_handle.visible = true
	player_r = 0
	player_g = 0
	player_b = 0
	
	# EYE 리셋
	player_eye_shape = "cat"
	player_eye_color = "black"
	player_eye_brow = "flat"
	player_eye_lash = "no"
	player_eye_size = 2
	eye_size_handle.visible = true
	
	mask_creation_timer.stop()
	mask_creation_timer.start()
	_initialize_skin_ui()
	_initialize_eye_ui()
	_update_ui_for_step()
	print("총점 리셋: %d" % payout)

func _on_total_play_timer_timeout() -> void:
	print("전체 플레이 시간 종료")
	transition_requested.emit("game_over")

func _on_mask_creation_timer_timeout() -> void:
	print("마스크 제작 시간 초과 - 리셋")
	current_step = Step.SKIN
	mask_data.clear()
	payout = 0
	
	# SKIN 리셋
	red_handle.visible = true
	green_handle.visible = true
	blue_handle.visible = true
	player_r = 0
	player_g = 0
	player_b = 0
	
	# EYE 리셋
	player_eye_shape = "cat"
	player_eye_color = "black"
	player_eye_brow = "flat"
	player_eye_lash = "no"
	player_eye_size = 2
	eye_size_handle.visible = true
	
	mask_creation_timer.start()
	_initialize_skin_ui()
	_initialize_eye_ui()
	_update_ui_for_step()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		transition_requested.emit("result")
