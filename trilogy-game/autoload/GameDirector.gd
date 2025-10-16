extends Node

signal health_changed(current: int, max_health: int)
signal time_changed(remaining: float)
signal altitude_changed(height: float)
signal message_shown(text: String, duration: float)
signal instructions_changed(text: String)
signal checkpoint_reached(name: String)
signal feedback(event: String)

const DEFAULT_TIME_LIMIT := 180.0

var max_health := 3
var health := max_health
var score := 0
var altitude := 0.0
var session_time := 0.0
var time_limit := DEFAULT_TIME_LIMIT
var time_remaining := DEFAULT_TIME_LIMIT
var countdown_active := true

var player_ref: Node = null
var hud_ref: Node = null
var respawn_position := Vector2.ZERO
var base_respawn_position := Vector2.ZERO

func _ready() -> void:
	reset_run()

func register_player(player: Node) -> void:
	player_ref = player
	if player_ref and player_ref.has_method("set_respawn"):
		respawn_position = player_ref.global_position
		base_respawn_position = respawn_position
		player_ref.set_respawn(respawn_position)
		emit_signal("health_changed", health, max_health)
		emit_signal("time_changed", time_remaining)
		_emit_instructions()

func register_hud(hud: Node) -> void:
	hud_ref = hud
	emit_signal("health_changed", health, max_health)
	emit_signal("time_changed", time_remaining)
	_emit_instructions()
	if altitude > 0.0:
		emit_signal("altitude_changed", altitude)

func reset_run() -> void:
	health = max_health
	score = 0
	altitude = 0.0
	session_time = 0.0
	time_remaining = time_limit
	countdown_active = true
	Engine.time_scale = 1.0
	respawn_position = base_respawn_position
	emit_signal("health_changed", health, max_health)
	emit_signal("time_changed", time_remaining)
	_emit_instructions()
	if player_ref and player_ref.has_method("respawn"):
		player_ref.respawn(respawn_position)
	if player_ref and player_ref.has_method("set_respawn"):
		player_ref.set_respawn(respawn_position)

func add_score(amount: int) -> void:
	score += amount

func register_altitude(height: float) -> void:
	if height <= altitude:
		return
	altitude = height
	emit_signal("altitude_changed", altitude)

func damage_player(amount: int = 1) -> void:
	if amount <= 0:
		return
	health = max(health - amount, 0)
	emit_signal("health_changed", health, max_health)
	if health <= 0:
		emit_signal("message_shown", "Run failed! Respawning at base.", 2.5)
		reset_run()
	else:
		request_respawn()

func heal_player(amount: int = 1) -> void:
	if amount <= 0:
		return
	health = min(health + amount, max_health)
	emit_signal("health_changed", health, max_health)

func request_respawn() -> void:
	if player_ref and player_ref.has_method("respawn"):
		player_ref.respawn(respawn_position)

func set_respawn_position(position: Vector2, checkpoint_name: String = "") -> void:
	respawn_position = position
	if player_ref and player_ref.has_method("set_respawn"):
		player_ref.set_respawn(respawn_position)
	if checkpoint_name != "":
		emit_signal("checkpoint_reached", checkpoint_name)
		emit_signal("message_shown", "Checkpoint reached: %s" % checkpoint_name, 2.0)

func set_countdown_active(active: bool) -> void:
	countdown_active = active

func play_feedback(event: String) -> void:
	emit_signal("feedback", event)

func _emit_instructions() -> void:
	var instructions := [
		"[A]/[D] or arrow keys to move",
		"[Space] to jump, tap again mid-air for double jump",
		"[F] for spell dash (short burst)",
		"[Shift] to slow time (when ready)",
		"Avoid hazards and reach the summit!"
	]
	emit_signal("instructions_changed", "\n".join(instructions))

func _process(delta: float) -> void:
	session_time += delta
	if not countdown_active:
		return
	time_remaining = max(time_remaining - delta, 0.0)
	emit_signal("time_changed", time_remaining)
	if time_remaining <= 0.0:
		emit_signal("message_shown", "Time's up!", 2.0)
		damage_player(health)
