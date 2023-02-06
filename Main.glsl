float h = 1e-3, //h para gradiente
    drawDist = 1e4;
vec3 y = vec3(0, 1, 0);
struct vec5 {
    vec3 c;
    float a;
    bool con;   
};

float map(vec3 p) {
    float r = 0.5;
    
    return min(length(p) - r, p.z + r);
}

bool esPequegno(float t) {
    return t < h; //t < 1e-3    
}

bool esMasPequegno(float t) {    
    float h1 = h / 10.0; //t < 1e-4 (<< 1e-3)
    
    return t < h1;
}

vec3 getNormal(vec3 p) { //gradiente normaliza entre [0, 1]. Ej: (-1 + 1) / 2 = 0, (1 + 1) / 2 = 1
    return (normalize(map(p) - vec3(map(vec3(-h, 0, 0) + p), 
        map(-h * y + p), map(vec3(0, 0, -h) + p))) + 1.0) / 2.0;
}

float get_TotalDist(vec3 R_O, vec3 ro) {
    return length(ro - R_O);
}

bool getCond(float t, bool cond1) {
    bool cond = esPequegno(t);
        
    if (cond1) cond = esMasPequegno(t); //Sombras
    
    return cond;
}

vec5 rayMarch(vec3 ro, vec3 rd, float t, bool cond1) {
    vec3 R_O = ro; //puede ser el origen del rayo sombra
    float totalDist = get_TotalDist(ro, R_O); 
    bool cond = getCond(t, cond1);

    while (!cond && totalDist < drawDist) { //bEsCero = false --> !bEsCero = true 
        ro += rd * t;
        totalDist = get_TotalDist(ro, R_O);
        t = map(ro);                   
        
        cond = getCond(t, cond1);
    }
    
    return vec5(ro, t, cond);
}

vec5 rayMarch(vec3 ro, vec3 rd, float t) {
    return rayMarch(ro, rd, t, false);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
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
    vec3 ro = -y,
        rd = normalize(vec3((2.0 / iResolution.xy * 
        fragCoord - vec2(1)), 1)), //z = 1      
        color = vec3(0); 
    //vec3 posLuz = vec3(1); //pto luz 
    float t = map(ro); 
              
    rd.x *= iResolution.x / iResolution.y;                 
    rd = rd.xzy; //z --> y = 1, y --> z, x cte             
    vec5 vRayMarch = rayMarch(ro, rd, t);
    ro = vRayMarch.c;
    t = vRayMarch.a; //*= 2.0; 
           
    if (vRayMarch.con) { //sombra directa
        color = getNormal(ro);     
         
        rd = vec3(1); //y = contraluz, -y desde cam vec3(1); -1? luz direccional vec3(0, 0, 1) normalize(posLuz - ro);                
        
        if (rayMarch(ro, rd, t, true).con) color -= vec3(0.1);
    }
         
    fragColor = vec4(color, 1);    
}
