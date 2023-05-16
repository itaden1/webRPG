extends KinematicBody

var interacting := false
var dialogue_pointer: int = 0
var dialogue_reset_timer: Timer = Timer.new()
var reset_time : int = 15

var current_interactor: Spatial
var health: int = 40

var dialogue := {
	0: [
		"Hail stranger",
		"Have you heard about the haunted mine North of here?",
		"They say a Lich has taken residence in its depths",
		"So long now"
	]
}

func _ready():
	dialogue_reset_timer.wait_time = reset_time
	dialogue_reset_timer.one_shot = true
	add_child(dialogue_reset_timer)
	var _d: int = dialogue_reset_timer.connect("timeout", self, "_reset_dialogue")


func _physics_process(delta):
	if interacting:
		look_at(
			Vector3(current_interactor.global_transform.origin.x, 0, current_interactor.global_transform.origin.z), 
			Vector3.UP
		)
		rotation.x = 0
		rotation.z = 0
	if current_interactor != null:
		if current_interactor.global_transform.origin.distance_to(global_transform.origin) > 25:
			_reset_dialogue()


func interact(interactor: Spatial):
	current_interactor = interactor
	interacting = true
	initiate_dialogue(interactor)


func initiate_dialogue(entity: KinematicBody):
	var dialogue_text = dialogue[0][dialogue_pointer]
	dialogue_pointer += 1
	if entity.get("weapon_drawn"):
		dialogue_text = "put that away if you want to talk!"
		dialogue_pointer = 0
	GameEvents.emit_signal("npc_emitted_dialogue", self, dialogue_text)
	dialogue_reset_timer.start()
	if dialogue_pointer > dialogue[0].size() - 1:
		dialogue_pointer = 0
		dialogue_reset_timer.stop()
		dialogue_reset_timer.wait_time = reset_time
		interacting = false
		rotation.y = 0


func _reset_dialogue():
	GameEvents.emit_signal("npc_emitted_dialogue", self, "Not much to say huh..")
	dialogue_pointer = 0
	interacting = false
	rotation.y = 0

func do_damage(damage: int):
	GameEvents.emit_signal("npc_emitted_dialogue", self, "Ouch!!")
	health -= damage
	if health <= 0:
		queue_free()
