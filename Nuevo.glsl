/*
Output: vec4 fragColor
Input: vec2 fragCoord
fragCoord: the x,y coordinate of the pixel in the output image
fragColor is used as output channel. It is not, for now, 
    mandatory but recommended to leave the alpha channel to 1.0.
vec3 iResolution image/buffer The viewport resolution 
float iTime	image/sound/buffer Current time in seconds
*/
float d_Esfera(vec3 p, float r) { 
    return length(p) - r;
}

float d_Plano( vec3 p, vec3 n, float h ) {
  // n must be normalized
  return dot(p,n) + h;
}

vec3 z = vec3(0, 0, 1);

float d_Supcie(vec3 p) { //d_Esfera->map
    return min(d_Esfera(p, 100.0),d_Plano(p, -z, 0.0)); 
}

void mainImage( out vec4 fragColor, vec2 fragCoord ) {
    /*
    falta añadir el origen de la cam detras del plano fragcoord
    proy ortogonal/normal para perspectiva v = fragcoord - origen_Cam
    normalizo v en coord polares
    */
    fragCoord *= 1e3 / iResolution.x; //cte / variable
    
    float p_Y = 0.0;
    vec3 col = vec3(0), x = z.zxx, y = z.xzx,  
        o = vec3(fragCoord.x, -p_Y, -fragCoord.y) - 500.0*x + 300.0*z,
        p = o, v = y; //p.y tiene q ser opuesto
           
    float f_D_Esfera = d_Supcie(p), d_Max = 1.0;
    
    for (d_Max; length(p-o) < d_Max;) { //while
        p += v*f_D_Esfera;
              
        if (f_D_Esfera < 1e-5) col = normalize(col-p); //vec3(1);
        
        else f_D_Esfera = d_Supcie(p);
    }
        
    //analogia p = vt en r3

    /* Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;

    // Time varying pixel color
    vec3 col = 0.5 + 0.5*cos(iTime+uv.xyx+vec3(0,2,4));
    */
    
    fragColor = vec4(col,1.0);
}
