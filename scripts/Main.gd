extends Node

@onready var screen_root = $CanvasLayer/ScreenRoot

const SCREENS = {
	"intro": "res://scenes/screens/IntroScreen.tscn",
	"menu": "res://scenes/screens/MenuScreen.tscn",
	"conversation": "res://scenes/screens/ConversationScreen.tscn",
	"game": "res://scenes/screens/GameScreen.tscn",
	"result": "res://scenes/screens/ResultScreen.tscn"
}

var current_screen: Node = null

func _ready() -> void:
	print("Main initialized. Setting up window...")
	
	# 해상도 1920x1080 설정 및 중앙 정렬
	get_window().size = Vector2i(1920, 1080)
	get_window().move_to_center()
	
	# 창 크기 변경 후 레이아웃 적용을 위해 한 프레임 뒤에 실행
	call_deferred("change_screen", "intro")

func change_screen(screen_name: String) -> void:
	if current_screen:
		current_screen.queue_free()
		current_screen = null
	
	if screen_name in SCREENS:
		var screen_path = SCREENS[screen_name]
		var screen_scene = load(screen_path)
		if screen_scene:
			current_screen = screen_scene.instantiate()
			screen_root.add_child(current_screen)
			# 추가된 화면이 부모(ScreenRoot)를 꽉 채우도록 강제 설정
			if current_screen is Control:
				current_screen.set_anchors_preset(Control.PRESET_FULL_RECT)
				current_screen.offset_left = 0
				current_screen.offset_top = 0
				current_screen.offset_right = 0
				current_screen.offset_bottom = 0
			if current_screen.has_signal("transition_requested"):
				current_screen.transition_requested.connect(_on_transition_requested)
		else:
			push_error("Failed to load screen: " + screen_name)

func _on_transition_requested(next_screen_name: String) -> void:
	print("Main: Transition requested to ", next_screen_name)
	change_screen(next_screen_name)
