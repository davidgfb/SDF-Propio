from math import radians, sin, cos
from numpy.linalg import norm

fov = 45;

def normalize(dire):     
    return dire / norm(dire)

for beta in range(-fov, fov): 
    for alfa in range(-fov, fov): #(angZ = -fov; angZ < fov; angZ++) { #partimos desde esq sup izda
        if alfa < 0: alfa += 180; #4º --> 1er cuad

        #print(angX, angZ)
        
        alfa_Rads = radians(float(alfa)) #, t = map(posCam); //partimos desde p0 = posCam getDistMinAlObj
        dir_Rayo = normalize((cos(alfa_Rads), sin(alfa_Rads), 0)); #vec3 p1 = rayCast(normalize(0, cos(ang), 0)); //avanzamos la distancia t en la direccion del rayo           
    

