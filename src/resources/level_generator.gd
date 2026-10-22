extends Node
class_name LevelGenerator

var platforms: Array[Platform] = []
var relics: Array[Relic] = []
var stones: Array[Stone] = []
var last_stone: float = -1000.0
var rng := RandomNumberGenerator.new()

func _init():
	rng.randomize()

func reset():
	platforms.clear()
	relics.clear()
	stones.clear()
	last_stone = -1000.0

func generate(x: float, speed: float, elapsed: float, ground_y: float, config: GameConfig) -> void:
	while platforms.back().end < x + config.lookahead_distance:
		var previous: Platform = platforms.back()
		var arrival := elapsed + (float(previous.end) - x) / speed
		var gap := config.platform_gap_min if arrival < 8.0 else config.platform_gap_min + (config.platform_gap_max - config.platform_gap_min) * rng.randf()
		var top: float = previous.y
		if arrival > 20.0:
			top = clampf(top + rng.randi_range(-1, 1) * 8.0, ground_y - 16, ground_y + 16)
		var expected := lerp(config.base_speed, config.max_speed, minf(arrival / 120.0, 1.0))
		var flight := (config.max_speed + sqrt(config.max_speed * config.max_speed + config.gravity * config.gravity * (top - float(previous.y)))) / config.gravity
		gap = minf(gap, expected * flight - 20.0)
		var leading: float = previous.end + gap
		var length: float = [224.0, 256.0, 288.0][rng.randi_range(0, 2)]
		
		var new_p = Platform.new()
		new_p.x = leading
		new_p.end = leading + length
		new_p.y = top
		platforms.append(new_p)
		
		for i in 5:
			var height := 14.4
			if rng.randf() < 0.5:
				height = [12.8, 29.0, 36.8, 29.0, 12.8][i]
			var r = Relic.new()
			r.x = leading + 20.0 + i * 13.6
			r.y = top - height
			relics.append(r)
			
		if leading + 96.0 - last_stone >= 206.4:
			var s = Stone.new()
			s.x = leading + 96.0
			s.y = top
			stones.append(s)
			last_stone = leading + 96.0
			
	while platforms.size() > 1 and platforms[0].end < (x - 80.0) - 50:
		platforms.pop_front()
		
	for list in [relics, stones]:
		for i in range(list.size() - 1, -1, -1):
			if list[i].x < (x - 80.0) - 50:
				list.remove_at(i)
