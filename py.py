from math import radians, sin, cos
from numpy.linalg import norm

fov = 45;

def normalize(x,y,z): #dire):
    dire = (x,y,z)
    
    return dire / norm(dire)

for angX in range(-fov, fov): 
    for angZ in range(-fov, fov): #(angZ = -fov; angZ < fov; angZ++) { #partimos desde esq sup izda
        if angZ < 0: angZ += 180; #4º --> 1er cuad

        #print(angX, angZ)
        
        angZ_Rads = radians(float(angZ)) #, t = map(posCam); //partimos desde p0 = posCam getDistMinAlObj
        dir_Rayo = normalize(cos(angZ_Rads), sin(angZ_Rads), 0); #vec3 p1 = rayCast(normalize(0, cos(ang), 0)); //avanzamos la distancia t en la direccion del rayo           
    

