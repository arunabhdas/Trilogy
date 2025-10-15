extends Node

var score := 0
var altitude := 0.0
var session_time := 0.0

func _ready() -> void:
    reset_run()

func reset_run() -> void:
    score = 0
    altitude = 0.0
    session_time = 0.0

func register_altitude(height: float) -> void:
    altitude = max(altitude, height)

func add_score(amount: int) -> void:
    score += amount

func _process(delta: float) -> void:
    session_time += delta
