/*
Output: vec4 fragColor
Input: vec2 fragCoord

fragCoord: the x,y coordinate of the pixel in the output image
fragColor is used as output channel. It is not, for now, 
    mandatory but recommended to leave the alpha channel to 1.0.

vec3 iResolution image/buffer The viewport resolution (z is pixel 
    aspect ratio, usually 1.0) siempre será 1
float iTime	image/sound/buffer Current time in seconds
*/
float d_Esfera(vec3 p, float r) { 
    return length(p) - r;
}

float d_Esfera(vec3 p) {
    return d_Esfera(p, 100.0);
}

void mainImage( out vec4 fragColor, vec2 fragCoord ) {
    //falta añadir el origen de la cam detras del plano fragcoord
    //proy ortogonal/normal para perspectiva v = fragcoord - origen_Cam
    //normalizo v en coord polares
    fragCoord *= 1e3 / iResolution.x; //cte / variable
    
    float p_Y = 0.0;
    vec3 col = vec3(0), z = vec3(0, 0, 1), x = z.zxx, y = z.xzx, 
        p = vec3(fragCoord.x, -p_Y, -fragCoord.y) - 400.0*x + 300.0*z,
        v = y; //p.y tiene q ser opuesto
           
    float f_D_Esfera = d_Esfera(p);
    int d_Max = int(1), i_D_Esfera = int(f_D_Esfera); 
    
    for (i_D_Esfera; i_D_Esfera < d_Max;) { //while
        p += v*f_D_Esfera;
              
        if (f_D_Esfera < 1e-5) {
            col = normalize(col-p); //vec3();//z.zzz; 
            i_D_Esfera = d_Max;
        
        } else {
            f_D_Esfera = d_Esfera(p);
            i_D_Esfera = int(f_D_Esfera);
        }
    }
        
    //analogia p = vt en r3

    /* Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;

    // Time varying pixel color
    vec3 col = 0.5 + 0.5*cos(iTime+uv.xyx+vec3(0,2,4));
    */
    
    fragColor = vec4(col,1.0);
}
