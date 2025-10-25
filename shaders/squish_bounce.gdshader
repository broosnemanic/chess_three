shader_type canvas_item;

uniform float speed = 1.0;				// Cycles per second
uniform float magnitude = 1.0;			// Amount of bounce; 1.0 -> half width of texture
uniform float overshoot : hint_range(0.0, 0.5, 0.1) = 0.1;

// Returns [0, 0.999]
float normalized_float(float a_float){
	return float(int(10000.0 * a_float) % 10000) / 10000.0;
}

// Looping [0.0, 0.999] - used for building the different zoomed copies
float time_delta(){
	return normalized_float(TIME * speed);
}

float oscillating_radians(){
	return 2.0 * PI * time_delta();
}



void vertex() {
	vec2 t_size = vec2(1.0, 1.0) / TEXTURE_PIXEL_SIZE;
	float t_mag_x = t_size.x * 0.5 * magnitude;
	float t_time = pow(abs(sin(oscillating_radians())), 2.0);
	if (VERTEX.x > -1.0){
		VERTEX = vec2((overshoot + 0.5) * t_size.x - t_mag_x * t_time, VERTEX.y);
	}
	
}

void fragment() {
	COLOR = texture(TEXTURE, max(2.0 * UV - vec2(1.0, 0.5), vec2(0.1)));
	if (UV.x < 0.5){
		COLOR.a = 0.0;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
