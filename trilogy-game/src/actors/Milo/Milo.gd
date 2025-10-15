extends CharacterBody2D

const BASE_GRAVITY := ProjectSettings.get_setting("physics/2d/default_gravity") as float

@export var move_speed := 200.0
@export var acceleration := 900.0
@export var air_acceleration := 600.0
@export var jump_velocity := -420.0
@export var coyote_time := 0.15
@export var jump_buffer_time := 0.2
@export var beam_snap_speed := 6.0
@export var max_vertical_fall_speed := 900.0

var _coyote_timer := 0.0
var _jump_buffer_timer := 0.0
var _on_beam := false
var _current_beam: Node = null
var _last_floor_check := false

@onready var _beam_detector: RayCast2D = $BeamDetector
@onready var _sprite: Node2D = $Sprite2D

func _ready() -> void:
    add_to_group("player")
    _beam_detector.add_exception(self)

func _physics_process(delta: float) -> void:
    _update_timers(delta)
    _apply_gravity(delta)
    _handle_horizontal_movement(delta)
    _scan_for_beam(delta)
    _handle_jump()
    velocity.y = clamp(velocity.y, -INF, max_vertical_fall_speed)
    move_and_slide()
    _post_move_updates()

func _update_timers(delta: float) -> void:
    _jump_buffer_timer = max(_jump_buffer_timer - delta, 0.0)
    _coyote_timer = max(_coyote_timer - delta, 0.0)

func _apply_gravity(delta: float) -> void:
    if is_on_floor():
        velocity.y = min(velocity.y, 0.0)
        _coyote_timer = coyote_time
    elif _on_beam:
        velocity.y = min(velocity.y + BASE_GRAVITY * delta * -0.2, 0.0)
        _coyote_timer = coyote_time
    else:
        velocity.y += BASE_GRAVITY * delta

func _handle_horizontal_movement(delta: float) -> void:
    var input_direction := Input.get_axis("move_left", "move_right")
    var target_speed := input_direction * move_speed
    var accel := acceleration if (is_on_floor() or _on_beam) else air_acceleration
    velocity.x = move_toward(velocity.x, target_speed, accel * delta)

func _scan_for_beam(delta: float) -> void:
    _beam_detector.force_raycast_update()
    if _beam_detector.is_colliding():
        var collider := _beam_detector.get_collider()
        if collider and collider.is_in_group("beam"):
            if not _on_beam:
                _on_beam = true
                _current_beam = collider
            _align_with_beam(delta)
            return
    _on_beam = false
    _current_beam = null

func _align_with_beam(delta: float) -> void:
    if _current_beam == null:
        return
    var target_x := _current_beam.global_position.x
    global_position.x = lerp(global_position.x, target_x, clamp(beam_snap_speed * delta, 0.0, 1.0))
    if _current_beam.has_method("get_motion_velocity"):
        var beam_velocity: Vector2 = _current_beam.get_motion_velocity()
        global_position += beam_velocity * delta

func _handle_jump() -> void:
    if Input.is_action_just_pressed("jump"):
        _jump_buffer_timer = jump_buffer_time
    if _jump_buffer_timer > 0.0 and _coyote_timer > 0.0:
        velocity.y = jump_velocity
        _jump_buffer_timer = 0.0
        _coyote_timer = 0.0
        _detach_from_beam()

func _post_move_updates() -> void:
    if not is_on_floor() and not _on_beam and velocity.y > 0.0:
        _coyote_timer = max(_coyote_timer - get_physics_process_delta_time(), 0.0)
    _last_floor_check = is_on_floor()

func _detach_from_beam() -> void:
    _on_beam = false
    _current_beam = null

func is_on_beam() -> bool:
    return _on_beam
