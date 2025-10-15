extends AnimatableBody2D

@export var width := 96.0
@export var thickness := 16.0

var _previous_global_position := Vector2.ZERO
var _motion_velocity := Vector2.ZERO

func _ready() -> void:
    add_to_group("beam")
    _previous_global_position = global_position
    physics_process_priority = -1

func _physics_process(delta: float) -> void:
    var current_position := global_position
    _motion_velocity = (current_position - _previous_global_position) / max(delta, 0.000001)
    _previous_global_position = current_position

func get_motion_velocity() -> Vector2:
    return _motion_velocity
