extends Control

signal transition_requested(next_screen_name)

func _ready() -> void:
	print("ConversationScreen: _ready")
	# NextButton 연결 (이미지는 .tscn에서 설정)
	if has_node("NextButton"):
		print("ConversationScreen: NextButton found")
		$NextButton.pressed.connect(func(): 
			print("ConversationScreen: NextButton pressed, transitioning to game")
			transition_requested.emit("game")
		)
	else:
		print("ConversationScreen: NextButton NOT found")
	
	# SkipButton 연결 (이미지는 .tscn에서 설정)
	if has_node("SkipButton"):
		print("ConversationScreen: SkipButton found")
		$SkipButton.pressed.connect(func():
			print("ConversationScreen: SkipButton pressed, transitioning to game")
			transition_requested.emit("game")
		)
	else:
		print("ConversationScreen: SkipButton NOT found")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		print("ConversationScreen: UI Accept pressed (keyboard), triggering transition.")
		transition_requested.emit("game")