extends StaticBody2D

var _width := 200.0
var _height := 24.0

@export var width: float = 200.0:
	set(value):
		_width = value
		_apply_size()
	get:
		return _width

@export var height: float = 24.0:
	set(value):
		_height = value
		_apply_size()
	get:
		return _height

@onready var _collision: CollisionShape2D = $CollisionShape2D
@onready var _sprite: Polygon2D = $Sprite

func _ready() -> void:
	_apply_size()

func _apply_size() -> void:
	if not is_inside_tree():
		return
	var shape := _collision.shape as RectangleShape2D
	shape.size = Vector2(_width, _height)
	_collision.position = Vector2(0, -_height * 0.5)
	_sprite.polygon = PackedVector2Array([
		Vector2(-_width * 0.5, 0),
		Vector2(_width * 0.5, 0),
		Vector2(_width * 0.5, -_height),
		Vector2(-_width * 0.5, -_height)
	])
	_sprite.color = Color(0.36, 0.34, 0.4, 1.0)
