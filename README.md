# Pixel Unicorn Runner

A complete endless runner in Godot 4.7. Open `src/project.godot` and press **F6** with `main.tscn` open, or **F5** to run the project. Gameplay starts immediately.

- **Space / Z:** jump; press again for one airborne jump. Release early for a short hop.
- **Either Shift / X:** dash through ochre runestones. Jumping over them also works.
- **R:** retry after death with a new course.

Original rectangle-based pixel artwork and a hand-authored 5x7 font use only the eight requested colors. The 320x180 viewport scales in integer steps and letterboxes. Movement runs at 120 Hz independently of display refresh. No external assets, audio, saved data, or dependencies are needed.

## Verification

Run `godot --headless --path src --script res://tests/runner_test.gd`.

Checks cover variable jump height, double-jump limits, coyote time, jump buffering, dash duration and cooldown, vertical suspension, reward uniqueness, hazard and platform collisions, falls, frozen score, complete retry reset, 2,000 course-generation samples, bounded storage, and a ten-minute simulated run using jumps and dashes.

Run `godot --path src --script res://tests/capture.gd` to regenerate `src/preview.png` and check that the logical viewport stays 320x180 at 640x360, 960x540, and 1000x700 window sizes. Integer scaling and aspect preservation are configured in the project. The preview was visually inspected for pixel edges, HUD alignment, and hazard contrast.

Implementation: `runner.gd` owns fixed-step movement, collision, generation, scoring and effects; `pixel_art.gd` draws the world, unicorn poses and HUD. `main.tscn` is the entry scene.
