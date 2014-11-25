#!/usr/bin/env python2

from sys import argv
from random import random as rand

def intersect(pos1, pos2, width, height):
    dx=abs(pos1[0]-pos2[0])
    if dx > width/2:
        dx = width - dx

    dy=abs(pos1[1]-pos2[1])
    if dy > height/2:
        dy = height - dy

    return dx < 1 and dy < 1

print("#aktiv flaeche dichte")
maxtries=int(argv[1])
for simrun in range(0, 100):
    width=10.0+rand()*200
    height=10.0+rand()*200

    num=0
    triesleft=maxtries
    
    squares=[]

    while triesleft > 0:
        pos = [width*rand(), height*rand()]
        for pos2 in squares:
            if intersect(pos, pos2, width, height):
                triesleft -= 1
                num -= 1
                break;
        num += 1
        squares.append(pos)
                    
    print("%d\t%f\t%f"%(num, width*height, num/(width*height)))
