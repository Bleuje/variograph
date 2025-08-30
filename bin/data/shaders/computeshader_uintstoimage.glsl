#version 440

uniform float width;
uniform float height;
uniform float countPerColorChange;
uniform int colormode;
uniform float randomizer;
uniform float time;
uniform int threeD;
uniform float greyBackgroundFactor;
uniform int colorPrecision;

layout(std430,binding=0) buffer countR
{
	uint mR[];
};
layout(std430,binding=1) buffer countG
{
	uint mG[];
};
layout(std430,binding=2) buffer countB
{
	uint mB[];
};

layout(rgba32f,binding=3) uniform writeonly image2D displayImage;

#define PI 3.1415926538
#define TWO_PI (2.*3.1415926538)

vec3 pal( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d )
{
    return a + b*cos( 6.28318*(c*t+d) );
}

uint hash( uint x ) {
    x += ( x << 10u );
    x ^= ( x >>  6u );
    x += ( x <<  3u );
    x ^= ( x >> 11u );
    x += ( x << 15u );
    return x;
}

uint hash( uvec2 v ) {
    return hash( v.x ^ hash(v.y) );
}

float nrand(vec2 v ) {
	const uint mantissaMask = 0x007FFFFFu;
	const uint one          = 0x3F800000u;

	uint h = hash( floatBitsToUint( v ) );
	h &= mantissaMask;
	h |= one;

	float  r2 = uintBitsToFloat( h );
	return r2 - 1.0;
}

float prand(vec2 v)
{
	return nrand(v);
}

const float ALPHA = 0.14;
const float INV_ALPHA = 1.0 / ALPHA;
const float K = 2.0 / (PI * ALPHA);

float inv_error_function(float x)
{
	float y = log(1.0 - x*x);
	float z = K + 0.5 * y;
	return sqrt(sqrt(z*z - y * INV_ALPHA) - z) * sign(x);
}



float gaussian_rand( vec2 n)
{
	float t = randomizer;
	float x = nrand( n + 0.07*t );
    
	return inv_error_function(x*2.0-1.0)*0.15;
}

vec3 aces(vec3 x) {
  const float a = 2.51;
  const float b = 0.03;
  const float c = 2.43;
  const float d = 0.59;
  const float e = 0.14;
  return clamp((x * (a * x + b)) / (x * (c * x + d) + e), 0.0, 1.0);
}

layout(local_size_x = 32, local_size_y = 32, local_size_z = 1) in;
void main(){
	ivec2 pos = ivec2(gl_GlobalInvocationID.xy);
	uint cpt = mR[ pos.x * int(height) + pos.y ];
	
	vec2 fpos = vec2(pos);

	float greyValue = float(cpt)/countPerColorChange;

    vec3 cntRGB = vec3(mR[ pos.x * int(height) + pos.y ],mG[ pos.x * int(height) + pos.y ],mB[ pos.x * int(height) + pos.y ])/float(colorPrecision)/countPerColorChange;
    vec4 color0 = vec4(cntRGB,1.0);
	
	vec3 rgb;
	if(colormode<=6) rgb = vec3(tanh(color0.rgb*0.7)); // white on black
	else
	{
		float greyValue = float(mR[ pos.x * int(height) + pos.y ] + mG[ pos.x * int(height) + pos.y ] + mB[ pos.x * int(height) + pos.y ])/3.0/float(colorPrecision)/countPerColorChange;
		
        if(colormode==7) rgb = vec3(tanh(greyValue)); // white on black
        else if(colormode==8) rgb = vec3(greyBackgroundFactor-0.76*tanh(greyValue)); // black on white
	}
	
	imageStore(displayImage,pos,vec4(rgb,1.0));
}
