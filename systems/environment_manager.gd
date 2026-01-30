extends WorldEnvironment

@export var night_curve : Curve;

var sky_shader := self.environment.sky.sky_material as ShaderMaterial;

func _process(delta: float) -> void:
	sky_shader.set_shader_parameter("night", WorldConstants.time_of_day);
	var night_weight = night_curve.sample(WorldConstants.time_of_day);
	environment.adjustment_saturation = 1.0 - night_weight;
	environment.ambient_light_energy = 1.0 + 16 * night_weight;
	environment.adjustment_contrast = 1.0 + 0.15 * night_weight;
