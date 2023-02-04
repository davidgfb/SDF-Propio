const float h = 1e-3; //h para gradiente
vec3 y = vec3(0, 1, 0);

struct vec5 {
    vec3 c;
    float a;
    bool con;   
};

float map(vec3 p) {
    float r = 0.5;
    
    //return length(p) - r;
    return min(length(p) - r, p.z + r);
    //return p.z + r;
}

bool esPequegno(float t) {
    return t < h; //t < 1e-3    
}

bool esMasPequegno(float t) {    
    float h1 = h / 10.0; //t << 1e-4
    
    return t < h1;
}

vec3 getNormal(vec3 p) { //gradiente normaliza entre [0, 1]. Ej: (-1 + 1) / 2 = 0, (1 + 1) / 2 = 1
    return (normalize(map(p) - vec3(map(vec3(-h, 0, 0) + p), 
        map(-h * y + p), map(vec3(0, 0, -h) + p))) + 1.0) / 2.0;
}

vec5 rayMarch(bool cond, int nPasos, vec3 ro, vec3 rd, float t, bool cond1) {
    for (int i = 0; !cond && i < nPasos; i++) { //bEsCero = false --> !bEsCero = true 
        ro += rd * t;        
        t = map(ro);                   
        cond = esPequegno(t);
        
        if (cond1) cond = esMasPequegno(t); //Sombras
    }
    
    return vec5(ro, t, cond);
}

/*vec4 rayMarch(bool cond, int nPasos, vec3 ro, vec3 rd, float t) {
    return rayMarch(cond, nPasos, ro, rd, t, false);
}*/

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    int nPasos_Luz = int(1e4), //10 crea un efecto chulo
        nPasos_Sombra = nPasos_Luz / 10; //100;
    vec3 ro = -y,
        rd = normalize(vec3((2.0 / iResolution.xy * 
        fragCoord - vec2(1)), 1)), //z = 1      
        color = vec3(0); 
    //vec3 posLuz = vec3(1); //pto luz 
    float t = map(ro); 
    bool cond = esPequegno(t);
        
    rd.x *= iResolution.x / iResolution.y;                 
    rd = rd.xzy; //z --> y = 1, y --> z, x cte         
    
    /*for (int i = 0; !cond && i < nPasos_Luz; i++) { 
        ro += rd * t;        
        t = map(ro);         
        cond = esPequegno(t);
    }*/
    
    vec5 vRayMarch = rayMarch(cond, nPasos_Luz, ro, rd, t, false);
    ro = vRayMarch.c;
    t = vRayMarch.a; //*= 2.0; 
           
    if (vRayMarch.con) { //sombra directa
        color = getNormal(ro);     
        cond = esMasPequegno(t);
        rd = vec3(1); //-1? //luz direccional //vec3(0, 1, 0); //normalize(posLuz - ro);                
        vec5 vRayMarch = rayMarch(cond, nPasos_Sombra, ro, rd, t, true);
        t = vRayMarch.a;
        
        /*for (int i = 0; !cond && i < nPasos_Sombra; i++) { 
            ro += rd * t;        
            t = map(ro); 
            cond = esMasPequegno(t);
        }
   
        if (cond) color -= vec3(0.1);*/
        
        if (vRayMarch.con) color -= vec3(0.1);
    }
         
    fragColor = vec4(color, 1);    
}

/*rd.x /= 1.0 / iResolution.x * iResolution.y; 
rd.x /= iResolution.y;
rd.x *= iResolution.x;
*/
