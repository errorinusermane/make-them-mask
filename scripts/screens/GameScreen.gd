extends Control

signal transition_requested(next_screen_name)

enum Step {
	SKIN,
	EYE,
	NOSE,
	MOUTH,
	EAR,
	HAIR,
	COMPLETED # 모든 단계가 완료되었음을 나타냄
}

var current_step: Step = Step.SKIN
var mask_data: Dictionary = {} # 현재 제작 중인 마스크의 데이터를 저장
var payout: int = 0 # 나중에 점수 계산에 사용될 변수

@onready var total_play_timer: Timer = $TotalPlayTimer
@onready var mask_creation_timer: Timer = $MaskCreationTimer
@onready var done_button: Button = $DoneButton
@onready var okay_button: Button = $PreviewLayer/OkayButton # OkayButton이 PreviewLayer의 자식이라고 가정
@onready var reset_button: Button = $ResetButton

func _ready() -> void:
	# 타이머 초기화 및 시작
	total_play_timer.start()
	mask_creation_timer.start()
	
	# 버튼 시그널 연결
	done_button.pressed.connect(_on_DoneButton_pressed)
	okay_button.pressed.connect(_on_OkayButton_pressed)
	reset_button.pressed.connect(_on_ResetButton_pressed)
	
	# 타이머 시그널 연결
	total_play_timer.timeout.connect(_on_TotalPlayTimer_timeout)
	mask_creation_timer.timeout.connect(_on_MaskCreationTimer_timeout)
	
	_update_ui_for_step()

func _update_ui_for_step() -> void:
	# 현재 단계에 따라 UI 요소의 가시성/상호작용 가능 여부를 업데이트합니다.
	
	# DONE 버튼은 모든 단계가 완료되었을 때만 활성화됩니다.
	done_button.disabled = (current_step != Step.COMPLETED)
	
	# OKAY 버튼은 모든 단계가 완료되면 비활성화됩니다.
	# (각 단계의 작업 완료 여부에 따라 추가적인 비활성화 로직이 필요할 수 있습니다.)
	okay_button.disabled = (current_step == Step.COMPLETED)
	
	print("현재 단계: ", Step.keys()[current_step])
	# 여기에 현재 작업 중인 파트를 시각적으로 강조하는 로직을 추가할 수 있습니다.

func _on_DoneButton_pressed() -> void:
	if current_step == Step.COMPLETED:
		print("마스크 제작 완료! 처리 중...")
		# 마스크 제작 타이머 리셋 및 재시작 (새로운 마스크 제작을 위해)
		mask_creation_timer.stop()
		mask_creation_timer.start()
		
		# 현재 단계 리셋 (새로운 마스크 제작을 위해)
		current_step = Step.SKIN
		mask_data.clear() # 마스크 데이터 초기화
		_update_ui_for_step()
		
		# 여기에 결과 화면으로 전환하는 등의 후속 로직을 추가합니다.
		# transition_requested.emit("result")
	else:
		print("아직 DONE 버튼을 누를 수 없습니다. 모든 단계를 완료하세요.")

func _on_OkayButton_pressed() -> void:
	if current_step < Step.HAIR: # HAIR 단계를 넘어가지 않도록
		# 실제 게임에서는 현재 단계의 작업이 완료되었는지 확인하는 로직이 필요합니다.
		# 예: if _is_current_step_task_done():
		current_step = Step.values()[current_step + 1]
		_update_ui_for_step()
		print("다음 단계로 진행합니다.")
	elif current_step == Step.HAIR:
		print("모든 파트(SKIN부터 HAIR까지)가 완료되었습니다. 마스크를 완성할 준비가 되었습니다.")
		current_step = Step.COMPLETED
		_update_ui_for_step()
	else:
		print("모든 단계가 이미 완료되었습니다.")

func _on_ResetButton_pressed() -> void:
	print("마스크 제작을 리셋합니다.")
	current_step = Step.SKIN
	mask_data.clear()
	mask_creation_timer.stop()
	mask_creation_timer.start()
	_update_ui_for_step()

func _on_TotalPlayTimer_timeout() -> void:
	print("전체 플레이 시간이 종료되었습니다! 게임 오버.")
	transition_requested.emit("game_over") # "game_over" 화면으로 전환한다고 가정

func _on_MaskCreationTimer_timeout() -> void:
	print("마스크 제작 시간이 초과되었습니다! 마스크 제작 실패.")
	# 마스크 실패 처리 (예: 현재 마스크 리셋, 플레이어에게 페널티 부여 등)
	current_step = Step.SKIN # 새로운 시도를 위해 리셋
	mask_data.clear()
	mask_creation_timer.stop()
	mask_creation_timer.start() # 새로운 마스크를 위해 타이머 재시작
	_update_ui_for_step()

# 예시: 게임 오버 또는 클리어 시 결과 화면으로 전환 (백업)
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		transition_requested.emit("result")