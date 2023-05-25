extends Resource
class_name Signaler

signal entered_state(fsm, state_name)
signal exited_state(fsm, state_name)
signal changed_state(fsm, state_name)
signal state_cooldown_ended(fsm, state_name)
signal state_cooldown_started(fsm, state_name)

signal state_sent_action(fsm, state_name, action)
