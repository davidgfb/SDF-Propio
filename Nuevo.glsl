///////////// debug //////////////
// This code is released into the public domain.
// If you need a license instead, consider this CC0, MIT or BSD licensed, take your pick.
// Remember to set iChannel3 to the font texture
// If you want to print digits larger than 99999, increase MAX_DIGITS
int MAX_DIGITS = 5, BASE = 10;
float DIGIT_WIDTH = 20.0, DIGIT_HEIGHT = 20.0;
vec2 PLUS_SIGN = vec2(11.0, 13.0), MINUS_SIGN = vec2(13.0, 13.0),
    DOT = vec2(14.0, 13.0);

int idiv(int a, int b){
    // If you encounter precision loss, this is probably the reason.
    return int(float(a)/float(b));
}

int imod(int a, int b){
    return a - idiv(a, b)*b;
}

// draw a character where p is bottom left
float draw_char(vec2 p, vec2 char_position){
    vec2 uv = (gl_FragCoord.xy - p)/vec2(DIGIT_WIDTH, DIGIT_HEIGHT);
    float res = 0.0;
        
    if (uv.x >= 0.0 && uv.x <= 1.0 && uv.y >= 0.0 && uv.y <= 1.0)
        res = texture(iChannel3, (uv + char_position)/16.0).r;
        
    return res;
}

// draw a digit between 0-9
float draw_digit(vec2 p, int digit){
    return draw_char(p, vec2(float(digit), 12.0));
}

// draw an unsigned integer
float draw_uint(vec2 p, int number){
    number = abs(number);
    
    // we draw numbers from right to left because we get digits in that order
    p.x += float(MAX_DIGITS - 1)*DIGIT_WIDTH;
    
    float color = 0.0;
    
    // decompose number into digits
    for (int i = 0; i < MAX_DIGITS; i++){
        int digit = imod(number, BASE);
        number = idiv(number, BASE);
        
        color += draw_digit(p, digit);
        
        p.x -= DIGIT_WIDTH;
    }
    
    return color;
}

// draw an unsigned integer with a sign in front
float draw_uint_with_sign(vec2 p, int number, bool negative){
    // draw sign
    float color = draw_char(p, negative ? MINUS_SIGN : PLUS_SIGN);
    p.x += DIGIT_WIDTH;
    
    // draw uint
    color += draw_uint(p, number);
    
    return color;
}

/*
float draw_int(vec2 p, int number){
    return draw_uint_with_sign(p, number, number < 0);
}
*/

float draw_float(vec2 p, float f){
    float color = draw_uint_with_sign(p, int(f), f < 0.0);
    p.x += float(MAX_DIGITS + 1)*DIGIT_WIDTH;
    
    // draw dot
    color += draw_char(p, DOT);
    p.x += DIGIT_WIDTH;
    
    // remove integer part
    f -= float(int(f));
    // shift fractional part into integer part
    f *= pow(float(BASE), float(MAX_DIGITS));
    
    // draw fractional part
    color += draw_uint(p, int(f));
    
    return color;
}
/////////////// debug ///////////////
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
float v1 = 0.0, v_Term = 55.0;
float cond = 0.0;

float d_Supcie(vec3 p) {
    if (f_Actual != iFrame) { 
        /*
        estas variables son ctes durante frameTime
        actualiza solo UNA vez x frametime
        */
        float g = 9.8; //, v_Term = 55.0, v = 0.0; //v(11) = v_Term
        //v != v_Term
        //float - vec3!!, 300>200
        //AQUÍ v1 NO esta actualizado
        //hay q calcularlo para cada frameTime
        //NO es persistente
        //float t = 0.0; //si no actualizo t -> 0
        v1 = g*iTime;
        //v1 = g/2.0*t; //t
        //AHORA SÍ esta actualizado                
        //calculo
        h_Plano += v1*iTime;
        //h_Plano += v1*t;        
        //fuerzo a q plano y esfera esten en cto        
        //cond = float(r_Esfera-h_Plano1 > 2.0*r_Esfera); //NO funca bien       
        //p_Min_Esfera.z                                                             
        if (r_Esfera-h_Plano < 2.0*r_Esfera) { //v1 > 0.0) {
            h_Plano = -r_Esfera; 
            v1 = 0.0;
        }        
        
        if (v1 > v_Term) v1 = v_Term;
        
        cond = v1;
        //h_Plano1 = h_Plano + iTime; //v1 = 0.0; //NO funca      
        //v1 = g/2.0*t;
        //h_Plano = h_Plano1; // + v1*t; //asigno NO +=!!

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

struct F {
    float c, y;
};

F draw_float(float color, vec2 pos, float n, float D_H) {
    color += draw_float(pos, n);
    pos.y += D_H;
    
    return F(color, pos.y); 
}

void mainImage( out vec4 fragColor, vec2 fragCoord ) {
    /*
    falta añadir el origen de la cam detras del plano fragcoord
    proy ortogonal/normal para perspectiva v = fragcoord - origen_Cam
    normalizo v en coord polares
    */
    fragCoord *= 1e3 / iResolution.x; //cte / variable, 1000/800=1.25
    //1000/1920 = 0.52
    
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
                                     
            //bottom left of text
            vec2 position = vec2(0.0);
            
            //aqui las cosas SÍ  funcan. Arriba NO
            //float cond = v1; //float(v1 > v_Term); //v1 < v_Term); //r_Esfera-h_Plano > 2.0*r_Esfera)
            col += draw_float(position, cond);

            position.y += DIGIT_HEIGHT;            
        
        } else f_D_Supcie = d_Supcie(p);
    }
             
    /*
    analogia p = vt en r3
    // Time varying pixel color
    vec3 col = 0.5 + 0.5*cos(iTime+uv.xyx+vec3(0,2,4));
    */   
    
    //////////////// debug //////////////////
    float color = 0.0;
    
    // bottom left of text
    vec2 position = vec2(0.0);
    
    /*color += draw_float(position, v);

    position.y += DIGIT_HEIGHT;
    
    //fragCoord.x, .y no representa bien
    F f = draw_float(color, position, v, DIGIT_HEIGHT);
    color = f.c; //2.0*r_Esfera r_Esfera-h_Plano
    position.y = f.y;    
    
    f = draw_float(color, position, 3.14, DIGIT_HEIGHT);
    color = f.c;
    position.y = f.y;
    */
    ////////// debug //////////////
        
    fragColor = vec4(col, 1.0) + vec4(color);
}
