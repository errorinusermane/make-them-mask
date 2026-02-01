extends Control

signal transition_requested(next_screen_name)

func _ready() -> void:
	$NextButton.icon = load("res://assets/global/button_next.svg")
	
	if has_node("NextButton"):
		$NextButton.pressed.connect(func(): transition_requested.emit("result"))

# 예시: 게임 오버 또는 클리어 시 결과 화면으로 전환 (백업)
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		transition_requested.emit("result")