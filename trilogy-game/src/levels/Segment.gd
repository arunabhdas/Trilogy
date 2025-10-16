class_name Segment
extends Node2D

@export var height := 800.0
@export var segment_name := "Segment"

func get_top_y() -> float:
    return global_position.y - height

func get_bottom_y() -> float:
    return global_position.y
