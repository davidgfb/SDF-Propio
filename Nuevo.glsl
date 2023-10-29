///////////// debug //////////////
// This code is released into the public domain.
// If you need a license instead, consider this CC0, MIT or BSD licensed, take your pick.
// Remember to set iChannel3 to the font texture
// If you want to print digits larger than 99999, increase MAX_DIGITS

#define MAX_DIGITS    5
#define BASE         10
#define DIGIT_WIDTH  20.0
#define DIGIT_HEIGHT 20.0

#define PLUS_SIGN  vec2(11.0, 13.0)
#define MINUS_SIGN vec2(13.0, 13.0)
#define DOT        vec2(14.0, 13.0)

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
    if (uv.x >= 0.0 && uv.x <= 1.0 && uv.y >= 0.0 && uv.y <= 1.0){
        return texture(iChannel3, (uv + char_position)/16.0).r;
    }
    return 0.0;
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

float draw_int(vec2 p, int number){
    return draw_uint_with_sign(p, number, number < 0);
}

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
float d_Supcie(vec3 p) {
    if (f_Actual != iFrame) { 
        /*
        estas variables son ctes durante frameTime
        actualiza solo UNA vez x frametime
        */
        float g = 9.8, v_Term = 55.0, v = 0.0; //v(11) = v_Term

        //v != v_Term
        //float - vec3!!
        //if (/*p_Min_Esfera.z*/-r_Esfera-h_Plano > 0.0) { 
            if (v < v_Term) v = g/2.0*iTime; 
            else if (v > v_Term) v = v_Term; 

        //} else if (v > 0.0) v = 0.0; //NO funca

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
    //////////////// debug //////////////////
    float color = 0.0;
    
    // bottom left of text
    vec2 position = vec2(0.0);
    
    color += draw_float(position, iTime);
    
    position.y += DIGIT_HEIGHT;
    
    color += draw_float(position, 3.14); //print pi
    
    position.y += DIGIT_HEIGHT;
    
    color += draw_int(position, -12345);
    ////////// debug //////////////
        
    fragColor = vec4(col, 1.0) + vec4(color);
}
