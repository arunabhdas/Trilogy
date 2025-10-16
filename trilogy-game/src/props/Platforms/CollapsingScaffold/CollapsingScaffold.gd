extends StaticBody2D

@export var collapse_delay := 0.6
@export var respawn_delay := 4.0
@export var fall_distance := 160.0

var _is_collapsing := false
var _original_position := Vector2.ZERO
var _original_disabled := false

@onready var _collision: CollisionShape2D = $CollisionShape2D
@onready var _trigger: Area2D = $Trigger
@onready var _timer: Timer = $CollapseTimer
@onready var _respawn_timer: Timer = $RespawnTimer

func _ready() -> void:
    _original_position = global_position
    _trigger.body_entered.connect(_on_trigger_body_entered)
    _timer.timeout.connect(_on_collapse_timeout)
    _respawn_timer.timeout.connect(_on_respawn_timeout)

func _on_trigger_body_entered(body: Node) -> void:
    if _is_collapsing:
        return
    if body.is_in_group("player"):
        _timer.start(collapse_delay)
        _is_collapsing = true

func _on_collapse_timeout() -> void:
    _collision.disabled = true
    var tween := create_tween()
    tween.tween_property(self, "position:y", position.y + fall_distance, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
    tween.tween_callback(_on_collapse_complete)

func _on_collapse_complete() -> void:
    hide()
    _respawn_timer.start(respawn_delay)

func _on_respawn_timeout() -> void:
    show()
    global_position = _original_position
    _collision.disabled = false
    _is_collapsing = false
