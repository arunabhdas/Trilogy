extends Node2D

@export var rope_length := 180.0
@export var swing_angle := 0.6
@export var swing_speed := 0.5
@export var phase_offset := 0.0

var _time := 0.0
var _previous_ball_pos := Vector2.ZERO
var _ball_velocity := Vector2.ZERO

@onready var _ball: AnimatableBody2D = $Ball
@onready var _line: Line2D = $Cable

func _ready() -> void:
    _ball.add_to_group("hazard")
    _ball.set_physics_process_priority(-1)
    _previous_ball_pos = _ball.global_position

func _physics_process(delta: float) -> void:
    _time += delta
    var angle := sin((_time + phase_offset) * TAU * swing_speed) * swing_angle
    var offset := Vector2(sin(angle), cos(angle)) * rope_length
    _ball.position = offset
    _line.points = PackedVector2Array([Vector2.ZERO, offset])
    var current_pos := _ball.global_position
    _ball_velocity = (current_pos - _previous_ball_pos) / max(delta, 0.000001)
    _previous_ball_pos = current_pos

func get_ball_velocity() -> Vector2:
    return _ball_velocity
