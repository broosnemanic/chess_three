shader_type canvas_item;

										//** Nested Tinted Zooms **//

// Displays expanding nested tinted copies of <sample> behind a Sprite2D.texture 
// Notes on prefixes: t_ is for local (temp) variables; a_ is for func arguments
// Questions? corpsinhere@gmail.com

uniform sampler2D sample;				// The image being duplicated
uniform float speed = 1.0;				// Cycles per second
uniform float max_zoom = 2.0;			// Scale of max zoom
uniform int layer_count = 3;			// Count of duplicates of <sample> to display
uniform int color_count = 3;			// Count of colors to cycle through - taken from top items in <color_array>
uniform vec2 pivot = vec2(0.5, 0.5);	// Point duplicates zoom from [0.0, 1.0]
uniform bool is_only_bigger = true;		// Should duplicates start at zoom = 1.0?  Else start at zoom = 0.0
uniform bool is_show_original = true;	// As it says
uniform bool is_use_colors = true;		// If false, layers will use original colors
uniform float boarder_zoom = 2.0;		// Canvas size of texture - if smaller than <max_zoom> clipping will occur
										// 0.0 = max, 1-0 = min contrast of tinted layers
uniform float contrast_offset : hint_range(0.0, 1.0, 0.1) = 0.1;
uniform vec3 color_array[9];			// Holds all tints. Shader will only use the first <color_count>


// Expands extents to match <boarder_zoom> and centers (0, 0) at (0.5, 0.5)
void vertex() {
	vec2 center_dist = vec2(0.5, 0.5) - VERTEX;
	center_dist *= boarder_zoom;
	VERTEX = vec2(0.5, 0.5) - center_dist;
}


// As it says
bool is_uv_outofbounds(vec2 a_uv){
	return a_uv.x > 1.0 || a_uv.x < 0.0 || a_uv.y > 1.0 || a_uv.y < 0.0;
}


// Adjust UV per new scale and pivot
vec2 adj_uv(vec2 a_uv, float a_scale, vec2 a_pivot){
	return a_pivot + (a_uv - a_pivot) * pow(a_scale, -1.0);
}


// Color of <sample> at given coord, scale, and pivot point
vec4 layer_color(vec2 a_uv, float a_scale, vec2 a_pivot){
	vec2 t_uv = adj_uv(a_uv, a_scale, a_pivot);
	if (is_uv_outofbounds(t_uv)){
		return vec4(0.0);
	}
	else{
		return texture(sample, adj_uv(a_uv, a_scale, a_pivot));
	}
}


// Returns [0, 0.999]
float normalized_float(float a_float){
	return float(int(10000.0 * a_float) % 10000) / 10000.0;
}


// Looping [0.0, 0.999] - used for building the different zoomed copies
float time_delta(){
	return normalized_float(TIME * speed);
}


// Looping [0.0, 0.999] - slower than <time_delta> by a factor of <layer_count>
// Used for keeping track of layer colors
float layer_time_delta(){
	return normalized_float(TIME * speed / float(layer_count));
}


// Converts <a_color> to greyscale, then tints
vec3 tinted_color(vec3 a_color, vec3 a_tint){
	float t_average = (a_color.r + a_color.g + a_color.b) / 3.0;
	t_average *= (1.0 - contrast_offset);
	t_average += contrast_offset;
	vec3 t_color = a_tint * t_average;
	return t_color;
}


// What? Is used as a bool to determin when layer and layer color match up
// Took ages of fiddling to get it to work and so it stays as is!
int color_index(int a_index){
	int t_layer_index = int(float(layer_count) * layer_time_delta());
	int t_index = abs(t_layer_index - a_index) % layer_count;
	return t_index;
}


// Here be all the goblins that get it all done
void fragment() {
	if (!is_show_original){
		COLOR = vec4(0.0);
	}
	else{
		COLOR = texture(TEXTURE, adj_uv(UV, pow(boarder_zoom, -1.0), vec2(0.5, 0.5)));
	}
	if (COLOR.a == 0.0){
		float scale_fraction;
		if (is_only_bigger){
			scale_fraction = (max_zoom - 1.0) * pow(float(layer_count), -1.0);
		}
		else{
			scale_fraction = max_zoom * pow(float(layer_count), -1.0);	// Used to calc zoom of a given layer
		}
		float size_scale;
		vec4 t_color;
		for (int i = layer_count - 1; i >= 0; i--) {
			size_scale = scale_fraction * (float(i) + time_delta());
			if (is_only_bigger){
				size_scale += 1.0;
			}
			vec2 adjusted_uv = adj_uv(UV, pow(boarder_zoom, -1.0), vec2(0.5, 0.5));
			adjusted_uv = adj_uv(adjusted_uv, size_scale, pivot);
			if (is_uv_outofbounds(adjusted_uv)){
				t_color = vec4(0.0);
			}
			else{
				t_color = texture(sample, adjusted_uv);
			}
			if (t_color.a > 0.0){
				t_color.a *= pow(1.0 - (size_scale / max_zoom), 0.7); // This value controls alpha falloff rate 
				COLOR = t_color;
				vec3 t_tint = COLOR.rgb;
				if (is_use_colors){
					float t_delta = float(layer_count) * (layer_time_delta());
					for(int j = 0; j < layer_count; j++){
						if (color_index(i + j) == 0){
							if (j < color_array.length()){
								t_tint = tinted_color(COLOR.rgb, color_array[j % color_count]);
							}
						}
					}
				}
				COLOR = vec4(vec3(t_tint), COLOR.a);
			}
		}
	}
}
