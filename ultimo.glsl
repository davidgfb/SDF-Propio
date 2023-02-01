float h = 1e-3, r = 0.5;
vec3 y = vec3(0, 1, 0);
int nPasos_Sombra = 100;

float map(vec3 p) {
    return min(length(p) - r, p.z + r);
}

bool getEsCero(float t) {
    return t < h;
}

vec3 getNormal(vec3 p) { //gradiente normaliza entre [0, 1]. Ej: (-1 + 1) / 2 = 0, (1 + 1) / 2 = 1
    return (normalize(map(p) - 
        vec3(map(-h * vec3(1,0,0) + p),
        map(-h * y + p), 
        map(-h * vec3(0,0,1) + p))) + 1.0) / 2.0;
}

/*vec3 rayCast(bool esCero, vec3 ro, vec3 rd, float t) {
    for (int i = 0; !esCero && i < 1000; i++) { 
        ro += rd * t;        
        t = map(ro);         
        esCero = getEsCero(t);
    }
    
    return ro;
}*/

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec3 ro = -y,
        rd = normalize(vec3((2.0 / iResolution.xy * 
        fragCoord - vec2(1)), 1)), //z = 1      
        color = vec3(0),
        posLuz = vec3(10); //pto luz 
    float t = map(ro); 
    bool esCero = getEsCero(t);
        
    rd.x *= iResolution.x / iResolution.y;                 
    rd = rd.xzy; //z --> y = 1, y --> z, x cte         
    
    for (int i = 0; !esCero && i < 1000; i++) { 
        ro += rd * t;        
        t = map(ro);         
        esCero = getEsCero(t);
    }
    //ro = rayCast(esCero, ro, rd, t);
        
    color = getNormal(ro); //no hay contacto (i = 1000)   
        
    //rayCast(); 
    if (esCero) { //sombra luz directa 
        esCero = false;
        rd = vec3(1); //luz direccional //vec3(0, 1, 0); //normalize(posLuz - ro);
        
        for (int i = 0; t > 1e-4 && i < nPasos_Sombra; i++) { 
            ro += rd * t;        
            t = map(ro);                     
        }
   
        if (t <= 1e-4) color -= vec3(0.1);         
    } 
         
    fragColor = vec4(color, 1);    
}

/*rd.x /= 1.0 / iResolution.x * iResolution.y; 
rd.x /= iResolution.y;
rd.x *= iResolution.x;
*/
