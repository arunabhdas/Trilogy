extends Node2D

@export var swing_range := 160.0
@export var swing_speed := 0.25
@export var lift_amplitude := 48.0
@export var anchor_drop := 96.0
@export var phase_offset := 0.0
@export var beam_scene: PackedScene

var _time := 0.0
var _beam: AnimatableBody2D

func _ready() -> void:
    add_to_group("crane")
    _ensure_beam_instance()

func _ensure_beam_instance() -> void:
    if _beam and is_instance_valid(_beam):
        return
    if has_node("Beam"):
        _beam = get_node("Beam") as AnimatableBody2D
    elif beam_scene:
        _beam = beam_scene.instantiate() as AnimatableBody2D
        _beam.name = "Beam"
        add_child(_beam)
    if _beam:
        _beam.position = Vector2(0, anchor_drop)

func _physics_process(delta: float) -> void:
    if not _beam:
        return
    _time += delta
    var swing := sin((_time + phase_offset) * TAU * swing_speed) * swing_range * 0.5
    var lift := cos((_time + phase_offset) * TAU * swing_speed * 0.7) * lift_amplitude
    _beam.position = Vector2(swing, anchor_drop + lift)
