extends CharacterBody2D

@export var move_speed := 240.0
@export var acceleration := 1200.0
@export var air_acceleration := 780.0
@export var jump_velocity := -460.0
@export var double_jump_velocity := -420.0
@export var coyote_time := 0.12
@export var jump_buffer_time := 0.18
@export var beam_snap_speed := 6.0
@export var max_vertical_fall_speed := 1200.0
@export var max_air_jumps := 1
@export var wall_slide_speed := -160.0
@export var dash_speed := 520.0
@export var dash_duration := 0.2
@export var dash_cooldown := 1.2
@export var invulnerability_time := 1.0
@export var time_slow_factor := 0.55
@export var time_slow_duration := 1.4
@export var time_slow_cooldown := 6.0

var _coyote_timer := 0.0
var _jump_buffer_timer := 0.0
var _air_jumps_remaining := 0
var _on_beam := false
var _current_beam: Node = null
var _base_gravity := 980.0
var _respawn_position := Vector2.ZERO
var _dash_time_remaining := 0.0
var _dash_cooldown_timer := 0.0
var _dash_direction := 0.0
var _invulnerability_timer := 0.0
var _time_slow_timer := 0.0
var _time_slow_cooldown_timer := 0.0

@onready var _beam_detector: RayCast2D = $BeamDetector
@onready var _hazard_detector: Area2D = $HazardDetector
@onready var _sprite: Node2D = $Sprite2D

func _ready() -> void:
	add_to_group("player")
	_beam_detector.add_exception(self)
	_hazard_detector.body_entered.connect(_on_hazard_hit)
	_hazard_detector.area_entered.connect(_on_hazard_area)
	_base_gravity = float(ProjectSettings.get_setting("physics/2d/default_gravity"))
	_respawn_position = global_position
	_air_jumps_remaining = max_air_jumps
	GameDirector.register_player(self)

func _exit_tree() -> void:
	_reset_time_scale()

func _physics_process(delta: float) -> void:
	_update_timers(delta)
	_handle_time_slow(delta)
	if _dash_time_remaining > 0.0:
		_handle_dash_motion(delta)
	else:
		_apply_gravity(delta)
		_handle_horizontal_movement(delta)
		_scan_for_beam(delta)
		_handle_jump()
		_consider_dash()
	velocity.y = clamp(velocity.y, -INF, max_vertical_fall_speed)
	move_and_slide()
	_post_move_updates(delta)
	GameDirector.register_altitude(-global_position.y)

func _update_timers(delta: float) -> void:
	_jump_buffer_timer = max(_jump_buffer_timer - delta, 0.0)
	_coyote_timer = max(_coyote_timer - delta, 0.0)
	_dash_cooldown_timer = max(_dash_cooldown_timer - delta, 0.0)
	_invulnerability_timer = max(_invulnerability_timer - delta, 0.0)
	_time_slow_cooldown_timer = max(_time_slow_cooldown_timer - delta, 0.0)

func _apply_gravity(delta: float) -> void:
	if is_on_floor():
		velocity.y = min(velocity.y, 0.0)
		_coyote_timer = coyote_time
		_air_jumps_remaining = max_air_jumps
	elif _on_beam:
		velocity.y = min(velocity.y + _base_gravity * delta * -0.2, 0.0)
		_coyote_timer = coyote_time
		_air_jumps_remaining = max_air_jumps
	else:
		velocity.y += _base_gravity * delta
		if is_on_wall() and velocity.y > wall_slide_speed:
			velocity.y = wall_slide_speed

func _handle_horizontal_movement(delta: float) -> void:
	var input_direction := Input.get_axis("move_left", "move_right")
	var target_speed := input_direction * move_speed
	var accel := acceleration if (is_on_floor() or _on_beam) else air_acceleration
	velocity.x = move_toward(velocity.x, target_speed, accel * delta)
	_sprite.scale.x = sign(velocity.x) if abs(velocity.x) > 5 else _sprite.scale.x

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
	_detach_from_beam()

func _align_with_beam(delta: float) -> void:
	if _current_beam == null:
		return
	var target_x: float = _current_beam.global_position.x
	global_position.x = lerp(global_position.x, target_x, clamp(beam_snap_speed * delta, 0.0, 1.0))
	if _current_beam.has_method("get_motion_velocity"):
		var beam_velocity: Vector2 = _current_beam.get_motion_velocity()
		global_position += beam_velocity * delta

func _handle_jump() -> void:
	if Input.is_action_just_pressed("jump"):
		_jump_buffer_timer = jump_buffer_time
	var can_jump := _coyote_timer > 0.0 or _on_beam or is_on_floor()
	if _jump_buffer_timer > 0.0 and can_jump:
		velocity.y = jump_velocity
		_jump_buffer_timer = 0.0
		_coyote_timer = 0.0
		_detach_from_beam()
		_air_jumps_remaining = max_air_jumps
	elif _jump_buffer_timer > 0.0 and _air_jumps_remaining > 0:
		velocity.y = double_jump_velocity
		_jump_buffer_timer = 0.0
		_air_jumps_remaining -= 1
		GameDirector.play_feedback("double_jump")

func _consider_dash() -> void:
	if not Input.is_action_just_pressed("dash") or _dash_cooldown_timer > 0.0:
		return
	var input_direction := Input.get_axis("move_left", "move_right")
	if input_direction == 0.0:
		input_direction = sign(_sprite.scale.x)
	_dash_direction = clamp(input_direction, -1.0, 1.0)
	if _dash_direction == 0.0:
		return
	_dash_time_remaining = dash_duration
	_dash_cooldown_timer = dash_cooldown
	velocity = Vector2(_dash_direction * dash_speed, 0.0)
	GameDirector.play_feedback("dash")
	_detach_from_beam()

func _handle_dash_motion(delta: float) -> void:
	_dash_time_remaining = max(_dash_time_remaining - delta, 0.0)
	velocity.x = _dash_direction * dash_speed
	velocity.y = 0.0
	if _dash_time_remaining <= 0.0:
		velocity.x *= 0.4

func _handle_time_slow(delta: float) -> void:
	if _time_slow_timer > 0.0:
		_time_slow_timer = max(_time_slow_timer - delta, 0.0)
		if _time_slow_timer <= 0.0:
			_reset_time_scale()
	elif Input.is_action_just_pressed("time_slow") and _time_slow_cooldown_timer <= 0.0:
		Engine.time_scale = time_slow_factor
		_time_slow_timer = time_slow_duration
		_time_slow_cooldown_timer = time_slow_cooldown
		GameDirector.play_feedback("time_slow")

func _reset_time_scale() -> void:
	if Engine.time_scale != 1.0:
		Engine.time_scale = 1.0

func _post_move_updates(delta: float) -> void:
	if not is_on_floor() and not _on_beam and velocity.y > 0.0:
		_coyote_timer = max(_coyote_timer - delta, 0.0)

func _detach_from_beam() -> void:
	_on_beam = false
	_current_beam = null

func take_damage(amount: int = 1) -> void:
	if _invulnerability_timer > 0.0:
		return
	_invulnerability_timer = invulnerability_time
	GameDirector.damage_player(amount)

func respawn(at_position: Vector2) -> void:
	global_position = at_position
	velocity = Vector2.ZERO
	_air_jumps_remaining = max_air_jumps
	_dash_time_remaining = 0.0
	_dash_direction = 0.0
	_reset_time_scale()

func set_respawn(at_position: Vector2) -> void:
	_respawn_position = at_position

func _on_hazard_hit(body: Node) -> void:
	if body.is_in_group("hazard"):
		take_damage(1)

func _on_hazard_area(area: Area2D) -> void:
	if area.is_in_group("hazard"):
		take_damage(1)
