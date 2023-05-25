tool
extends EditorPlugin

const FSM_NODE_NAME = "FiniteStateMachine"
const FSM_INHERITENCE = "Node"
const FSM_SCRIPT = preload("FiniteStateMachine.gd")
const FSM_ICON = preload("Icons/gear_icon.png")


func _enter_tree():
	add_custom_type(FSM_NODE_NAME, FSM_INHERITENCE, FSM_SCRIPT, FSM_ICON)

func _exit_tree():
	remove_custom_type(FSM_NODE_NAME)
