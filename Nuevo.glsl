/*
Output: vec4 fragColor
Input: vec2 fragCoord
fragCoord: the x,y coordinate of the pixel in the output image
fragColor is used as output channel. It is not, for now, 
    mandatory but recommended to leave the alpha channel to 1.0.
vec3 iResolution image/buffer The viewport resolution 
float iTime	image/sound/buffer Current time in seconds
todas las direcciones deben estar normalizadas
Todas estas variables se recargan x cada pixel.
Ojo a que sean constantes
*/
vec3 z = vec3(0, 0, 1), p_Min_Esfera = vec3(1e3); 
//H_Min_Esfera = p_Min_Esfera.z
float h_O_Plano = -200.0, h_Plano = 0.0, r_Esfera = 100.0;
int f_Actual = 0;

float d_Esfera(vec3 p, float r) { 
    return length(p) - r;
}

float d_Plano( vec3 p, vec3 n, float h ) {
    //n direccion
    return dot(p,-n) - h;
}

void act_Frametime() {
    /*
    estas variables son ctes durante frameTime
    actualiza solo UNA vez x frametime
    */
    h_Plano = h_O_Plano; 
    
    h_Plano *= sin(iTime); //movto SIEMPRE en f(t).
    //NO valen operadores de asignacion compuesta que no esten en f de 
    //iTime! x la volatilidad/efimeridad de los datos
    
    f_Actual = iFrame;
}

/*
actualizo posicion cada frame en f de tiempo. 
iTimeDelta (f) = Tiempo/frame, 16ms/frame
iFrameRate(t)
*/
float d_Supcie(vec3 p) {
    if (f_Actual != iFrame) act_Frametime();
    
    /*
    if (int(iTime) != t_Actual) { //iFrame
        h_Plano += 10.0; //NO funciona
        
        t_Actual = int(iTime);
    }
    */ 
    
    return min(d_Esfera(p, r_Esfera),d_Plano(p, z, h_Plano)); 
}

/*
float get_H() {
    return 0.0;
}
*/

void mainImage( out vec4 fragColor, vec2 fragCoord ) {
    /*
    falta añadir el origen de la cam detras del plano fragcoord
    proy ortogonal/normal para perspectiva v = fragcoord - origen_Cam
    normalizo v en coord polares
    */
    fragCoord *= 1e3 / iResolution.x; //cte / variable
    
    float p_Y = 0.0;
    vec3 col = vec3(0), x = z.zxx, y = z.xzx,  
        o = vec3(fragCoord.x, -p_Y, -fragCoord.y) - 500.0*x + 400.0*z,
        p = o, v = y; //v direccion, p.y tiene q ser opuesto
           
    float f_D_Supcie = d_Supcie(p), d_Max = 1e0;
    
    for (p; length(p-o) < d_Max;) { //while    
        p += v*f_D_Supcie;
              
        if (f_D_Supcie < 1e-5) { //f de movimiento SIEMPRE antes de col!
            col = normalize(col-p); //col direccion, vec3(1);
            
            //es_Esfera
            if (f_D_Supcie == d_Esfera(p, r_Esfera) && 
                p_Min_Esfera.z > p.z) p_Min_Esfera = p;
        
        } else f_D_Supcie = d_Supcie(p);
    }
             
    /*
    analogia p = vt en r3
    // Time varying pixel color
    vec3 col = 0.5 + 0.5*cos(iTime+uv.xyx+vec3(0,2,4));
    */
    
    fragColor = vec4(col,1.0);
}
