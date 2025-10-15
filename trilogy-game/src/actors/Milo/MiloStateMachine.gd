class_name MiloStateMachine
extends Node

enum State {
    IDLE,
    RUN,
    JUMP,
    FALL,
    BEAM_HANG,
    BEAM_RIDE,
    STUNNED
}

var current_state: State = State.IDLE

func transition_to(target: State) -> void:
    current_state = target

func is_in(state: State) -> bool:
    return current_state == state
