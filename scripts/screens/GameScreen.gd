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
var player_eye_size: int = 0  # 0=S, 1=M, 2=L, 3=XL, 4=XXL
var target_eye_shape: String = "dog"
var target_eye_color: String = "blue"
var target_eye_brow: String = "up"
var target_eye_lash: String = "out"
var target_eye_size: int = 3

# Nose 단계 변수
var player_nose_size: int = 0  # 0=S, 1=M, 2=L, 3=XL, 4=XXL
var target_nose_size: int = 3
var nose_is_animating: bool = false  # stop button으로 애니메이션 제어
var nose_animation_timer: float = 0.0
var nose_animation_speed: float = 0.1  # 레벨 변경 간격(초)

# Mouth 단계 변수
var player_mouth_size: int = 2  # 0=S, 1=M, 2=L, 3=XL, 4=XXL
var target_mouth_size: int = 3
var mouth_is_animating: bool = false  # lever로 애니메이션 제어
var mouth_animation_timer: float = 0.0
var mouth_animation_speed: float = 0.08  # 레벨 변경 간격(초)
var mouth_direction: int = 1  # 1=오른쪽(증가), -1=왼쪽(감소)

# Ear 단계 변수
var player_ear_position: String = ""  # "top"(엘프귀), "middle"(일반), "bottom"(부처님 귀)
var player_ear_size: int = 0  # 0=S, 1=M, 2=L, 3=XL, 4=XXL
var target_ear_position: String = "middle"
var target_ear_size: int = 2

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

# NOSE 단계 노드
@onready var nose_layer: TextureRect = $NoseLayer
@onready var nose_stop_button: Button = $NoseLayer/NoseStopButton
@onready var nose_slider: TextureRect = $NoseLayer/NoseSlider
@onready var nose_stop_arrow: TextureRect = $NoseLayer/NoseStopArrow

# MOUTH 단계 노드
@onready var mouth_layer: TextureRect = $MouthLayer
@onready var mouth_lever: Button = $MouthLayer/MouthLever
@onready var mouth_size_chart: TextureRect = $MouthLayer/MouthSizeChart
@onready var mouth_size_arrow: TextureRect = $MouthLayer/MouthSizeArrow

# EAR 단계 노드
@onready var ear_layer: TextureRect = $EarLayer
@onready var ear_direction: TextureRect = $EarLayer/EarDirection
@onready var ear_direction_top_btn: Button = $EarLayer/EarDirectionTopButton
@onready var ear_direction_middle_btn: Button = $EarLayer/EarDirectionMiddleButton
@onready var ear_direction_bottom_btn: Button = $EarLayer/EarDirectionBottomButton
@onready var ear_slider: VSlider = $EarLayer/EarSlider
@onready var ear_handle: TextureRect = $EarLayer/EarSlider/EarHandle

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

var nose_layer_texture: Texture2D = preload("res://assets/production/nose/nose_layer.svg")
var nose_slider_texture: Texture2D = preload("res://assets/production/nose/nose_slider.png")
var nose_stop_button_texture: Texture2D = preload("res://assets/production/nose/nose_stop_button.svg")
var nose_stop_arrow_texture: Texture2D = preload("res://assets/production/nose/nose_stop_arrow.svg")

var mouth_layer_texture: Texture2D = preload("res://assets/production/mouth/mouth_layer.svg")
var mouth_lever_texture: Texture2D = preload("res://assets/production/mouth/mouth_lever.svg")
var mouth_size_chart_texture: Texture2D = preload("res://assets/production/mouth/mouth_size_chart.svg")
var mouth_size_arrow_texture: Texture2D = preload("res://assets/production/mouth/mouth_size_arrow.svg")

var ear_layer_texture: Texture2D = preload("res://assets/production/ear/ear_layer.svg")
var ear_direction_texture: Texture2D = preload("res://assets/production/ear/ear_direction.svg")
var ear_direction_picker_texture: Texture2D = preload("res://assets/production/ear/ear_direction_picker.svg")
var ear_slider_texture: Texture2D = preload("res://assets/production/ear/ear_slider.png")
var ear_handle_texture: Texture2D = preload("res://assets/production/ear/ear_handle.svg")

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
	
	# NOSE 버튼 시그널 연결
	nose_stop_button.pressed.connect(_on_nose_stop_button_pressed)
	
	# MOUTH 버튼 시그널 연결
	mouth_lever.pressed.connect(_on_mouth_lever_pressed)
	
	# EAR 버튼 시그널 연결
	ear_direction_top_btn.pressed.connect(_on_ear_direction_changed.bind("top"))
	ear_direction_middle_btn.pressed.connect(_on_ear_direction_changed.bind("middle"))
	ear_direction_bottom_btn.pressed.connect(_on_ear_direction_changed.bind("bottom"))
	ear_slider.value_changed.connect(_on_ear_slider_value_changed)
	ear_slider.drag_ended.connect(_on_ear_slider_drag_ended)
	
	# 핸들 텍스처 설정
	ear_handle.texture = ear_handle_texture
	
	# 초기화
	_initialize_skin_ui()
	_initialize_eye_ui()
	_initialize_nose_ui()
	_initialize_mouth_ui()
	_initialize_ear_ui()
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

func _initialize_nose_ui() -> void:
	# 초기값 설정
	player_nose_size = 0  # 가장 밑(S)
	nose_is_animating = false
	nose_animation_timer = 0.0
	
	# 슬라이더 초기 위치 업데이트
	_update_nose_slider_position()

func _initialize_mouth_ui() -> void:
	# 초기값 설정
	player_mouth_size = 2  # L (중간)
	mouth_is_animating = false
	mouth_animation_timer = 0.0
	mouth_direction = 1  # 오른쪽으로 시작
	
	# 화살표 초기 위치 업데이트
	_update_mouth_arrow_position()

func _initialize_ear_ui() -> void:
	# 초기값 설정 - 전체 비활성화 상태
	player_ear_position = ""
	player_ear_size = 0  # S
	
	# 슬라이더 범위: 0~4 (5단계: S/M/L/XL/XXL)
	ear_slider.min_value = 0
	ear_slider.max_value = 4
	ear_slider.step = 1
	ear_slider.tick_count = 5
	ear_slider.ticks_on_borders = true
	
	# 초기값 설정
	ear_slider.value = 0
	ear_slider.editable = false  # 위치 선택 전까지 비활성화
	
	# 모든 버튼 비활성 표시
	_update_ear_button_states()
	
	# 초기 핸들 위치 업데이트
	_update_ear_handle_position()

func _process(delta: float) -> void:
	if current_step == Step.NOSE and nose_is_animating:
		nose_animation_timer += delta
		
		if nose_animation_timer >= nose_animation_speed:
			nose_animation_timer = 0.0
			
			# 레벨 증가: S(0) -> M(1) -> L(2) -> XL(3) -> XXL(4) -> S(0) 루프
			player_nose_size += 1
			if player_nose_size > 4:
				player_nose_size = 0
			
			_update_nose_slider_position()
			
			var size_names = ["S", "M", "L", "XL", "XXL"]
			print("코 크기 변경: %s (%d)" % [size_names[player_nose_size], player_nose_size])
	
	if current_step == Step.MOUTH and mouth_is_animating:
		mouth_animation_timer += delta
		
		if mouth_animation_timer >= mouth_animation_speed:
			mouth_animation_timer = 0.0
			
			# 방향에 따라 증가/감소: S(0) ↔ M(1) ↔ L(2) ↔ XL(3) ↔ XXL(4)
			player_mouth_size += mouth_direction
			
			# 경계에 도달하면 방향 반전
			if player_mouth_size >= 4:
				player_mouth_size = 4
				mouth_direction = -1  # 왼쪽으로
			elif player_mouth_size <= 0:
				player_mouth_size = 0
				mouth_direction = 1  # 오른쪽으로
			
			_update_mouth_arrow_position()
			
			var size_names = ["S", "M", "L", "XL", "XXL"]
			print("입 크기 변경: %s (%d)" % [size_names[player_mouth_size], player_mouth_size])

func _update_nose_slider_position() -> void:
	if not nose_slider or not nose_stop_arrow:
		return
	
	# 세로 슬라이더: 5단계 (S=0 -> XXL=4)
	# 슬라이더 배경의 높이를 기준으로 5단계로 나눔
	# 아래(S)에서 위(XXL)로 이동
	var slider_height = nose_slider.size.y
	var arrow_height = nose_stop_arrow.size.y
	
	# 5단계로 나누기 (0~4)
	var step_height = slider_height / 5.0
	
	# player_nose_size: 0(S)=아래, 4(XXL)=위
	# Y 위치는 위가 작고 아래가 큼
	var y_position = slider_height - (player_nose_size + 0.5) * step_height - arrow_height / 2.0
	
	nose_stop_arrow.position.y = y_position

func _update_mouth_arrow_position() -> void:
	if not mouth_size_chart or not mouth_size_arrow:
		return
	
	# 차트는 5개 구역으로 나뉨 (S, M, L, XL, XXL)
	# 화살표는 회전하면서 각 구역을 가리킴
	# 0(S) = -72도, 1(M) = -36도, 2(L) = 0도, 3(XL) = 36도, 4(XXL) = 72도
	var angle_step = 36.0  # 각 단계마다 36도
	var base_angle = -72.0  # S의 시작 각도
	var target_angle = base_angle + (player_mouth_size * angle_step)
	
	# 화살표 회전 (deg_to_rad 사용)
	mouth_size_arrow.rotation = deg_to_rad(target_angle)

func _on_nose_stop_button_pressed() -> void:
	if current_step != Step.NOSE:
		return
	
	# 첫 번째 클릭: 애니메이션 시작
	# 두 번째 클릭: 애니메이션 멈춤
	nose_is_animating = !nose_is_animating
	
	if nose_is_animating:
		print("코 크기 애니메이션 시작")
	else:
		var size_names = ["S", "M", "L", "XL", "XXL"]
		print("코 크기 애니메이션 멈춤: %s (%d)" % [size_names[player_nose_size], player_nose_size])

func _on_mouth_lever_pressed() -> void:
	if current_step != Step.MOUTH:
		return
	
	# 토글: 애니메이션 시작/멈춤
	mouth_is_animating = !mouth_is_animating
	
	if mouth_is_animating:
		print("입 크기 애니메이션 시작")
	else:
		var size_names = ["S", "M", "L", "XL", "XXL"]
		print("입 크기 애니메이션 멈춤: %s (%d)" % [size_names[player_mouth_size], player_mouth_size])

func _on_ear_direction_changed(ear_position: String) -> void:
	if current_step != Step.EAR:
		return
	
	# 다른 위치를 선택하면 슬라이더 초기화
	if player_ear_position != ear_position:
		player_ear_position = ear_position
		player_ear_size = 0  # S로 리셋
		ear_slider.value = 0
		ear_slider.editable = true  # 슬라이더 활성화
		
		var position_names = {"top": "엘프귀", "middle": "일반", "bottom": "부처님 귀"}
		print("귀 위치 선택: %s" % position_names[ear_position])
	
	# 버튼 상태 업데이트
	_update_ear_button_states()
	_update_ear_handle_position()

func _on_ear_slider_value_changed(value: float) -> void:
	if current_step != Step.EAR:
		return
	
	player_ear_size = int(value)
	_update_ear_handle_position()
	
	var size_names = ["S", "M", "L", "XL", "XXL"]
	print("귀 크기 변경: %s (%d)" % [size_names[player_ear_size], player_ear_size])

func _on_ear_slider_drag_ended(_value_changed: bool) -> void:
	if current_step != Step.EAR:
		return
	# 이미 step=1이므로 정수값으로 스냅됨
	pass

func _update_ear_button_states() -> void:
	# 선택된 버튼만 활성 표시 (시각적 피드백은 나중에 추가 가능)
	# 지금은 기본 동작만 구현
	pass

func _update_ear_handle_position() -> void:
	if not ear_slider or not ear_handle:
		return
	
	# 세로 슬라이더: 5단계 (S=0 -> XXL=4)
	# 아래(S)에서 위(XXL)로 이동
	var slider_range = ear_slider.max_value - ear_slider.min_value
	if slider_range == 0:
		return
	
	var normalized_value = (ear_slider.value - ear_slider.min_value) / slider_range
	var track_length = ear_slider.size.y
	var handle_height = ear_handle.size.y
	
	# 세로 슬라이더는 위가 max, 아래가 min이므로 반전
	ear_handle.position.y = (1.0 - normalized_value) * (track_length - handle_height)
	ear_handle.position.x = (ear_slider.size.x - ear_handle.size.x) / 2

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
	
	# NOSE 단계
	var is_nose_step = (current_step == Step.NOSE)
	if nose_layer:
		nose_layer.visible = is_nose_step
	if is_nose_step:
		nose_stop_button.disabled = false
	else:
		# NOSE 단계가 아니면 애니메이션 중지
		nose_is_animating = false
	
	# MOUTH 단계
	var is_mouth_step = (current_step == Step.MOUTH)
	if mouth_layer:
		mouth_layer.visible = is_mouth_step
	if is_mouth_step:
		mouth_lever.disabled = false
	else:
		# MOUTH 단계가 아니면 애니메이션 중지
		mouth_is_animating = false
	
	# EAR 단계
	var is_ear_step = (current_step == Step.EAR)
	if ear_layer:
		ear_layer.visible = is_ear_step
	if is_ear_step:
		ear_direction_top_btn.disabled = false
		ear_direction_middle_btn.disabled = false
		ear_direction_bottom_btn.disabled = false
	
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
		# 애니메이션 중지
		nose_is_animating = false
		
		# 점수 계산
		var nose_score = 0
		if player_nose_size == target_nose_size:
			nose_score = 100
		else:
			# 거리에 따라 점수 차감
			var distance = abs(player_nose_size - target_nose_size)
			nose_score = max(0, 100 - distance * 25)
		
		# 최종 값 저장
		mask_data["nose_size"] = player_nose_size
		mask_data["nose_score"] = nose_score
		payout += nose_score
		
		var size_names = ["S", "M", "L", "XL", "XXL"]
		print("코 저장: 크기=%s | 점수: %d | 총점: %d" % [
			size_names[player_nose_size], nose_score, payout
		])
		
		current_step = Step.MOUTH
		_update_ui_for_step()
	
	elif current_step == Step.MOUTH:
		# 애니메이션 중지
		mouth_is_animating = false
		
		# 점수 계산
		var mouth_score = 0
		if player_mouth_size == target_mouth_size:
			mouth_score = 100
		else:
			# 거리에 따라 점수 차감
			var distance = abs(player_mouth_size - target_mouth_size)
			mouth_score = max(0, 100 - distance * 25)
		
		# 최종 값 저장
		mask_data["mouth_size"] = player_mouth_size
		mask_data["mouth_score"] = mouth_score
		payout += mouth_score
		
		var size_names = ["S", "M", "L", "XL", "XXL"]
		print("입 저장: 크기=%s | 점수: %d | 총점: %d" % [
			size_names[player_mouth_size], mouth_score, payout
		])
		
		current_step = Step.EAR
		_update_ui_for_step()
	
	elif current_step == Step.EAR:
		# 점수 계산
		var ear_score = 0
		
		# 위치를 선택하지 않으면 0점
		if player_ear_position == "":
			ear_score = 0
		else:
			# 위치 점수 (50점)
			if player_ear_position == target_ear_position:
				ear_score += 50
			
			# 크기 점수 (50점)
			if player_ear_size == target_ear_size:
				ear_score += 50
			else:
				var distance = abs(player_ear_size - target_ear_size)
				ear_score += max(0, 50 - distance * 12)
		
		# 최종 값 저장
		mask_data["ear_position"] = player_ear_position
		mask_data["ear_size"] = player_ear_size
		mask_data["ear_score"] = ear_score
		payout += ear_score
		
		var size_names = ["S", "M", "L", "XL", "XXL"]
		var position_names = {"top": "엘프귀", "middle": "일반", "bottom": "부처님 귀", "": "선택 안함"}
		print("귀 저장: 위치=%s 크기=%s | 점수: %d | 총점: %d" % [
			position_names[player_ear_position], 
			size_names[player_ear_size] if player_ear_position != "" else "N/A",
			ear_score, payout
		])
		
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
	
	# NOSE 리셋
	player_nose_size = 0
	nose_is_animating = false
	nose_animation_timer = 0.0
	
	# MOUTH 리셋
	player_mouth_size = 2
	mouth_is_animating = false
	mouth_animation_timer = 0.0
	mouth_direction = 1
	
	# EAR 리셋
	player_ear_position = ""
	player_ear_size = 0
	
	mask_creation_timer.stop()
	mask_creation_timer.start()
	_initialize_skin_ui()
	_initialize_eye_ui()
	_initialize_nose_ui()
	_initialize_mouth_ui()
	_initialize_ear_ui()
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
	
	# NOSE 리셋
	player_nose_size = 0
	nose_is_animating = false
	nose_animation_timer = 0.0
	
	# MOUTH 리셋
	player_mouth_size = 2
	mouth_is_animating = false
	mouth_animation_timer = 0.0
	mouth_direction = 1
	
	# EAR 리셋
	player_ear_position = ""
	player_ear_size = 0
	
	mask_creation_timer.start()
	_initialize_skin_ui()
	_initialize_eye_ui()
	_initialize_nose_ui()
	_initialize_mouth_ui()
	_initialize_ear_ui()
	_update_ui_for_step()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		transition_requested.emit("result")
