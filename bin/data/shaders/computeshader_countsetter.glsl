#version 440

uniform float width;
uniform float height;
uniform uint value;

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

layout(local_size_x = 32, local_size_y = 32, local_size_z = 1) in;
void main(){
    uint idx = gl_GlobalInvocationID.x * int(height) + gl_GlobalInvocationID.y;
    mR[ idx ] = value;
    mG[ idx ] = value;
    mB[ idx ] = value;
}
