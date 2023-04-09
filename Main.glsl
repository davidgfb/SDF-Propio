float h = 1e-5, drawDist = 200.0; //h para gradiente    
vec3 y = vec3(0, 1, 0);
struct RayMarch {
    vec3 c;
    float a;
    bool con;   
};
struct Rayo {
    vec3 origen, dire;
};

/*float mapSombra(vec3 p) {
   float r = 0.5;
   
   return min(min(length(p) - r, length(p - vec3(1, 1, 0)) - r), p.z + r); //0.8 * vec3(1, 0, 1)
}*/

float supcie(vec2 p) {
    return sin(p.x) * sin(p.y);
}

vec2 posEsf = -vec2(-1, 1); //z es calculado, calcula BIEN!!! pueden ser las normales!!!
float mapLuz(vec3 p) {
    float r = 0.5,
        pos = length(p + vec3(posEsf, supcie(posEsf))) - r; //p - INVERTIDO? x q NO funciona bien?
    
    //posEsf.y += iTime; //posEsf += y.xy * iTime; 
    
    return min(pos, supcie(p.xy) + p.z + r); 
}

bool esPequegno(float t) {
    return t < h; //t < 1e-3    
}

bool esMasPequegno(float t) {        
    return esPequegno(10.0 * t); //t < 1e-4 (<< 1e-3), t < h1;
}

vec3 getNormal(vec3 p) { //gradiente normaliza entre [0, 1]. Ej: (-1 + 1) / 2 = 0, (1 + 1) / 2 = 1
    //return vec3(1);
    vec3 normal = (normalize(mapLuz(p) - vec3(mapLuz(vec3(-h, 0, 0) + p), 
        mapLuz(-h * y + p), mapLuz(vec3(0, 0, -h) + p))) + 1.0) / 2.0;
    float r = 0.5,
        supEsf = length(p + vec3(posEsf, supcie(posEsf))) - r;
    
    if (supEsf < 1e-3) normal = vec3(1, 0, 0); 

    return normal; /*(normalize(mapLuz(p) - vec3(mapLuz(vec3(-h, 0, 0) + p), 
        mapLuz(-h * y + p), mapLuz(vec3(0, 0, -h) + p))) + 1.0) / 2.0;*/
}

float get_TotalDist(vec3 R_O, vec3 ro) {
    return length(ro - R_O);
}

bool getCond(float t, bool cond1) {
    bool cond = esPequegno(t);
        
    if (cond1) cond = esMasPequegno(t); //Sombras
    
    return cond;
}

float getMapSombra(bool cond, Rayo rayo, float t) {
    if (cond) t = mapLuz(rayo.origen); //mapSombra(rayo.origen);

    return t;
}

RayMarch getRayMarch(Rayo rayo, bool cond1) {
    vec3 R_O = rayo.origen; //puede ser el origen del rayo sombra
    float totalDist = get_TotalDist(rayo.origen, R_O),
        t = mapLuz(rayo.origen); 
    bool cond = getCond(t, cond1);
    
    t = getMapSombra(cond1, rayo, t);
    
    if (cond1) cond = getCond(t, cond1);

    while (!cond && totalDist < drawDist) { //bEsCero = false --> !bEsCero = true 
        rayo.origen += rayo.dire * t;
        totalDist = get_TotalDist(rayo.origen, R_O);                          
        t = getMapSombra(cond1, rayo, mapLuz(rayo.origen));
                
        cond = getCond(t, cond1);
    }
    
    return RayMarch(rayo.origen, t, cond);
}

RayMarch getRayMarch(Rayo rayo) {
    return getRayMarch(rayo, false);
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
    Rayo rayo = Rayo(-2.0*y/* * iTime*/, normalize(vec3((2.0 / iResolution.xy * 
        fragCoord - vec2(1)), 1))); //z = 1      
    vec3 color = vec3(0);         
    //vec3 posLuz = vec3(1); //pto luz                
    rayo.dire = vec3(rayo.dire.x / iResolution.y * iResolution.x, rayo.dire.zy); //z --> y = 1, y --> z, x cte 
    RayMarch rayMarch = getRayMarch(rayo);
    rayo.origen = rayMarch.c;
               
    if (rayMarch.con) { //sombra directa
        color = getNormal(rayo.origen);            
        rayo.dire = vec3(1); //y = contraluz, -y desde cam vec3(1); -1? luz direccional vec3(0, 0, 1) normalize(posLuz - ro);                
        
        if (getRayMarch(rayo, true).con) color -= vec3(0.1);
    }
         
    fragColor = vec4(color, 1);    
}
