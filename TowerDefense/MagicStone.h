//
//  MagicStone.h
//  TowerDefense
//
//  Created by charmjunewonder on 4/10/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Creep.h"

@interface MagicStone : CCSprite {
    
}
@property (nonatomic, assign) int level;
@property (nonatomic, assign) int range;
@property (nonatomic, assign) int damageMin;
@property (nonatomic, assign) int damageRandom;
@property (nonatomic, assign) float fireRate;
@property (nonatomic) int projectileTag;
@property (nonatomic, retain) Creep *target;
@property (nonatomic, retain) CCSprite *nextProjectile;

- (Creep *)getClosestTarget;
- (Creep *)getTagetThatClosestToEnd;
- (void)stoneLogic:(ccTime)dt;
- (void)creepMoveFinished:(id)sender;
- (void)finishFiring;
- (void)specialEffect;
@end

@interface PoisonousStone : MagicStone

@property (nonatomic) float poisoningDuration;
@property (nonatomic) int poisonousDamage;
+ (id)stone;

@end

@interface ManaGatheringStone : MagicStone

+ (id)stone;

@end

@interface ShockingStone : MagicStone

@property (nonatomic) float shockingDuration;

+ (id)stone;

@end