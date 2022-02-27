# Ecology Project

This is a project that aims to simulate a virtual ecosystem with digital creatures interacting with each other. 

## Overview

The code simulates the situation where a predator attempts to hund down the preys. From the start, their locations are randomly generated. For each prey, they are constantly running away from the predator. On the other hand, the predator locates the nearest prey at any given time and chase it down at a higher speed. However, the prey being chased will escape from the predator at a even higher speed because of its survival instincts. The preys has smaller weights so that they are more agile while the predator is more heavy.

Right now, only the chasing part is done. In the future, I want to add features like preys being eaten by the predator, predator staying idle after a feast, and both preys and predators will reproduce and age. 

## Lessons Learned

Collision is hard to implement, need to look into Box2D chapture in the book. Also, displaying images instead of a mere shape is also tricky since we want it to always orient to the right direction.

## Screenshots

![loading-ag-118](C:\Users\Phill\source\repos\RobotaPsyche\attachments\dc31476fc4a63310426e2290660e80a3ab1d6da0.png)

![](C:\Users\Phill\source\repos\RobotaPsyche\attachments\01c79355e584ce54b57969d9b6bb48247ca82c9c.png)

[Link to video](https://drive.google.com/file/d/1tZauoaTW1oDxC6otW7bPnm6xuqH-a3k3/view?usp=sharing)
