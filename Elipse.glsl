/* See https://iquilezles.org/articles/ellipses
Ellipse          - 3D BBox : https://www.shadertoy.com/view/Xtjczw
---------------------------------------------------------------------------------------
 bounding box for a ellipse (https://iquilezles.org/articles/ellipses)
---------------------------------------------------------------------------------------
ray-ellipse intersection
*/
float d_Elipse( vec3[5] elipse_Cuv ) {
    /*ray: origin, direction
    disk: center, 1st axis, 2nd axis*/ 
    vec3 ro = elipse_Cuv[0], rd = elipse_Cuv[1], c = elipse_Cuv[2], 
         u = elipse_Cuv[3], v = elipse_Cuv[4], q = ro - c, 
         u_X_V = cross(u,v), r = vec3(dot(u_X_V, q),dot(cross(q,u), rd), 
                                 dot( cross(v,q), rd ))/dot( -u_X_V, rd);
    
    return (dot(r.yz,r.yz)<1.0) ? r.x : -1.0;
}

float hash1( in vec2 p ) {
    return fract(sin(dot(p, vec2(13.0, 78.23)))*43758.55);
}

float d_Supcie(float[2] supcies) {
    return min(supcies[0], supcies[1]);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec3 tot = vec3(0);
    int AA = 3;
    
    for( int m=0; m<AA; m++ ) {
        for( int n=0; n<AA; n++ ) {
            //float t = 0.0;
            // pixel coordinates
            vec2 o = vec2(float(m),float(n)) / float(AA) - 0.5,
                 p = (2.0*(fragCoord+o) -iResolution.xy)/iResolution.y;
            //vec2 p = (2.0*fragCoord -iResolution.xy)/iResolution.y;
            // camera position
            vec3 Y = vec3(0,1,0), ro = vec3(0, -4, 10)/10.0,ta = vec3(0),
                 // camera matrix
                 ww = normalize( ta - ro ), 
                 uu = normalize( cross(ww,Y ) ), 
                 vv = p.y*normalize( cross(uu,ww)),
                 rd = normalize( p.x*uu + vv + 1.5*ww ), //NO es float dot(vec3(p.xy, 1.5),vec3(uu,vv,ww))               
                 // render
                 col = vec3(2)/5.0*(1.0-0.3*length(p)), 
                 elipse_axis = vec3(1);
                   
            float[] ds_Supcies = float[](d_Elipse(vec3[] (ro, rd, vec3(0),
                                                          vec3(0.3), 
                                                          vec3(0,0,0.3))),
                                         d_Elipse(vec3[] (ro, rd, vec3(0),
                                                          vec3(0.3),
                                                          vec3(0,0.3,0.3))));       
                   
            // raytrace elipse, //center;
            if( d_Supcie(ds_Supcies)>0.0 ) 
                col = vec3(10,30.0/4.0,3)/10.0*(0.7+abs(elipse_axis.y)/5.0);
            
            tot += col;    
        }
    }
    
    // dithering
	fragColor = vec4( tot/float(AA*AA) + ((hash1(fragCoord.xy)+
                      hash1(fragCoord.yx+13.1))-1.0)/512.0, 1.0 );
}
