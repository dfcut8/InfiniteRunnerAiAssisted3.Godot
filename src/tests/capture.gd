extends SceneTree
func _initialize() -> void:
	call_deferred("capture")
func capture() -> void:
	var game: Node2D = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.set_physics_process(false)
	game.x = 360.0
	game.elapsed = 3.8
	game.camera = game.x - 80
	game.queue_redraw()
	for dimensions in [Vector2i(960, 540), Vector2i(1000, 700), Vector2i(640, 360)]:
		root.size = dimensions
		await process_frame
		await process_frame
		await RenderingServer.frame_post_draw
		var frame := root.get_texture().get_image()
		assert(frame.get_size() == Vector2i(320, 180), "Logical game and HUD resolution must stay fixed")
		print("Verified logical 320x180 canvas at window ", dimensions)
		if dimensions == Vector2i(960, 540):
			frame.save_png("res://preview.png")
	quit()
