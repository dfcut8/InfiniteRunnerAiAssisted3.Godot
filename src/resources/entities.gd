class_name GameEntity
var x: float
var y: float

class_name Platform extends GameEntity
var end: float

class_name Relic extends GameEntity

class_name Stone extends GameEntity

class_name Particle extends GameEntity
var vel: Vector2
var life: float
var color: Color

class_name Trail extends GameEntity
var life: float
