vec3 z = vec3(0, 0, 1);

/*
struct Elipsoide {
    vec3 r;
};
*/

float d_Capsula( vec3 p, vec3 a, vec3 b, float r )
{
  vec3 pa = p - a, ba = b - a;
  float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
  
  return length( pa - ba*h ) - r;
}

/*
float d_Esfera(vec3 p, float r) { 
    return length(p) - r;
}

float d_Elipsoide( vec3 p, vec3 r ) {
    vec3 p_E_R = p/r; 
    float k0 = length(p_E_R);

    return k0/length(p_E_R/r)*(k0-1.0);
}
*/

void mainImage( out vec4 fragColor, vec2 fragCoord ) {
    fragCoord *= 1e3 / iResolution.x;

    vec3 col = vec3(0), x = z.zxx, y = z.xzx,  
        o = vec3(fragCoord.x, 0, -fragCoord.y) - 100.0*vec3(5,0,-3),
        p = o, v = y, //v direccion, p.y no importa pues la persp
        //es ortogonal. tiene q ser opuesto
        a = vec3(0), b = 20.0*vec3(1,0,1);
    float f_D_Supcie = d_Capsula( p, a, b, 1e-1), //d_Esfera(p, 1e-1), //d_Elipsoide(p, vec3(1, 2, 3)/10.0), 
        d_Max = 1e0;
        
    for (p; length(p-o) < d_Max;) { //while  
        p += v*f_D_Supcie;
        
        if (f_D_Supcie < 50.0) col = 5.0/f_D_Supcie*vec3(1); 
    }
       
    // Normalized pixel coordinates (from 0 to 1)
    //vec2 uv = fragCoord/iResolution.xy;
    // Time varying pixel color
    //vec3 col = 0.5 + 0.5*cos(iTime+uv.xyx+vec3(0,2,4));
    // Output to screen
    fragColor = vec4(col,1.0);
}
