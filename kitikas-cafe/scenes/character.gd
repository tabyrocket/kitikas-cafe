extends TextureRect


# Sprites
var mc_default = preload("res://assets/characters/mc_default.png")
var mc_nervous = preload("res://assets/characters/mc_nervous.png")
var mc_bashful = preload("res://assets/characters/mc_bashful.png")

var kitika_default = preload("res://assets/characters/kitika_default.png")
var kitika_hmm = preload("res://assets/characters/kitika_hmm.png")
var kitika_smirk = preload("res://assets/characters/kitika_smirk.png")

var gato_default = preload("res://assets/characters/gato.png")
var gato_annoyed = preload("res://assets/characters/gato_annoyed.png")

var billy_default = preload("res://assets/characters/billy.png")
var billy_talking = preload("res://assets/characters/billy_talking.png")


func change_sprite(sprite_name: String):
	texture = get(sprite_name)
