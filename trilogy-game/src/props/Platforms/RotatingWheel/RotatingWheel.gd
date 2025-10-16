extends AnimatableBody2D

@export var radius := 64.0
@export var spoke_count := 4
@export var rotation_speed := 1.0
@export var platform_thickness := 16.0

var _previous_global_transform := Transform2D.IDENTITY
var _motion_velocity := Vector2.ZERO

func _ready() -> void:
    add_to_group("moving_platform")
    _previous_global_transform = global_transform
    set_physics_process_priority(-1)
    _build_spokes()

func _build_spokes() -> void:
    if has_node("Sprite2D"):
        return
    for i in range(spoke_count):
        var polygon := Polygon2D.new()
        polygon.name = "Spoke_%d" % i
        polygon.color = Color(0.41, 0.38, 0.47)
        polygon.polygon = PackedVector2Array([
            Vector2(0, -platform_thickness * 0.5),
            Vector2(radius, -platform_thickness * 0.5),
            Vector2(radius, platform_thickness * 0.5),
            Vector2(0, platform_thickness * 0.5)
        ])
        var holder := Node2D.new()
        holder.rotation = TAU * float(i) / float(spoke_count)
        holder.add_child(polygon)
        add_child(holder)

func _physics_process(delta: float) -> void:
    rotation += rotation_speed * delta
    var current_transform := global_transform
    _motion_velocity = (current_transform.origin - _previous_global_transform.origin) / max(delta, 0.000001)
    _previous_global_transform = current_transform

func get_motion_velocity() -> Vector2:
    return _motion_velocity
