extends Node
class_name VisualEffectsManager

var particles: Array[Particle] = []
var trails: Array[Trail] = []
var gravity: float

func _init(gravity: float):
	self.gravity = gravity

func add_particle(pos: Vector2, vel: Vector2, life: float, color: Color) -> void:
	var p = Particle.new()
	p.pos = pos
	p.vel = vel
	p.life = life
	p.color = color
	particles.append(p)

func add_trail(pos: Vector2, life: float) -> void:
	var t = Trail.new()
	t.pos = pos
	t.life = life
	trails.append(t)

func update(dt: float) -> void:
	for i in range(particles.size() - 1, -1, -1):
		particles[i].life -= dt
		particles[i].pos += particles[i].vel * dt
		particles[i].vel.y += gravity * dt
		if particles[i].life <= 0:
			particles.remove_at(i)
			
	for i in range(trails.size() - 1, -1, -1):
		trails[i].life -= dt
		if trails[i].life <= 0:
			trails.remove_at(i)
