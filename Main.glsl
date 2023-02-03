const float h = 1e-3, h1 = h / 10.0; //h para gradiente
vec3 y = vec3(0, 1, 0);

float map(vec3 p) {
    float r = 0.5;
    
    return min(length(p) - r, p.z + r);
}

bool esCero(float t) {
    return t < h;
}

bool esMayorQ_Cero(float t) {
    return t > h1;
}

vec3 getNormal(vec3 p) { //gradiente normaliza entre [0, 1]. Ej: (-1 + 1) / 2 = 0, (1 + 1) / 2 = 1
    return (normalize(map(p) - vec3(map(vec3(-h, 0, 0) + p), 
        map(-h * y + p), map(vec3(0, 0, -h) + p))) + 1.0) / 2.0;
}

/*vec4 rayMarch(bool cond, int nPasos, vec3 ro, vec3 rd, float t) {
    for (int i = 0; cond && i < nPasos; i++) { 
        ro += rd * t;        
        t = map(ro);                   
        //esCero = getEsCero(t);        
    }
    
    return vec4(ro, t);
}

vec4 rayMarch(bool cond, int nPasos, vec3 ro, vec3 rd, float t) {
    return rayMarch(cond, nPasos, ro, rd, t, false);
}*/

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    int nPasos_Luz = int(1e4), //10 crea un efecto chulo
        nPasos_Sombra = nPasos_Luz / 10; //100;
    vec3 ro = -y,
        rd = normalize(vec3((2.0 / iResolution.xy * 
        fragCoord - vec2(1)), 1)), //z = 1      
        color = vec3(0); 
    //vec3 posLuz = vec3(1); //pto luz 
    float t = map(ro); 
    bool cond = esCero(t);
        
    rd.x *= iResolution.x / iResolution.y;                 
    rd = rd.xzy; //z --> y = 1, y --> z, x cte         
    
    for (int i = 0; !cond && i < nPasos_Luz; i++) { 
        ro += rd * t;        
        t = map(ro);         
        cond = esCero(t);
    }
    
    /*vec4 vRayMarch = rayMarch(!getEsCero(t), nPasos_Luz, ro, rd, t);
    ro = vRayMarch.xyz;
    t = vRayMarch.a;*/
    
    color = getNormal(ro); //no hay contacto (i = 1000)  
        
    if (cond) { //sombra directa 
        cond = esMayorQ_Cero(t);
        rd = vec3(1); //luz direccional //vec3(0, 1, 0); //normalize(posLuz - ro);
        
        /*vec4 vRayMarch = rayMarch(t > h1, nPasos_Sombra, ro, rd, t);
        ro = vRayMarch.xyz;
        t = vRayMarch.a;*/
        
        for (int i = 0; cond && i < nPasos_Sombra; i++) { 
            ro += rd * t;        
            t = map(ro); 
            cond = esMayorQ_Cero(t);
        }
   
        if (!cond) color -= vec3(0.1);         
    }
         
    fragColor = vec4(color, 1);    
}

/*rd.x /= 1.0 / iResolution.x * iResolution.y; 
rd.x /= iResolution.y;
rd.x *= iResolution.x;
*/