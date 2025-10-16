extends CanvasLayer

@onready var _status_label: Label = $Root/TopLeft/StatusPanel/Margin/VBox/StatusLabel
@onready var _instructions_label: Label = $Root/BottomLeft/InstructionsPanel/Margin/InstructionsLabel
@onready var _message_label: Label = $Root/Center/MessageLabel
@onready var _ability_label: Label = $Root/TopLeft/StatusPanel/Margin/VBox/AbilityLabel

var _current_health := 3
var _max_health := 3
var _time_remaining := 0.0
var _altitude := 0.0
var _dash_feedback_timer := 0.0

func _ready() -> void:
    GameDirector.health_changed.connect(_on_health_changed)
    GameDirector.time_changed.connect(_on_time_changed)
    GameDirector.altitude_changed.connect(_on_altitude_changed)
    GameDirector.instructions_changed.connect(_on_instructions_changed)
    GameDirector.message_shown.connect(_on_message_shown)
    GameDirector.feedback.connect(_on_feedback)
    GameDirector.register_hud(self)
    _update_status()

func _process(delta: float) -> void:
    if _dash_feedback_timer > 0.0:
        _dash_feedback_timer = max(_dash_feedback_timer - delta, 0.0)
        if _dash_feedback_timer == 0.0:
            _ability_label.text = "Abilities: Dash ✓  |  Time Slow ✓"

func _on_health_changed(current: int, max_health: int) -> void:
    _current_health = current
    _max_health = max_health
    _update_status()

func _on_time_changed(remaining: float) -> void:
    _time_remaining = remaining
    _update_status()

func _on_altitude_changed(height: float) -> void:
    _altitude = height
    _update_status()

func _on_instructions_changed(text: String) -> void:
    _instructions_label.text = text

func _on_message_shown(text: String, duration: float) -> void:
    _message_label.text = text
    _message_label.modulate = Color(1, 1, 1, 1)
    _message_label.show()
    var tween := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    tween.tween_interval(duration)
    tween.tween_property(_message_label, "modulate:a", 0.0, 0.4)
    tween.tween_callback(_message_label.hide)

func _on_feedback(event: String) -> void:
    match event:
        "dash":
            _ability_label.text = "Dash activated!"
            _dash_feedback_timer = 1.2
        "time_slow":
            _ability_label.text = "Time slowing..."
            _dash_feedback_timer = 1.5
        "double_jump":
            _ability_label.text = "Double jump!"
            _dash_feedback_timer = 1.0
        _:
            pass

func _update_status() -> void:
    var hearts := ""
    for i in range(_max_health):
        hearts += "[+]" if i < _current_health else "[ ]"
    var minutes := int(_time_remaining) / 60
    var seconds := int(_time_remaining) % 60
    var altitude_meters := int(round(_altitude / 32.0))
    _status_label.text = "Hearts: %s\nTimer: %02d:%02d\nAltitude: %dm" % [hearts, minutes, seconds, altitude_meters]
    if _dash_feedback_timer <= 0.0:
        _ability_label.text = "Abilities: Dash ready | Time Slow ready"
