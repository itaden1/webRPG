extends KinematicBody

var interacting := false
var dialogue_pointer: int = 0
var dialogue_reset_timer: Timer = Timer.new()
var reset_time : int = 15

onready var vocal_sound_player = get_node("AudioStreamPlayer3D")

var current_interactor: Spatial
var health: int = 40

var has_greeted: bool = false
var greetings = {
	0: [
		"Hail stranger",
		"Who are you?",
		"Can I help you?"
	],
	3: [
		"Greetings",
		"Well met"
	],
	10: [
		"Welcome Hero",
		"The slayer of demons has returned!"
	]
}

var farewells = {
	0: [
		"So long",
		"So long now",
		"Till next time"
	],
	3: [
		"Its been apleasure"
	],
	10: [
		"Go with honour friend",
		"May our paths cross again"
	]
}

var dialogues := [
	{
		0: [
			"I woke last night to strange screeching sounds...",
			"It sounded like some demon from beyond the grave",
		]
	},
	{
		0: [
			"The land around these parts are full of ruins.",
			"Some are said to be teeming with evil",
			"I am not brave enough to find out for myself.."
		]
	},
	{
		0: [
			"I was passing by some ruins last week.",
			"I heard strange howling eminating from its depths..",
			"I don;t think I will venture near there agian."
		]
	},
	{
		0: [
			"Are you supposed to be some kind of a hero or something?",
			"Maybe you should prove yourself and put that sword to use",
			"The townsfolk are afraid of the ruins and foul beasts that dwell within.",
			"Perhaps you could kill them"
		]
	},
	{
		0: [
			"You can draw your sword by pressing [X]"
		]
	}
]


var chosen_dialogue: Dictionary

func _ready():
	chosen_dialogue = dialogues[Rng.get_random_range(0, dialogues.size()-1)]
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
	var dialogue_text = greetings[0][Rng.get_random_range(0, greetings.size()-1)]
	if dialogue_pointer > chosen_dialogue[0].size()-1:
		dialogue_text = farewells[0][Rng.get_random_range(0, farewells.size()-1)]
		dialogue_pointer = 0
		dialogue_reset_timer.stop()
		dialogue_reset_timer.wait_time = reset_time
		interacting = false
		rotation.y = 0
		has_greeted = false
	if has_greeted:
		dialogue_text = chosen_dialogue[0][dialogue_pointer]
		dialogue_pointer += 1
	else:
		has_greeted = true



	if entity.get("weapon_drawn"):
		dialogue_text = "put that away if you want to talk!"
		dialogue_pointer = 0
	GameEvents.emit_signal("npc_emitted_dialogue", self, dialogue_text)
	dialogue_reset_timer.start()

func _reset_dialogue():
	GameEvents.emit_signal("npc_emitted_dialogue", self, "Not much to say huh..")
	dialogue_pointer = 0
	interacting = false
	rotation.y = 0
	has_greeted = false

func do_damage(damage: int):
	GameEvents.emit_signal("npc_emitted_dialogue", self, "Ouch!!")
	health -= damage
	vocal_sound_player.play()
	if health <= 0:
		queue_free()
