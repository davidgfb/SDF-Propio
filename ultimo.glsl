float map(vec3 p) {
    return length(p) - 0.5;
    //return min(length(p) - 0.5, p.z + 1.0);
    //return p.z + 1.0;
}

bool getEsCero(float t) {
    return t < 0.1;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    /*OBJ: fragCoord / iResolution.xy (uv) normaliza 
    la pos del pixel en pantalla entre [0, 1] en 
    euclideas NO en polares [-1, 1]!
    El origen esta en la esq inf izda!
    fragCoord = pos pixel en pantalla
    iResolution = resolucion pantalla
    ej: 1er pixel esq inf izda: (0.5, 0.5) / 
    (1920, 1080) = (0, 0)    
    n-esimo pixel esq sup dcha: (1919'5, 1079'5) / 
    (1920, 1080) = (1, 1)  
    
    rd normaliza uv entre [-1, 1]
    ej: (0, 0): 2 * (0, 0) - (1, 1) = 
    (0, 0) - (1, 1) = (-1, -1) 
    (1, 1): 2 * (1, 1) - (1, 1) = 
    (2, 2) - (1, 1) = (1, 1) 
    iResolution.x / iResolution.y corrige la 
    relacion de aspecto
    normalize coordenadas: euclideas --> polares    
    rd = rd.xzy transforma xyz en xzy
    TODO: origen en esq sup izda
    */
    vec3 frente = vec3(0, 1, 0), //coordenada y
        ro = -frente,
        rd = normalize(vec3((2.0 / iResolution.xy * 
        fragCoord - vec2(1)), 1)), //z = 1
        color = vec3(0);    
    float t = map(ro),
        tMin = t;
    bool esCero = getEsCero(t);
    
    rd.x *= iResolution.x / iResolution.y;
                 
    rd = rd.xzy; //z --> y = 1, y --> z, x cte
         
    while (!esCero && t <= tMin) { //'=' para el 1er paso
        ro += rd * t;
        
        float t1 = map(ro); 
        
        t = t1;
        esCero = getEsCero(t1);
        
        if (t1 < tMin) { //NO tMin = t sin t = t1!
            tMin = t1;
        }
    }
    
    fragColor = vec4(vec3(int(esCero)), 1);    
}

/*rd.x /= 1.0 / iResolution.x * iResolution.y; 
rd.x /= iResolution.y;
rd.x *= iResolution.x;
*/
