/**
 * Gradient Fragment Shader
 * Creates smooth GPU-accelerated gradients.
 * Supports both vertical and horizontal gradients.
 * 
 * Uniforms:
 * - color1: Start color (top for vertical, left for horizontal)
 * - color2: End color (bottom for vertical, right for horizontal)
 * - vertical: 1.0 for vertical gradient, 0.0 for horizontal
 */

#pragma header

// Gradient colors (RGBA, normalized 0.0-1.0)
uniform vec4 color1;
uniform vec4 color2;

// Direction: 1.0 = vertical (top to bottom), 0.0 = horizontal (left to right)
uniform float vertical;

void main()
{
	// Get texture coordinates (0.0 to 1.0)
	vec2 uv = openfl_TextureCoordv;
	
	// Calculate gradient factor based on direction
	// mix(uv.x, uv.y, vertical) blends between horizontal and vertical
	float factor = mix(uv.x, uv.y, vertical);
	
	// Linear interpolation between colors
	vec4 gradientColor = mix(color1, color2, factor);
	
	// Sample original texture (the 1x1 white pixel)
	vec4 texColor = flixel_texture2D(bitmap, uv);
	
	// Multiply texture by gradient to get final color
	// This preserves the alpha from the texture and applies the gradient
	gl_FragColor = texColor * gradientColor;
}
