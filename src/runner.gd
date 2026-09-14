extends Node2D
## Fixed-step runner simulation. World coordinates are logical pixels.
const Art = preload("res://pixel_art.gd")
const GROUND := 132.0
const START := 48.0
var rng := RandomNumberGenerator.new()
var x := START
var y := GROUND
var vy := 0.0
var elapsed := 0.0
var speed := 80.0
var grounded := true
var jumps := 2
var grace := 0.1
var buffered := 0.0
var dash := 0.0
var cooldown := 0.0
var saved_vy := 0.0
var trail_clock := 0.0
var dead := false
var death_time := 0.0
var relic_count := 0
var broken := 0
var score := 0
var camera := 0.0
var platforms: Array[Dictionary] = []
var relics: Array[Dictionary] = []
var stones: Array[Dictionary] = []
var particles: Array[Dictionary] = []
var trails: Array[Dictionary] = []
var last_stone := -1000.0
var art := Art.new()

func _ready() -> void:
	reset()

func reset() -> void:
	rng.randomize()
	x = START
	y = GROUND
	vy = 0.0
	elapsed = 0.0
	speed = 80.0
	grounded = true
	jumps = 2
	grace = 0.1
	buffered = 0.0
	dash = 0.0
	cooldown = 0.0
	saved_vy = 0.0
	trail_clock = 0.0
	dead = false
	death_time = 0.0
	relic_count = 0
	broken = 0
	score = 0
	camera = x - 80.0
	platforms.clear()
	relics.clear()
	stones.clear()
	particles.clear()
	trails.clear()
	last_stone = -1000.0
	platforms.append({"x": -100.0, "end": START + 384.0, "y": GROUND})
	for i in 5:
		relics.append({"x": START + 64 + i * 16, "y": GROUND - 14.0})
	generate()
	queue_redraw()

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or event.echo:
		return
	if event.pressed and event.keycode == KEY_R and dead:
		reset()
		return
	if dead:
		return
	if event.keycode in [KEY_SPACE, KEY_Z]:
		if event.pressed:
			buffered = 0.12
		else:
			cut_jump()
	if event.pressed and event.keycode in [KEY_SHIFT, KEY_X]:
		start_dash()

func cut_jump() -> void:
	if dash > 0.0:
		if saved_vy < 0.0:
			saved_vy *= 0.45
	elif vy < 0.0:
		vy *= 0.45

func start_dash() -> void:
	if dash <= 0.0 and cooldown <= 0.0 and not dead:
		dash = 0.20
		saved_vy = vy
		trail_clock = 0.0

func _physics_process(dt: float) -> void:
	step(dt)
	queue_redraw()

func step(dt: float) -> void:
	update_effects(dt)
	if dead:
		death_time += dt
		return
	elapsed += dt
	speed = lerpf(80.0, 144.0, minf(elapsed / 120.0, 1.0))
	if grounded:
		grace = 0.10
	else:
		grace = maxf(0.0, grace - dt)
		if grace <= 0.0 and jumps == 2:
			jumps = 1
	if buffered > 0.0 and jumps > 0 and dash <= 0.0:
		vy = -144.0
		jumps -= 1
		grounded = false
		grace = 0.0
		buffered = 0.0
	buffered = maxf(0.0, buffered - dt)
	var old_y := y
	var old_x := x
	var was_dashing := dash > 0.0
	if was_dashing:
		x += speed * (dt + minf(dash, dt))
		trail_clock -= dt
		if trail_clock <= 0.0:
			trails.append({"x": x, "y": y, "life": 0.13})
			trail_clock += 0.045
		dash = maxf(0.0, dash - dt)
		if dash <= 0.00001:
			dash = 0.0
			cooldown = 0.70
			vy = saved_vy
	else:
		cooldown = maxf(0.0, cooldown - dt)
		x += speed * dt
		vy += 448.0 * dt
		y += vy * dt
	grounded = false
	for p in platforms:
		if x + 9.0 > p.x and x - 9.0 < p.end:
			if old_y <= p.y + 0.01 and y >= p.y and vy >= 0.0 and not was_dashing:
				y = p.y
				vy = 0.0
				grounded = true
				jumps = 2
			elif was_dashing and absf(y - p.y) < 0.01:
				grounded = true
				jumps = 2
			elif y > p.y + 0.1 and y - 22.0 < p.y + 100.0:
				x = maxf(old_x, p.x - 9.0)
				die()
				break
	if y > GROUND + 96.0:
		die()
	if not dead:
		for i in range(stones.size() - 1, -1, -1):
			var s: Dictionary = stones[i]
			if absf(x - s.x) < 15.0 and y > s.y - 29.0 and y - 22.0 < s.y:
				if was_dashing:
					burst(Vector2(s.x, s.y - 15), 18, Art.GOLD, 0.35)
					stones.remove_at(i)
					broken += 1
				else:
					die()
					break
	if not dead:
		for i in range(relics.size() - 1, -1, -1):
			var r: Dictionary = relics[i]
			if absf(x - r.x) < 14.0 and r.y > y - 27.0 and r.y < y + 4.0:
				burst(Vector2(r.x, r.y), 7, Art.GOLD, 0.35)
				relics.remove_at(i)
				relic_count += 1
	score = floori((x - START) / 16.0 * 10.0) + relic_count * 25 + broken * 100
	camera = x - 80.0
	generate()

func generate() -> void:
	while platforms.back().end < x + 560.0:
		var previous: Dictionary = platforms.back()
		# Estimate arrival time rather than using generation time (off-screen lookahead).
		var arrival := elapsed + (float(previous.end) - x) / speed
		var gap := 20.0 if arrival < 8.0 else rng.randf_range(24.0, lerpf(32.0, 56.0, minf(arrival / 120.0, 1.0)))
		var top: float = previous.y
		if arrival > 20.0:
			top = clampf(top + rng.randi_range(-1, 1) * 8.0, GROUND - 16, GROUND + 16)
		var expected := lerpf(80.0, 144.0, minf(arrival / 120.0, 1.0))
		var flight := (144.0 + sqrt(144.0 * 144.0 + 896.0 * (top - float(previous.y)))) / 448.0
		gap = minf(gap, expected * flight - 20.0)
		var leading: float = previous.end + gap
		var length: float = [224.0, 256.0, 288.0][rng.randi_range(0, 2)]
		platforms.append({"x": leading, "end": leading + length, "y": top})
		var arch := rng.randf() < 0.5
		for i in 5:
			var height := 14.4
			if arch:
				height = [12.8, 29.0, 36.8, 29.0, 12.8][i]
			relics.append({"x": leading + 20.0 + i * 13.6, "y": top - height})
		if leading + 96.0 - last_stone >= 206.4:
			stones.append({"x": leading + 96.0, "y": top})
			last_stone = leading + 96.0
	while platforms.size() > 1 and platforms[0].end < camera - 50:
		platforms.pop_front()
	for list in [relics, stones]:
		for i in range(list.size() - 1, -1, -1):
			if list[i].x < camera - 50:
				list.remove_at(i)

func die() -> void:
	if dead:
		return
	dead = true
	death_time = 0.0
	burst(Vector2(x, y - 12), 30, Art.IVORY, 0.75)

func burst(pos: Vector2, count: int, color: Color, life: float) -> void:
	for i in count:
		particles.append({"pos": pos, "vel": Vector2(rng.randf_range(-45, 45), rng.randf_range(-65, 10)), "life": life, "color": color})

func update_effects(dt: float) -> void:
	for i in range(particles.size() - 1, -1, -1):
		particles[i].life -= dt
		particles[i].pos += particles[i].vel * dt
		particles[i].vel.y += 160.0 * dt
		if particles[i].life <= 0:
			particles.remove_at(i)
	for i in range(trails.size() - 1, -1, -1):
		trails[i].life -= dt
		if trails[i].life <= 0:
			trails.remove_at(i)

func _draw() -> void:
	art.render(self)
