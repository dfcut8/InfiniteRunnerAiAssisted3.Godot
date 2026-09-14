extends SceneTree
const Runner = preload("res://runner.gd")
var failures := 0
func check(value: bool, message: String) -> void:
	if not value:
		failures += 1
		push_error(message)
func fresh() -> Node2D:
	var g := Runner.new()
	g.reset()
	return g
func _initialize() -> void:
	var g := fresh()
	g.buffered = 0.12
	g.step(1.0 / 120)
	check(g.jumps == 1 and g.vy < -130, "first jump")
	var held: float = g.vy
	g.cut_jump()
	check(is_equal_approx(g.vy, held * 0.45), "tap cut")
	g.buffered = 0.12
	g.step(1.0 / 120)
	check(g.jumps == 0 and g.vy < -130, "double jump")
	g.buffered = 0.12
	g.step(1.0 / 120)
	check(g.jumps == 0 and g.vy > -140, "no third jump")
	g.reset()
	g.x = 442
	g.grounded = false
	g.grace = 0.08
	g.buffered = 0.12
	g.step(1.0 / 120)
	check(g.jumps == 1 and g.vy < 0, "coyote jump")
	g.reset()
	g.x = 442
	g.grounded = false
	g.grace = 0.0
	g.step(1.0 / 120)
	check(g.jumps == 1, "walking off leaves one recovery jump")
	g.reset()
	g.y = 130
	g.grounded = false
	g.jumps = 0
	g.vy = 80
	g.buffered = 0.12
	for i in 5:
		g.step(1.0 / 120)
	check(g.vy < 0 and g.jumps == 1, "buffered jump after landing")
	g.reset()
	g.y = 90
	g.vy = -80
	g.grounded = false
	g.start_dash()
	for i in 24:
		g.step(1.0 / 120)
	check(is_equal_approx(g.y, 90) and g.dash == 0 and is_equal_approx(g.cooldown, 0.7), "dash duration and suspension")
	check(g.vy == -80, "dash restores vertical speed")
	g.start_dash()
	check(g.dash == 0, "cooldown blocks dash")
	for i in 84:
		g.step(1.0 / 120)
	check(g.cooldown < 0.00001, "cooldown duration")
	g.reset()
	g.stones.assign([{"x": g.x + 10, "y": g.y}])
	g.start_dash()
	g.step(1.0 / 120)
	check(not g.dead and g.broken == 1 and g.stones.is_empty(), "dash breaks stone once")
	g.step(1.0 / 120)
	check(g.broken == 1, "stone only scores once")
	g.reset()
	g.stones.assign([{"x": g.x + 10, "y": g.y}])
	g.step(1.0 / 120)
	check(g.dead, "stone fatal without dash")
	var final_score: int = g.score
	g.step(1)
	check(g.score == final_score, "score frozen")
	g.reset()
	g.relics.assign([{"x": g.x, "y": g.y - 14}])
	g.step(1.0 / 120)
	g.step(1.0 / 120)
	check(g.relic_count == 1 and g.score == 25, "relic scores once")
	g.reset()
	g.platforms.assign([{"x": -100.0, "end": 48.0, "y": 132.0}, {"x": 60.0, "end": 500.0, "y": 110.0}])
	g.start_dash()
	g.step(1.0 / 120)
	g.step(1.0 / 120)
	g.step(1.0 / 120)
	check(g.dead, "front collision fatal during dash")
	g.reset()
	g.y = 230
	g.step(1.0 / 120)
	check(g.dead, "fall fatal")
	g.reset()
	check(g.score == 0 and g.relic_count == 0 and g.jumps == 2 and g.cooldown == 0 and g.dash == 0 and g.speed == 80 and g.particles.is_empty() and g.trails.is_empty() and g.camera == -32, "retry reset")
	# Sample a long course at all speeds, verifying ballistic single-jump margins.
	for i in 2000:
		g.x = float(g.platforms.back().end) - 100
		g.elapsed = i * 0.25
		g.speed = lerpf(80, 144, minf(g.elapsed / 120, 1))
		g.camera = g.x - 80
		g.generate()
		for j in range(1, g.platforms.size()):
			var a: Dictionary = g.platforms[j - 1]
			var b: Dictionary = g.platforms[j]
			var arrival: float = g.elapsed + (float(a.end) - g.x) / g.speed
			var velocity := lerpf(80, 144, clampf(arrival / 120, 0, 1))
			var flight := (144 + sqrt(20736 + 896 * (float(b.y) - float(a.y)))) / 448
			check(b.x - a.end < velocity * flight - 17, "single jump margins")
			check(absf(b.y - a.y) <= 8 and absf(b.y - 132) <= 16, "elevation limits")
		for j in range(1, g.stones.size()):
			check(g.stones[j].x - g.stones[j - 1].x >= 206.4, "hazard spacing")
		check(g.platforms.size() < 8 and g.relics.size() < 40 and g.stones.size() < 8, "bounded course storage")
	g.reset()
	g.rng.seed = 711
	for tick in 72000:
		if g.grounded:
			for p in g.platforms:
				if g.x >= p.x and g.x < p.end and p.end - g.x < 14:
					g.buffered = 0.12
		for s in g.stones:
			if s.x > g.x and s.x - g.x < 20:
				g.start_dash()
		g.step(1.0 / 120)
		if g.dead:
			check(false, "continuous run died at %.2f seconds" % g.elapsed)
			break
	check(g.elapsed > 599, "ten minute run")
	g.free()
	print("Runner checks finished: %d failures" % failures)
	quit(1 if failures else 0)







