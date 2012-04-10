//
//  MagicStone.m
//  TowerDefense
//
//  Created by charmjunewonder on 4/10/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MagicStone.h"
#import "Projectile.h"

#define greenColor ccc3(191, 224, 93)
#define orangeColor ccc3(251, 178, 78)
#define blueColor ccc3(73, 172, 249)
#define redColor ccc3(255, 96, 84)
#define yellowColor ccc3(244, 223, 91)
#define purpleColor ccc3(73, 172, 249)

@implementation MagicStone

@synthesize level = _level;
@synthesize range = _range;
@synthesize damageMin = _damageMin;
@synthesize damageRandom = _damageRandom;
@synthesize target = _target;
@synthesize nextProjectile = _nextProjectile;
@synthesize fireRate = _fireRate;
@synthesize projectileTag = _projectileTag;

/*
 search through all available creeps on the map and see which one is close 
 by comparing their distances. For each creep we look through we check to 
 see if it's distance is less than the one we have stored before. By default 
 we pick a distance of 99999 which is way larger than any distance to any 
 creep once they start coming out.
 */
- (Creep *)getClosestTarget{
    Creep *closestCreep = nil;
	double maxDistant = 99999;
	
	DataModel *data = [DataModel getModel];
	
	for (CCSprite *target in data.targets) {	
		Creep *creep = (Creep *)target;
		double curDistance = ccpDistance(self.position, creep.position);
		
		if (curDistance < maxDistant && curDistance < self.range) {
			closestCreep = creep;
			maxDistant = curDistance;
		}
		
	}
	
    return closestCreep;
}

- (Creep *)getTagetThatClosestToEnd{
    
    Creep *closestCreep = nil;
	double maxDistant = 99999;
	
	DataModel *data = [DataModel getModel];
	if (data.targets.count == 0) {
        return nil;
    }
    
	for (CCSprite *target in data.targets) {	
		Creep *creep = (Creep *)target;
		double curDistance = creep.path.count;
        double targetDistanceToStone = ccpDistance(self.position, creep.position);
        
		if (curDistance < maxDistant && targetDistanceToStone < self.range) {
			closestCreep = creep;
			maxDistant = curDistance;
		}
		
	}
	
    return closestCreep;
}

-(void)stoneLogic:(ccTime)defenseTime {
    [self runAction:[CCSequence actions:
                         [CCCallFunc actionWithTarget:self selector:@selector(finishFiring)],
                         nil]];		
}

-(void)creepMoveFinished:(id)sender {
    
	DataModel *data = [DataModel getModel];
	
	CCSprite *sprite = (CCSprite *)sender;
	[self.parent removeChild:sprite cleanup:YES];
	
	[data.projectiles removeObject:sprite];
}

/*
 finishFiring only gets called after we know our stone is pointing in 
 the right direction. It's purpose is to create a new projectile and add 
 it to the DataModel projectile array (for reference later), and then give 
 it a position and a final destination.
 */
- (void)finishFiring {
    self.target = [self getTagetThatClosestToEnd];
    if (self.target) {
        DataModel *data = [DataModel getModel];
        
        self.nextProjectile = [Projectile projectile:self];
        self.nextProjectile.position = self.position;
        [self.nextProjectile setColor:greenColor];
        
        [self.parent addChild:self.nextProjectile z:1];
        [data.projectiles addObject:self.nextProjectile];
        
        [self.nextProjectile runAction:[CCSequence actions:
                                        [CCMoveTo actionWithDuration:0.1 position:self.target.position],
                                        [CCCallFuncN actionWithTarget:self selector:@selector(creepMoveFinished:)],
                                        nil]];
        self.target.hp -= (rand()% self.damageRandom)+self.damageMin;
        self.nextProjectile.tag = self.projectileTag;
        
        [self specialEffect];
        
        self.nextProjectile = nil;
        data = nil;
    }
}

- (void)specialEffect{}

@end

@implementation PoisonousStone

@synthesize poisoningDuration = _poisoningDuration;
@synthesize poisonousDamage = _poisonousDamage;
+ (id)stone{
    PoisonousStone *stone = nil;
    if ((stone = [[[super alloc] initWithFile:@"gem 1.png"]autorelease])) {
        BaseAttributes *baseAttributes = [BaseAttributes sharedAttributes];
        
        stone.damageMin = baseAttributes.baseMGDamage;
        stone.damageRandom = baseAttributes.baseMGDamageRandom;
        stone.range = baseAttributes.baseMGRange;
        stone.projectileTag = 1;
        stone.poisonousDamage = 8;
        
        [stone schedule:@selector(stoneLogic:) interval:baseAttributes.baseMGFireRate];
        
        stone.level = 1;
        stone.poisoningDuration = 5;
        
		stone.target = nil;
        [stone schedule:@selector(stoneLogic:) interval:1];
        //[stone schedule:@selector(checkTarget) interval:0.5];
        [stone schedule:@selector(checkExperience) interval:0.5];
    }
    return stone;

}

- (void)specialEffect{
    self.target.color = ccGREEN;
    [self.target beingPoisonedForSeconds:self.poisoningDuration poinsonousDamage:self.poisonousDamage];
}

@end

@implementation ManaGatheringStone

+ (id)stone{
    ManaGatheringStone *stone = nil;
    if ((stone = [[[super alloc] initWithFile:@"gem 2.png"] autorelease])) {
        BaseAttributes *baseAttributes = [BaseAttributes sharedAttributes];
        
        stone.damageMin = baseAttributes.baseFDamage;
        stone.damageRandom = baseAttributes.baseFDamageRandom;
        stone.range = baseAttributes.baseFRange;
        stone.projectileTag = 2;
        [stone schedule:@selector(stoneLogic:) interval:baseAttributes.baseFFireRate];

        stone.level = 1;
        
		stone.target = nil;
		[stone schedule:@selector(stoneLogic:) interval:1];
        [stone schedule:@selector(checkExperience) interval:0.5];
    }
	
    return stone;

}

- (void)specialEffect{

}

@end

@implementation ShockingStone

@synthesize shockingDuration = _shockingDuration;

+ (id)stone{
    ShockingStone *stone = nil;
    if ((stone = [[[super alloc] initWithFile:@"gem 3.jpg"] autorelease])) {
        BaseAttributes *baseAttributes = [BaseAttributes sharedAttributes];
        
        stone.damageMin = baseAttributes.baseCDamage;
        stone.damageRandom = baseAttributes.baseCDamageRandom;
        stone.range = baseAttributes.baseMGRange;
        stone.projectileTag = 3;
        [stone schedule:@selector(stoneLogic:) interval:baseAttributes.baseCFireRate];
        stone.shockingDuration = 0;
        
        stone.level = 1;
		stone.target = nil;
        
        [stone schedule:@selector(checkExperience) interval:0.5];
		
		stone.target = nil;
		[stone schedule:@selector(stoneLogic:) interval:2];
		
    }
	
    return stone;

}

- (void)specialEffect{
    self.target.color = blueColor;
    [self.target beingShockingForSeconds:1];
}

@end
