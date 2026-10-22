extends Node2D
## Fixed-step runner simulation. World coordinates are logical pixels.
const Art = preload("res://pixel_art.gd")
const Config = preload("res://resources/game_config.gd").new()
const LevelGenerator = preload("res://resources/level_generator.gd").new()
const VisualEffects = preload("res://resources/visual_effects.gd").new(Config.gravity)

enum State { IDLE, RUNNING, JUMPING, DASHING, DEAD }

var current_state := State.RUNNING
var x := Config.start_x
var y := Config.ground_y
var vy := 0.0
var elapsed := 0.0
var speed := Config.base_speed
var grounded := true
var jumps := Config.max_jumps
var grace := Config.jump_grace_period
var buffered := 0.0
var dash_timer := 0.0
var cooldown_timer := 0.0
var saved_vy := 0.0
var trail_clock := 0.0
var death_time := 0.0
var relic_count := 0
var broken := 0
var score := 0
var camera := 0.0

var art := Art.new()
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	reset()

func reset() -> void:
	x = Config.start_x
	y = Config.ground_y
	vy = 0.0
	elapsed = 0.0
	speed = Config.base_speed
	grounded = true
	jumps = Config.max_jumps
	grace = Config.jump_grace_period
	buffered = 0.0
	dash_timer = 0.0
	cooldown_timer = 0.0
	saved_vy = 0.0
	trail_clock = 0.0
	death_time = 0.0
	relic_count = 0
	broken = 0
	score = 0
	camera = x - 80.0
	
	LevelGenerator.reset()
	
	var start_platform = Platform.new()
	start_platform.x = -100.0
	start_platform.end = Config.start_x + 384.0
	start_platform.y = Config.ground_y
	LevelGenerator.platforms.append(start_platform)
	
	for i in 5:
		var r = Relic.new()
		r.x = Config.start_x + 64 + i * 16
		r.y = Config.ground_y - 14.0
		LevelGenerator.relics.append(r)
		
	LevelGenerator.generate(x, speed, elapsed, Config.ground_y, Config)
	queue_redraw()

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or event.echo:
		return
	
	if event.pressed and event.keycode == KEY_R and current_state == State.DEAD:
		reset()
		return
	
	if current_state == State.DEAD:
		return
		
	if event.keycode in [KEY_SPACE, KEY_Z]:
		if event.pressed:
			buffered = Config.jump_buffer_time
		else:
			cut_jump()
	if event.pressed and event.keycode in [KEY_SHIFT, KEY_X]:
		start_dash()

func cut_jump() -> void:
	if dash_timer > 0.0:
		if saved_vy < 0.0:
			saved_vy *= 0.45
	elif vy < 0.0:
		vy *= 0.45

func start_dash() -> void:
	if dash_timer <= 0.0 and cooldown_timer <= 0.0 and current_state != State.DEAD:
		dash_timer = Config.dash_duration
		saved_vy = vy
		trail_clock = 0.0

func _physics_process(dt: float) -> void:
	step(dt)
	queue_redraw()

func step(dt: float) -> void:
	VisualEffects.update(dt)
	
	if current_state == State.DEAD:
		death_time += dt
		return
		
	elapsed += dt
	speed = lerp(Config.base_speed, Config.max_speed, minf(elapsed / 120.0, 1.0))
	
	if grounded:
		grace = Config.jump_grace_period
	else:
		grace = maxf(0.0, grace - dt)
		if grace <= 0.0 and jumps == Config.max_jumps:
			jumps = 1
			
	if buffered > 0.0 and jumps > 0 and dash_timer <= 0.0:
		vy = Config.jump_strength
		jumps -= 1
		grounded = false
		grace = 0.0
		buffered = 0.0
		
	buffered = maxf(0.0, buffered - dt)
	var old_y := y
	var old_x := x
	var was_dashing := dash_timer > 0.0
	
	if was_dashing:
		x += speed * (dt + minf(dash_timer, dt))
		trail_clock -= dt
		if trail_clock <= 0.0:
			VisualEffects.add_trail(Vector2(x, y), 0.13)
			trail_clock += 0.045
		dash_timer = maxf(0.0, dash_timer - dt)
		if dash_timer <= 0.00001:
			dash_timer = 0.0
			cooldown_timer = Config.dash_cooldown
			vy = saved_vy
	else:
		cooldown_timer = maxf(0.0, cooldown_timer - dt)
		x += speed * dt
		vy += Config.gravity * dt
		y += vy * dt
		
	grounded = false
	for p in LevelGenerator.platforms:
		if x + 9.0 > p.x and x - 9.0 < p.end:
			if old_y <= p.y + 0.01 and y >= p.y and vy >= 0.0 and not was_dashing:
				y = p.y
				vy = 0.0
				grounded = true
				jumps = Config.max_jumps
			elif was_dashing and absf(y - p.y) < 0.01:
				grounded = true
				jumps = Config.max_jumps
			elif y > p.y + 0.1 and y - 22.0 < p.y + 100.0:
				x = maxf(old_x, p.x - 9.0)
				die()
				break
				
	if y > Config.ground_y + 96.0:
		die()
		
	if current_state != State.DEAD:
		for i in range(LevelGenerator.stones.size() - 1, -1, -1):
			var s: Stone = LevelGenerator.stones[i]
			if absf(x - s.x) < 15.0 and y > s.y - 29.0 and y - 22.0 < s.y:
				if was_dashing:
					VisualEffects.add_particle(Vector2(s.x, s.y - 15), Vector2(rng.randf_range(-45, 45), rng.randf_range(-65, 10)), Art.GOLD, 0.35)
					LevelGenerator.stones.remove_at(i)
					broken += 1
				else:
					die()
					break
					
	if current_state != State.DEAD:
		for i in range(LevelGenerator.relics.size() - 1, -1, -1):
			var r: Relic = LevelGenerator.relics[i]
			if absf(x - r.x) < 14.0 and r.y > y - 27.0 and r.y < y + 4.0:
				VisualEffects.add_particle(Vector2(r.x, r.y), Vector2(rng.randf_range(-45, 45), rng.randf_range(-65, 10)), Art.GOLD, 0.35)
				LevelGenerator.relics.remove_at(i)
				relic_count += 1
				
	score = floori((x - Config.start_x) / 16.0 * 10.0) + relic_count * 25 + broken * 100
	camera = x - 80.0
	LevelGenerator.generate(x, speed, elapsed, Config.ground_y, Config)

func die() -> void:
	if current_state == State.DEAD:
		return
	current_state = State.DEAD
	death_time = 0.0
	VisualEffects.add_particle(Vector2(x, y - 12), Vector2(rng.randf_range(-45, 45), rng.randf_range(-65, 10)), Art.IVORY, 0.75)

func _draw() -> void:
	art.render(self)
