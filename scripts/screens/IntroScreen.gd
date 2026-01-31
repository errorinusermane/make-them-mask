extends Control

signal transition_requested(next_screen_name)

func _ready() -> void:
	print("IntroScreen: _ready")
	if has_node("NextButton"):
		print("IntroScreen: NextButton found")
		$NextButton.pressed.connect(func(): 
			print("IntroScreen: NextButton pressed")
			transition_requested.emit("menu")
		)
	else:
		print("IntroScreen: NextButton NOT found")

# 예시: 클릭하거나 엔터 키를 누르면 메뉴 화면으로 전환
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		print("IntroScreen: Unhandled Click at ", event.position)

	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed):
		print("IntroScreen: Input triggers transition")
		transition_requested.emit("menu")
