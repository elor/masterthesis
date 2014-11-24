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
while True:
    width=10.0+rand()*200
    height=10.0+rand()*200

    triesleft=maxtries
    squares=[]

    while triesleft > 0:
        pos = [width*rand(), height*rand()]
#        print("[ %f\tx\t%f ] @ %f"%(pos[0], pos[1], len(squares)/(width*height), ))
        for pos2 in squares:
            if intersect(pos, pos2, width, height):
                # print("%f,%f / %f,%f"%(pos[0],pos[1],pos2[0],pos2[1]))
                triesleft -= 1
                pos=False
                break;
        if pos:
            squares.append(pos)
            triesleft=maxtries
                    
    print("%d\t%f\t%f"%(len(squares), width*height, len(squares)/(width*height)))
