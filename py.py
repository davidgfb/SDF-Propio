from math import radians, sin, cos
from numpy.linalg import norm

fov = 45;

def normalize(dire):
    return dire / norm(dire)

r = range(-fov, fov)

for beta in r:
    if beta < 0: beta += 180
    
    for alfa in r: #(angZ = -fov; angZ < fov; angZ++) { #partimos desde esq sup izda
        if alfa < 0: alfa += 180; #4º --> 1er cuad
                   
        alfa_Rads = radians(float(alfa)) #, t = map(posCam); //partimos desde p0 = posCam getDistMinAlObj
        dir_Rayo = tuple(normalize((cos(alfa_Rads), sin(alfa_Rads), 0))); #vec3 p1 = rayCast(normalize(0, cos(ang), 0)); //avanzamos la distancia t en la direccion del rayo           
    
        print((beta, alfa), dir_Rayo)

