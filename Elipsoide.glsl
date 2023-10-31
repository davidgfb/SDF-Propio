vec3 z = vec3(0, 0, 1);

/*
struct Elipsoide {
    vec3 r;
};
*/

float d_Elipsoide( vec3 p, vec3 r ) {
    vec3 p_E_R = p/r; 
    float k0 = length(p_E_R);

    return k0/length(p_E_R/r)*(k0-1.0);
}

void mainImage( out vec4 fragColor, vec2 fragCoord ) {
    fragCoord *= 1e3 / iResolution.x;

    vec3 col = vec3(0), x = z.zxx, y = z.xzx,  
        o = vec3(fragCoord.x, 0, -fragCoord.y) - 500.0*x + 300.0*z,
        p = o, v = y; //v direccion, p.y no importa pues la persp
        //es ortogonal. tiene q ser opuesto
    float f_D_Supcie = d_Elipsoide(p, 50.0*vec3(1, 2, 3)), 
        d_Max = 1e0;
        
    for (p; length(p-o) < d_Max;) { //while  
        p += v*f_D_Supcie;
        
        if (f_D_Supcie < 1e-5) col = normalize(col-p);                        
    }
       
    // Normalized pixel coordinates (from 0 to 1)
    //vec2 uv = fragCoord/iResolution.xy;
    // Time varying pixel color
    //vec3 col = 0.5 + 0.5*cos(iTime+uv.xyx+vec3(0,2,4));
    // Output to screen
    fragColor = vec4(col,1.0);
}
