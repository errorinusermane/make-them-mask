extends Control

signal transition_requested(next_screen_name)

func _ready() -> void:
	$Background.texture = load("res://assets/screens/result/background_result.svg")
	$NextButton.icon = load("res://assets/global/button_next.svg")
	
	if has_node("NextButton"):
		$NextButton.pressed.connect(func(): transition_requested.emit("intro"))

# 예시: 결과 확인 후 클릭 시 다시 인트로 화면으로 전환 (백업)
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		transition_requested.emit("intro")