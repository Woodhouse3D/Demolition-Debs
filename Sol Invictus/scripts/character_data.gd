extends Resource
class_name character_data

export(String) var description
export(SpriteFrames) var frames
export(int) var jump_force = 17000
export(Curve) var Horizontal_Acceleration
export(float) var mass = 1.0
export(bool) var move_wallstick = false
export(bool) var move_machclimb = false
export(bool) var move_dash = false
export(bool) var move_machturn = true
export(bool) var move_drilldive = true
export(bool) var move_homingattack = true
export(bool) var move_spindash = false
export(bool) var move_dropdash = false
