/*
Based on "EWA Volume Splatting" paper   (EWA = Elliptical Weighted Average)
by Matthias Zwicker, Hanspeter Pfister, Jeroen van Baar and Markus Gross
https://cgl.ethz.ch/Downloads/Publications/Papers/2001/p_Zwi01b.pdf
Note, there seems to be a newer version here (2002):
https://www.cs.umd.edu/~zwicker/publications/EWASplatting-TVCG02.pdf
I opted to implement this straightforwardly and directly from the paper,
as a consequence there's a lot of wasteful computation being performed.
Particularly because most operations uses matrix multiplication where not necessary.
Even so they could be rearranged in a more efficient manner.
For example:
For rotations, inverse(R) = traspose(R), and det(R) = det(inv(R)) = 1
Scaling can be performed by vector multiplication, since they are diagonal matrices here.
matrices that are repeated, like in: u = v^T *M^T * M * v can instead be computed as 
w = M * v; u = dot(w, w)
etc...
// Notation from paper:
t_k = center of the gaussian in world space
u = phi(t) = Wt + d = viewing transformation ( for matrix W and translation vector d)
u_k = phi(t_k) = center of gaussian in camera space
m(u) = perspective transform ( z division )
x_k = m(u_k) = center of gaussian in ray space ( screenspace + depth, after projection)
x_hat = screenspace coordinates
x_hat_k = gaussian center in screenspace
This method is used for rendering 3D Gaussians in the paper
"3D Gaussian Splatting for Real-Time Radiance Field Rendering"
https://repo-sam.inria.fr/fungraph/3d-gaussian-splatting/3d_gaussian_splatting_high.pdf
*/
// Jacobian for linear approximation of perspective transform (z-divide)
mat3 JacobianOfM_u(vec3 u)
{
    vec3 last_row = u / length(u); //u normalizado
    
    float inv_U_Z = 1./u.z, u_Z_Cuad = u.z*u.z;
    
    mat3 J = mat3(inv_U_Z, 0.,last_row.x,
                  0., inv_U_Z, last_row.y,
        -u.x/u_Z_Cuad, -u.y/u_Z_Cuad, last_row.z);
    
    return J;
}

// Based on formula from wikipedia :)
mat3 RotationMatrix(vec3 axis, float angle)
{
    float c = cos(angle), s = sin(angle);
    
    return mat3(c) + s * mat3(0, axis.z, -axis.y, 
                              -axis.z, 0, axis.x, 
                              axis.y, -axis.x, 0) + (1.-c) * 
                              outerProduct(axis, axis);
}

float gaussian(mat3 V, vec3 x) { // 3D gaussian tocho
    return exp(-dot(x, inverse(V)*x)/2.0) / (2. * PI *sqrt(determinant(V)));
}

float gaussian(mat2 V, vec2 x) { // 2D gaussian
    //OJO V[2][2] = 1 para mantener determinante
    //y aumentar el orden
    return gaussian( mat3(V),  vec3(x, 0)); 
}

// Computes eq 21:
//G_V_hat_k(x_hat - x_hat_k) / (det(inv(J)) * det(inv(W))
// But starting from gaussian center in cameraspace
float gaussianSplat(vec3 u_k, vec3 scale, mat3 R, vec2 x_hat)
{
    // Camera rotation
    mat3 W = transpose(R);
    float invDetW = determinant(inverse(W)); // For rotation matrices, the inverse is the transpose and the determinant is 1

    // In the paper, u.z is positive in the forward direction in camera space
    u_k.z *= -1.;
    
    // Compute ray space center of gaussian (eq 15 and 17)
    vec3 x_k = vec3(u_k.x/u_k.z, u_k.y/u_k.z, length(u_k));
    
    // Compute linear approximation to perspective transform  (eq 18)
    mat3 J = JacobianOfM_u(u_k);
    float invDetJ = determinant(inverse(J));
    
    vec2 x_hat_k = x_k.xy, x = x_hat - x_hat_k;
    
    // Compute 3D variace matrix
    mat3 S = mat3(scale.x,0,0, 
                  0,scale.y,0, 
                  0,0,scale.z), V_dprime_k = S*transpose(S),
                  V_prime_k = W * V_dprime_k * transpose(W),
                  V_k = J * V_prime_k * transpose(J);
    
    mat2 V_hat_k = mat2(V_k[0].xy, V_k[1].xy); 
    // 3D to 2D integration for gaussians
    
    return gaussian(V_hat_k, x) / (invDetJ * invDetW);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    float time = iTime; // Just a convenient way to scale time

    vec2 uv = (2. * fragCoord-iResolution.xy)/iResolution.y,
         mouse = (2. * iMouse.xy-iResolution.xy)/iResolution.y;
    
    // Idle mouse animation
    if(length(iMouse.xy) < 10.) mouse = vec2(cos(time), sin(time));
    
    //float pix_size = 2. / iResolution.y; // Unused atm
    
    float focal = 1.; // TODO: Change perspective transform and u_k to allow focal != 1.

    vec3 Camera_Position = vec3(0, 0, 3. + sin(time / 2.)),
         rd = normalize(vec3(uv, -focal));
    
    mat3 Tilt = RotationMatrix(vec3(1,0,0), -mouse.y);
    
    float angle = -mouse.x * PI;

    vec3 color = vec3(0), box_center = vec3(cos(iTime)/4.0, 0, 0); 
    // t_k
    float radius = 1.;

    vec3 axis = normalize(vec3(0,1,0));
    mat3 Camera_Rotation = RotationMatrix(axis, angle) * Tilt;

    vec3 ro = Camera_Rotation * Camera_Position; 
    // ray origin world space
    
    // Ray tracing box & splatting gaussian   
    vec2 T = RayBox(ro, Camera_Rotation * rd, box_center, vec3(radius));

    // Parameters for ray entering and ray exiting box for volumetric calculations.
    float t_enter = min(T.x, T.y), t_exit = max(T.x, T.y), t = T.x;
    
    if(T.t >= 0. && (T.y < T.x)) t = T.y;

    // Draw box
    /*
    if(t > 0.) {
        vec3 p = Camera_Rotation*rd * t + ro;
        vec3 pos_color = (normalize(p - box_center) + 1.) / 2.;
        float opacity = 0.9;
        color += exp(-2.5*(T.y - T.x)) * opacity * pos_color;
    }
    */
    
    vec3 gaussian_center = box_center, //vec3(0,0,0); // t_k
         gaussian_scale = vec3(0.4, 0.1, 0.2);
    
    // Convert world space center (t_k) to cameraspace center (u_k)
    mat3 W = transpose(Camera_Rotation);
    vec3 d = - Camera_Position, u_k = W * gaussian_center + d;
    
    // Splat the gaussian!
    if(u_k.z < 0.) 
        color += gaussianSplat(u_k, gaussian_scale, Camera_Rotation, uv);
                
    // Draw center of gaussian as green dot    
    /*
    T = RaySphere(ro, Camera_Rotation * rd, gaussian_center, 0.05);
    
    if(T.x > 0.) color = vec3(0,1,0);
        
    // Draw center of box as blue dot
    T = RaySphere(ro, Camera_Rotation * rd, box_center, 0.025);
    
    if(T.x > 0.) color = vec3(1,0,0);
    */
          
    fragColor = vec4(sRGBencode(tanh(color)), 1.0);
}
