extends Node


var can_start_solo: bool = false


func _ready() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	
	for arg: String in args:
		match arg:
			"--solo":
				can_start_solo = true
			_:
				push_warning("Unknown argument: ", arg)
