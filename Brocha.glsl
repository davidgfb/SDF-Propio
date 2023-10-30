float pi=3.14;
float gua_d(float x, float miu, float fi) {
	return 1./(fi*sqrt(2.*pi))*exp(-(x-miu)*(x-miu)/(2.*fi*fi));
}

float r = 50.,t,d,m;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord / iResolution.xy;
	d = length(fragCoord - iMouse.xy);
       
    float n = 0.0, c1 = mix(1., 0., (length(fragCoord - iMouse.xy) + 100. * (n - .5))/40.);
    
    fragColor = vec4(vec3(c1 ),1.0);
}
