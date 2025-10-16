extends Area2D

@export var checkpoint_name := "Checkpoint"

func _ready() -> void:
    add_to_group("checkpoint")
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
    if not body.is_in_group("player"):
        return
    GameDirector.set_respawn_position(global_position, checkpoint_name)
