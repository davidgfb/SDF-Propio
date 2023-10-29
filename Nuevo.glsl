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
float h_Plano = -200.0, r_Esfera = 100.0;
vec3 z = vec3(0, 0, 1), p_Min_Esfera = vec3(0,0,-100); //vec3(1e3); 
//H_Min_Esfera = p_Min_Esfera.z
int f_Actual = 0;

float d_Esfera(vec3 p, float r) { 
    return length(p) - r;
}

float d_Plano( vec3 p, vec3 n, float h ) {
    //n direccion
    return dot(p,-n) - h;
}

/*
actualizo posicion cada frame en f de tiempo. 
iTimeDelta (f) = Tiempo/frame, 16ms/frame
iFrameRate(t)
*/
float d_Supcie(vec3 p) {
    if (f_Actual != iFrame) { 
        /*
        estas variables son ctes durante frameTime
        actualiza solo UNA vez x frametime
        */
        float g = 9.8, v_Term = 55.0, v = 0.0; //v(11) = v_Term

        //v != v_Term
        //float - vec3!!
        if (/*p_Min_Esfera.z*/-r_Esfera-h_Plano > 0.0) { 
            if (v < v_Term) v = g/2.0*iTime; 
            else if (v > v_Term) v = v_Term; 

        } else if (v > 0.0) v = 0.0; //NO funca

        h_Plano += v*iTime;

        /*
        movto SIEMPRE en f(t).
        NO valen operadores de asignacion compuesta que no esten en f de 
        iTime! x la volatilidad/efimeridad de los datos solo actualiza 
        para el frametime y no conserva valores de variables/datos
        */
        f_Actual = iFrame;
    }
    
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
            /*
            es_Esfera
            se puede calcular marchando rayo desde infierno hasta esfera
            o desde dentro hacia fuera cuando rayo tenga valores 
            ascendentes
            if (f_D_Supcie == d_Esfera(p, r_Esfera) && 
                p_Min_Esfera.z > p.z) p_Min_Esfera = p;
            esto NO se puede hacer x falta de PERSISTENCIA
            tmb se podria hacer x GRADIENTE
            */
                                            
            col = normalize(col-p); //col direccion, vec3(1);
        
        } else f_D_Supcie = d_Supcie(p);
    }
             
    /*
    analogia p = vt en r3
    // Time varying pixel color
    vec3 col = 0.5 + 0.5*cos(iTime+uv.xyx+vec3(0,2,4));
    */
    
    fragColor = vec4(col,1.0);
}
