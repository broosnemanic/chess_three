shader_type canvas_item;

uniform float speed = 0.2;				// Cycles per second
uniform float magnitude = 0.1;			// Amount of bounce; 1.0 -> half width of texture
uniform int arrow_count;
uniform float angles[8];				// Each angle gets an arrow pointing that direction (deg)
uniform float fade = 1.0;						// Alpha value


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

bool is_in_bounds(vec2 a_uv) {
	return a_uv.x >= 0.0 && a_uv.x <= 1.0 && a_uv.y >= 0.0 && a_uv.y <= 1.0;  
}

vec2 transformed_uv(vec2 a_uv){
	vec2 t_uv = a_uv + vec2(-0.5, -0.25);
	t_uv = 2.0 * t_uv;
	return t_uv;
}

vec2 rotated_uv(vec2 a_uv, float a_delta_rad){
	vec2 t_pos = a_uv - vec2(0.5);
	float t_len = length(t_pos);
	float t_rad_0 = atan(t_pos.y, t_pos.x);
	float t_rad_1 = t_rad_0 - a_delta_rad;
	t_pos = t_len * vec2(cos(t_rad_1), sin(t_rad_1));
	t_pos += vec2(0.5);
	return t_pos;
}


void fragment() {
	float t_delta_rad;
	vec2 t_pos;
	vec2 t_uv;
	float t_x = magnitude * pow(abs(sin(oscillating_radians())), 2.0);
	t_delta_rad = (PI/180.0) * angles[0];
	t_pos = rotated_uv(UV, t_delta_rad);
	t_uv = vec2(t_pos.x + t_x, t_pos.y);
	COLOR = texture(TEXTURE, t_uv);
	for (int i = 1; i < arrow_count; i++) {
		if (COLOR.a == 0.0){
			t_delta_rad = (PI/180.0) * angles[i];
			t_pos = rotated_uv(UV, t_delta_rad);
			t_uv = vec2(t_pos.x + t_x, t_pos.y);
			COLOR = texture(TEXTURE, t_uv);
		}
	}
	if (COLOR.a > 0.0){
		COLOR.a = fade;
	}
	if (!is_in_bounds(t_uv)){
		COLOR.a = 0.0;
	}
}

//void fragment() {
	//float t_delta_rad = (PI/180.0) * angle;
	//float t_x = magnitude * pow(abs(sin(oscillating_radians())), 2.0);
	//vec2 t_pos = rotated_uv(UV, t_delta_rad);
	//vec2 t_uv = vec2(t_pos.x + t_x, t_pos.y);
	//COLOR = texture(TEXTURE, t_uv);
	//if (COLOR.a == 0.0){
		//t_delta_rad += PI/4.0;
		//t_pos = rotated_uv(UV, t_delta_rad);
		//t_uv = vec2(t_pos.x + t_x, t_pos.y);
		//COLOR = texture(TEXTURE, t_uv);
	//}
	//if (COLOR.a == 0.0){
		//t_delta_rad += PI/4.0;
		//t_pos = rotated_uv(UV, t_delta_rad);
		//t_uv = vec2(t_pos.x + t_x, t_pos.y);
		//COLOR = texture(TEXTURE, t_uv);
	//}
	//if (!is_in_bounds(t_uv)){
		//COLOR.a = 0.0;
	//}
//}

