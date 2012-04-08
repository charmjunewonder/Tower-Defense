//
//  Tower.h
//  TowerDefense
//
//  Created by charmjunewonder on 4/4/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Creep.h"

@interface Tower : CCSprite 

@property (nonatomic, assign) int experience;
@property (nonatomic, assign) int level;

@property (nonatomic, assign) int levelup1;
@property (nonatomic, assign) int levelup2;
@property (nonatomic, assign) int levelupCost;
@property (nonatomic, assign) bool levelupReady;

@property (nonatomic, assign) int range;
@property (nonatomic, assign) int damageMin;
@property (nonatomic, assign) int damageRandom;
@property (nonatomic, assign) float fireRate;
@property (nonatomic, assign) float freezeDur;
@property (nonatomic, assign) float splashDist;

@property (nonatomic, retain) Creep * target;
@property (nonatomic, retain) CCSprite *nextProjectile;

- (Creep *)getClosestTarget;

@end

@interface MachineGunTower : Tower

+ (id)tower;
- (void)towerLogic:(ccTime)defenseTime;
- (void)creepMoveFinished:(id)sender;
- (void)finishFiring;

@end

@interface FreezeTower : Tower {
    
}

+ (id)tower;

- (void)setClosestTarget:(Creep *)closestTarget;
- (void)towerLogic:(ccTime)dt;
- (void)creepMoveFinished:(id)sender;
- (void)finishFiring;

@end

@interface CannonTower : Tower {
    
}

+ (id)tower;

- (void)setClosestTarget:(Creep *)closestTarget;
- (void)towerLogic:(ccTime)dt;
- (void)creepMoveFinished:(id)sender;
- (void)finishFiring;

@end