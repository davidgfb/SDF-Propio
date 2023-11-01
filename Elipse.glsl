// The MIT License
// Copyright © 2017 Inigo Quilez
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
// See https://iquilezles.org/articles/ellipses
// Analytical computation of the exact bounding box for an arbitrarily oriented 3D elipse. 
// Derivation and more info in the link above
// Similar shaders:
// Cylinder         - 3D BBox : https://www.shadertoy.com/view/MtcXRf
// Ellipse          - 3D BBox : https://www.shadertoy.com/view/Xtjczw
struct bound3 {
    vec3 mMin, mMax;
};

/*---------------------------------------------------------------------------------------
 bounding box for a ellipse (https://iquilezles.org/articles/ellipses)
---------------------------------------------------------------------------------------*/
bound3 EllipseAABB( vec3 c, vec3 u, vec3 v ) { // disk: center, 1st axis, 2nd axis
    vec3 e = sqrt( u*u + v*v ); //NO es float length(u+v)
    
    return bound3( c-e, c+e );
}

// ray-ellipse intersection
float d_Elipse( vec3 ro, vec3 rd, vec3 c, vec3 u, vec3 v ) { 
    /*ray: origin, direction
    disk: center, 1st axis, 2nd axis*/    
	vec3 q = ro - c, u_X_V = cross(u,v), r = vec3(dot( u_X_V, q ),
		 dot( cross(q,u), rd ), dot( cross(v,q), rd ) ) / 
         dot( -u_X_V, rd );
    
    return (dot(r.yz,r.yz)<1.0) ? r.x : -1.0;
}

float hash1( in vec2 p ) {
    return fract(sin(dot(p, vec2(13.0, 78.23)))*43758.55);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec3 tot = vec3(0);
    int AA = 3;
    
    for( int m=0; m<AA; m++ ) {
        for( int n=0; n<AA; n++ ) {
            // pixel coordinates
            vec2 o = vec2(float(m),float(n)) / float(AA) - 0.5,
                 p = (2.0*(fragCoord+o) -iResolution.xy)/iResolution.y;
            //vec2 p = (2.0*fragCoord -iResolution.xy)/iResolution.y;
            // camera position
            vec3 Y = vec3(0,1,0), ro = vec3(-5, 4, 15)/10.0, ta = vec3( 0 ),
                 // camera matrix
                 ww = normalize( ta - ro ), 
                 uu = normalize( cross(ww,Y ) ), 
                 vv = p.y*normalize( cross(uu,ww)),
                 rd = normalize( p.x*uu + vv + 1.5*ww ), //NO es float dot(vec3(p.xy, 1.5),vec3(uu,vv,ww))
                 // create view ray
                 // disk animation
                 disk_center = 0.3*sin(iTime*vec3(111,127,147)/100.0+
                               vec3(2,5,6)),
                 disk_axis = normalize( sin(iTime*vec3(123,141,107)/100.0+
                             vec3(0,1,3)) ),
                 disk_u = 0.3*sin(iTime*vec3(13,11,12)/10.0+vec3(1,0,4)/2.0),
                 disk_v = 0.3*sin(iTime*vec3(10,12,11)/10.0+vec3(4,2,1)),
                 // render
                 col = vec3(2)/5.0*(1.0-0.3*length(p));

            // raytrace disk
            float t = d_Elipse( ro, rd, disk_center, disk_u, disk_v ),
                  tmin = 1e10;

            if( t>0.0 ) {        
                tmin = t;
                col = vec3(10,30.0/4.0,3)/10.0*(0.7+abs(disk_axis.y)/5.0);
            }

            // compute bounding box for disk
            bound3 bbox = EllipseAABB( disk_center, disk_u, disk_v );

            bbox.mMin/=2.0;
            bbox.mMax/=2.0;

            // raytrace bounding box
            vec3 bcen = bbox.mMin+bbox.mMax,
                 brad = bbox.mMax-bbox.mMin;	
            // no gamma required here, it's done in line 118

            tot += col;    
        }
    }
    
    // dithering
	fragColor = vec4( tot/float(AA*AA) + ((hash1(fragCoord.xy)+
                      hash1(fragCoord.yx+13.1))-1.0)/512.0, 1.0 );
}
