extends RefCounted
const BLACK := Color("101419")
const DARK := Color("252d32")
const STONE := Color("59615d")
const BROWN := Color("594b36")
const GOLD := Color("b58a43")
const MOSS := Color("628548")
const PALE := Color("b5cf83")
const IVORY := Color("f3efd9")
const GLYPHS := {
"A":"01110/10001/10001/11111/10001/10001/10001", "B":"11110/10001/10001/11110/10001/10001/11110",
"C":"01111/10000/10000/10000/10000/10000/01111", "D":"11110/10001/10001/10001/10001/10001/11110",
"E":"11111/10000/10000/11110/10000/10000/11111", "F":"11111/10000/10000/11110/10000/10000/10000",
"G":"01111/10000/10000/10111/10001/10001/01110", "H":"10001/10001/10001/11111/10001/10001/10001",
"I":"111/010/010/010/010/010/111", "J":"00111/00010/00010/00010/10010/10010/01100",
"K":"10001/10010/10100/11000/10100/10010/10001", "L":"10000/10000/10000/10000/10000/10000/11111",
"M":"10001/11011/10101/10101/10001/10001/10001", "N":"10001/11001/11001/10101/10011/10011/10001",
"O":"01110/10001/10001/10001/10001/10001/01110", "P":"11110/10001/10001/11110/10000/10000/10000",
"Q":"01110/10001/10001/10001/10101/10010/01101", "R":"11110/10001/10001/11110/10100/10010/10001",
"S":"01111/10000/10000/01110/00001/00001/11110", "T":"11111/00100/00100/00100/00100/00100/00100",
"U":"10001/10001/10001/10001/10001/10001/01110", "V":"10001/10001/10001/10001/10001/01010/00100",
"W":"10001/10001/10001/10101/10101/11011/10001", "X":"10001/10001/01010/00100/01010/10001/10001",
"Y":"10001/10001/01010/00100/00100/00100/00100", "Z":"11111/00001/00010/00100/01000/10000/11111",
"0":"01110/10001/10011/10101/11001/10001/01110", "1":"00100/01100/00100/00100/00100/00100/01110",
"2":"01110/10001/00001/00010/00100/01000/11111", "3":"11110/00001/00001/01110/00001/00001/11110",
"4":"00010/00110/01010/10010/11111/00010/00010", "5":"11111/10000/10000/11110/00001/00001/11110",
"6":"01110/10000/10000/11110/10001/10001/01110", "7":"11111/00001/00010/00100/01000/01000/01000",
"8":"01110/10001/10001/01110/10001/10001/01110", "9":"01110/10001/10001/01111/00001/00001/01110",
"/":"00001/00001/00010/00100/01000/10000/10000", " ":"000/000/000/000/000/000/000"
}
var canvas: Node2D
func box(x: float, y: float, w: float, h: float, color: Color) -> void:
	canvas.draw_rect(Rect2(floorf(x), floorf(y), w, h), color)

func label(text: String, x: float, y: float, color: Color) -> void:
	for character in text:
		var rows: PackedStringArray = GLYPHS.get(character, GLYPHS[" "]).split("/")
		for row in rows.size():
			for col in rows[row].length():
				if rows[row][col] == "1":
					box(x + col, y + row, 1, 1, color)
		x += rows[0].length() + 1

func text_width(text: String) -> int:
	var result := 0
	for ch in text:
		result += GLYPHS.get(ch, GLYPHS[" "]).split("/")[0].length() + 1
	return result - 1

func unicorn(px: float, py: float, pose: int, ghost: bool = false) -> void:
	var body := MOSS if ghost else IVORY
	var mane := MOSS if ghost else PALE
	var shade := MOSS if ghost else STONE
	var bob := 1 if pose in [1, 2, 5] else 0
	var yy := py - 25 + bob
	# Tail, rump, barrel, chest, neck and right-facing head.
	box(px - 17, yy + 8, 8, 3, mane)
	box(px - 19, yy + 10, 5, 5, mane)
	box(px - 21, yy + 13, 4, 2, mane)
	box(px - 12, yy + 9, 17, 9, body)
	box(px - 10, yy + 7, 13, 3, body)
	box(px + 1, yy + 3, 6, 13, body)
	box(px + 5, yy + 2, 7, 6, body)
	box(px + 10, yy + 5, 5, 4, body)
	box(px + 3, yy, 2, 4, body)
	box(px + 10, yy - 4, 1, 2, mane)
	box(px + 9, yy - 2, 2, 4, body)
	box(px, yy + 2, 4, 4, mane)
	box(px - 2, yy + 5, 4, 6, mane)
	box(px - 4, yy + 9, 4, 3, mane)
	if not ghost:
		box(px + 10, yy + 4, 1, 1, BLACK)
		box(px - 9, yy + 16, 11, 1, PALE)
	var offsets := [[-3, 3, 3, -2], [-2, 1, 4, 0], [0, -2, 2, 3], [3, -3, 0, 4], [4, -1, -3, 2], [2, 2, -4, 0], [0, 4, -2, -3], [-3, 2, 1, -4]]
	var legs: Array = offsets[pose % 8]
	if pose == 8:
		legs = [-3, -2, 3, 4]
	elif pose == 9:
		legs = [1, -1, 0, 2]
	elif pose == 10:
		legs = [-6, -5, 5, 6]
	elif pose == 11:
		legs = [4, 3, 5, 2]
	for i in 4:
		var lx: float = px + (-9 if i < 2 else 2) + (i % 2) * 3
		var length := 5 if pose >= 8 else 7 - ((pose + i) % 3)
		box(lx, yy + 17, 2, 3, body if i % 2 else shade)
		box(lx + float(legs[i]), yy + 19, 2, length - 2, body if i % 2 else shade)
		box(lx + float(legs[i]), yy + 17 + length, 3, 1, mane)

func render(game: Node2D) -> void:
	canvas = game
	box(0, 0, 320, 180, BLACK)
	# Seamless repeating distant arcade, 15% parallax.
	var far_offset := posmod(int(game.camera * 0.15), 96)
	for i in range(-1, 5):
		var xx := float(i * 96 - far_offset)
		box(xx, 35, 80, 103, DARK)
		box(xx + 16, 57, 48, 81, BLACK)
		box(xx + 21, 49, 38, 9, BLACK)
		box(xx + 29, 44, 22, 5, BLACK)
		box(xx - 2, 34, 84, 4, BROWN)
		for j in 4:
			box(xx + j * 22, 28 - (j % 2) * 6, 12, 8 + (j % 2) * 6, DARK)
		box(xx + 3, 57, 2, 53, BROWN)
		box(xx + 72, 44, 2, 71, BROWN)
	# Near ruined pillars and broken lintels, 40% parallax.
	var near_offset := posmod(int(game.camera * 0.4), 149)
	for i in range(-1, 4):
		var xx := float(i * 149 - near_offset)
		box(xx + 5, 79, 16, 65, DARK)
		box(xx + 3, 78, 20, 5, STONE)
		box(xx + 8, 85, 3, 52, BROWN)
		box(xx + 1, 137, 24, 7, STONE)
		box(xx + 5, 70, 9, 8, STONE)
		box(xx + 22, 115, 23, 20, DARK)
		box(xx + 32, 109, 9, 6, DARK)
		for j in 7:
			box(xx + 18 + (j % 2) * 2, 80 + j * 5, 2, 5, MOSS)
	for p in game.platforms:
		var left: float = p.x - game.camera
		var width: float = p.end - p.x
		box(left, p.y, width, 90, DARK)
		# Stable world-space brick pattern, clipped to each platform.
		for row in 7:
			var first := int(floor(float(p.x) / 24.0))
			var last := int(ceil(float(p.end) / 24.0))
			for col in range(first - 1, last + 1):
				var bx := col * 24.0 + (row % 2) * 12.0
				var a := maxf(bx, p.x)
				var b := minf(bx + 22, p.end)
				if b > a:
					box(a - game.camera, p.y + 5 + row * 10, b - a, 8, STONE if row < 3 else DARK)
					if row < 3:
						box(a - game.camera + 1, p.y + 6 + row * 10, maxf(1, b - a - 3), 1, BROWN)
		box(left, p.y, width, 3, MOSS)
		box(left + 1, p.y, width - 2, 1, PALE)
		for j in range(0, int(width), 19):
			box(left + j, p.y + 3, 3, 3 + j % 7, MOSS)
			if j % 3 == 0:
				box(left + j + 3, p.y + 7, 2, 7, MOSS)
	for r in game.relics:
		var rx: float = r.x - game.camera
		box(rx - 1, r.y - 4, 2, 8, GOLD)
		box(rx - 3, r.y - 2, 6, 4, GOLD)
		box(rx - 1, r.y - 2, 1, 3, IVORY)
	for s in game.stones:
		var sx: float = s.x - game.camera
		box(sx - 7, s.y - 26, 14, 25, BROWN)
		box(sx - 5, s.y - 29, 10, 28, GOLD)
		box(sx - 3, s.y - 31, 6, 2, GOLD)
		box(sx - 8, s.y - 3, 16, 3, GOLD)
		box(sx - 1, s.y - 24, 2, 17, BLACK)
		box(sx + 1, s.y - 22, 3, 2, IVORY)
		box(sx + 3, s.y - 20, 2, 3, IVORY)
		box(sx + 1, s.y - 17, 3, 2, IVORY)
		box(sx - 4, s.y - 15, 3, 2, PALE)
		box(sx - 4, s.y - 17, 2, 2, PALE)
	for t in game.trails:
		unicorn(t.x - game.camera, t.y, 10, true)
	if not game.dead or game.death_time < 0.65:
		var pose := int(game.elapsed * 12 * game.speed / 80.0) % 8
		if game.dead:
			pose = 11
		elif game.dash > 0:
			pose = 10
		elif not game.grounded:
			pose = 8 if game.vy < 0 else 9
		unicorn(80, game.y, pose)
	for particle in game.particles:
		box(particle.pos.x - game.camera, particle.pos.y, 2, 2, particle.color)
	box(0, 0, 320, 18, BLACK)
	box(0, 17, 320, 1, DARK)
	label("SCORE %06d" % game.score, 7, 5, IVORY)
	var relic_text := "RELICS %03d" % game.relic_count
	label(relic_text, 313 - text_width(relic_text), 5, GOLD)
	box(4, 157, 81, 20, BLACK)
	label("DASH READY" if game.cooldown <= 0 and game.dash <= 0 else "DASH", 8, 160, PALE)
	box(8, 171, 69, 3, DARK)
	var charge: float = 1.0 - game.cooldown / 0.70
	if game.dash > 0:
		charge = game.dash / 0.20
	box(8, 171, floorf(69 * charge), 2, MOSS)
	if game.elapsed < 6 and not game.dead:
		box(218, 154, 99, 23, BLACK)
		label("SPACE / Z  JUMP", 223, 157, IVORY)
		label("SHIFT / X  DASH", 223, 168, PALE)
	if game.dead:
		box(99, 66, 122, 48, STONE)
		box(100, 67, 120, 46, BLACK)
		box(107, 72, 106, 1, MOSS)
		label("RUN ENDED", 160 - text_width("RUN ENDED") / 2.0, 80, IVORY)
		label("R TO RETRY", 160 - text_width("R TO RETRY") / 2.0, 97, PALE)
