extends Resource
class_name GameConfig

@export_group("Movement")
@export var ground_y: float = 132.0
@export var start_x: float = 48.0
@export var base_speed: float = 80.0
@export var max_speed: float = 144.0
@export var gravity: float = 448.0

@export_group("Jumping")
@export var jump_strength: float = -144.0
@export var max_jumps: int = 2
@export var jump_grace_period: float = 0.1
@export var jump_buffer_time: float = 0.12

@export_group("Dashing")
@export var dash_duration: float = 0.20
@export var dash_cooldown: float = 0.70

@export_group("Generation")
@export var platform_gap_min: float = 20.0
@export var platform_gap_max: float = 32.0
@export var lookahead_distance: float = 560.0
@export var fall_off_distance: float = 96.0
