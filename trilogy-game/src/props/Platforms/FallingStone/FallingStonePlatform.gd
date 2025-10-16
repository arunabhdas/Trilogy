extends AnimatableBody2D

@export var fall_delay := 0.3
@export var gravity := 1600.0
@export var max_fall_speed := 900.0
@export var respawn_delay := 5.0

var _falling := false
var _velocity := Vector2.ZERO
var _start_position := Vector2.ZERO
var _start_local_position := Vector2.ZERO

@onready var _trigger: Area2D = $Trigger
@onready var _timer: Timer = $FallTimer
@onready var _respawn_timer: Timer = $RespawnTimer
@onready var _collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
    add_to_group("moving_platform")
    _start_position = global_position
    _start_local_position = position
    _trigger.body_entered.connect(_on_trigger_body_entered)
    _timer.timeout.connect(_on_fall_timeout)
    _respawn_timer.timeout.connect(_on_respawn_timeout)
    set_physics_process_priority(-1)

func _on_trigger_body_entered(body: Node) -> void:
    if _falling:
        return
    if body.is_in_group("player"):
        _timer.start(fall_delay)

func _on_fall_timeout() -> void:
    _falling = true

func _physics_process(delta: float) -> void:
    if not _falling:
        return
    _velocity.y = min(_velocity.y + gravity * delta, max_fall_speed)
    position += _velocity * delta
    if global_position.y > _start_position.y + 800.0:
        hide()
        _collision.disabled = true
        _respawn_timer.start(respawn_delay)
        _falling = false
        _velocity = Vector2.ZERO

func _on_respawn_timeout() -> void:
    position = _start_local_position
    global_position = _start_position
    show()
    _collision.disabled = false

func reset_platform() -> void:
    _timer.stop()
    _respawn_timer.stop()
    _falling = false
    _velocity = Vector2.ZERO
    position = _start_local_position
    global_position = _start_position
    show()
    _collision.disabled = false
