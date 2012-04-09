//
//  Tower.m
//  TowerDefense
//
//  Created by charmjunewonder on 4/4/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Tower.h"
#import "Projectile.h"

#define greenColor ccc3(191, 224, 93)
#define orangeColor ccc3(251, 178, 78)
#define blueColor ccc3(73, 172, 249)
#define redColor ccc3(255, 96, 84)
#define yellowColor ccc3(244, 223, 91)
#define purpleColor ccc3(73, 172, 249)


@implementation Tower
@synthesize experience = experience;
@synthesize level = _level;

@synthesize levelup1 = _levelup1;
@synthesize levelup2 = _levelup2;
@synthesize levelupCost = _lvlupCost;
@synthesize levelupReady = _levelupReady;

@synthesize range = range;
@synthesize damageMin = damageMin;
@synthesize damageRandom = damageRandom;
@synthesize fireRate = fireRate;
@synthesize freezeDur = freezeDur;
@synthesize splashDist = splashDist;

@synthesize target = _target;
@synthesize nextProjectile = _nextProjectile;

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
        double targetDistanceToTower = ccpDistance(self.position, creep.position);

		if (curDistance < maxDistant && targetDistanceToTower < self.range) {
			closestCreep = creep;
			maxDistant = curDistance;
		}
		
	}
	
    return closestCreep;
}

@end

@implementation MachineGunTower

+ (id)tower{
    MachineGunTower *tower = nil;
    if ((tower = [[[super alloc] initWithFile:@"gem 1.png"]autorelease])) {
        BaseAttributes *baseAttributes = [BaseAttributes sharedAttributes];
        
        tower.damageMin = baseAttributes.baseMGDamage;
        tower.damageRandom = baseAttributes.baseMGDamageRandom;
        tower.range = baseAttributes.baseMGRange;
        [tower schedule:@selector(towerLogic:) interval:baseAttributes.baseMGFireRate];
        
		tower.experience = 0;
        tower.level = 1;
        tower.levelup1 = baseAttributes.baseMGlvlup1;
        tower.levelup2 = baseAttributes.baseMGlvlup2;
        tower.levelupCost = baseAttributes.baseMGCost /2;
        tower.levelupReady = NO;
        tower.freezeDur = 0;
        tower.splashDist = 0;
        
		tower.target = nil;
        [tower schedule:@selector(towerLogic:) interval:1];
        //[tower schedule:@selector(checkTarget) interval:0.5];
        [tower schedule:@selector(checkExperience) interval:0.5];
    }
    return tower;
}

-(void)checkExperience {
    switch (self.level) {
        case 1:
            if (self.experience >= self.levelup1 && self.levelupReady == NO) {
                //Ready lvl up
                printf("Ready upgrade");
                
                [self setTexture:[[CCTextureCache sharedTextureCache] addImage:@"MGTowerUpgrade.png"]];
                
                self.levelupReady = TRUE;
            }
            break;
        case 2:
            if (self.experience >= self.levelup2) {
                //Ready lvl up 2
                self.levelupReady = TRUE;
            }
        default:
            break;
    }
}


-(id) init
{
	if ((self=[super init]) ) {
		//[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
	}
	return self;
}

-(void)towerLogic:(ccTime)defenseTime {
    if (self.target == nil) {
        self.target = [self getClosestTarget];
    }
	
	if (self.target != nil) {
        		
		[self runAction:[CCSequence actions:
                         [CCCallFunc actionWithTarget:self selector:@selector(finishFiring)],
                         nil]];		
	}
} 

-(void)creepMoveFinished:(id)sender {
    
	DataModel *data = [DataModel getModel];
	
	CCSprite *sprite = (CCSprite *)sender;
	[self.parent removeChild:sprite cleanup:YES];
	
	[data.projectiles removeObject:sprite];
}

/*
    finishFiring only gets called after we know our tower is pointing in 
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
        self.target.projectileTag = 1;
        self.target.color = ccGREEN;
        [self.target beingPoisonedForSeconds:4 damageRandom:self.damageRandom damageMin:self.damageMin];
        
        self.nextProjectile = nil;
        data = nil;
    }
}

@end

@implementation FreezeTower

+ (id)tower {
	
    FreezeTower *tower = nil;
    if ((tower = [[[super alloc] initWithFile:@"gem 2.png"] autorelease])) {
        BaseAttributes *baseAttributes = [BaseAttributes sharedAttributes];
        
        tower.damageMin = baseAttributes.baseFDamage;
        tower.damageRandom = baseAttributes.baseFDamageRandom;
        tower.range = baseAttributes.baseFRange;
        [tower schedule:@selector(towerLogic:) interval:baseAttributes.baseFFireRate];
        tower.freezeDur = baseAttributes.baseFFreezeDur;
        tower.splashDist = 0;
        
		tower.experience = 0;
        tower.level = 1;
        tower.levelup1 = baseAttributes.baseFlvlup1;
        tower.levelup2 = baseAttributes.baseFlvlup2;
        tower.levelupCost = baseAttributes.baseFCost /2;
        tower.levelupReady = NO;
        
        
		tower.target = nil;
		[tower schedule:@selector(towerLogic:) interval:1];
        [tower schedule:@selector(checkExperience) interval:0.5];

    }
	
    return tower;
    
}

-(id) init
{
	if ((self=[super init]) ) {
		//[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
	}
	return self;
}


-(void)setClosestTarget:(Creep *)closestTarget {
	self.target = closestTarget;
}

-(void)checkExperience {
    switch (self.level) {
        case 1:
            if (self.experience >= self.levelup1 && self.levelupReady == NO) {
                //Ready lvl up
                printf("Ready upgrade");
                
                [self setTexture:[[CCTextureCache sharedTextureCache] addImage:@"FreezeTurretUpgrade.png"]];
                
                self.levelupReady = TRUE;
            }
            break;
        case 2:
            if (self.experience >= self.levelup2) {
                //Ready lvl up 2
                self.levelupReady = TRUE;
            }
        default:
            break;
    }
}

-(void)towerLogic:(ccTime)dt {
	
	self.target = [self getClosestTarget];
	
	if (self.target != nil) {
		
		[self runAction:[CCSequence actions:
						 [CCCallFunc actionWithTarget:self selector:@selector(finishFiring)],
						 nil]];		
	}
}

-(void)creepMoveFinished:(id)sender {
    
	DataModel *data = [DataModel getModel];
	
	CCSprite *sprite = (CCSprite *)sender;
	[self.parent removeChild:sprite cleanup:YES];
	
	[data.projectiles removeObject:sprite];
	
}

- (void)finishFiring {
    self.target = [self getTagetThatClosestToEnd];
    if (self.target) {
       	DataModel *data = [DataModel getModel];
        
        self.nextProjectile = [Projectile projectile:self];
        self.nextProjectile.position = self.position;
        [self.nextProjectile setColor:orangeColor];

        [self.parent addChild:self.nextProjectile z:1];
        [data.projectiles addObject:self.nextProjectile];
        
        [self.nextProjectile runAction:[CCSequence actions:
                                        [CCMoveTo actionWithDuration:0.1 position:self.target.position],
                                        [CCCallFuncN actionWithTarget:self selector:@selector(creepMoveFinished:)],
                                        nil]];
        self.target.hp -= (rand()% self.damageRandom)+self.damageMin;
        self.target.projectileTag = 2;	
        
        self.nextProjectile = nil; 
    }
    
}

@end

@implementation CannonTower

+ (id)tower {
	
    CannonTower *tower = nil;
    if ((tower = [[[super alloc] initWithFile:@"gem 3.jpg"] autorelease])) {
        BaseAttributes *baseAttributes = [BaseAttributes sharedAttributes];
        
        tower.damageMin = baseAttributes.baseCDamage;
        tower.damageRandom = baseAttributes.baseCDamageRandom;
        tower.range = baseAttributes.baseMGRange;
        [tower schedule:@selector(towerLogic:) interval:baseAttributes.baseCFireRate];
        tower.freezeDur = 0;
        tower.splashDist = baseAttributes.baseCSplashDist;
        
		tower.experience = 0;
        tower.level = 1;
        tower.levelup1 = baseAttributes.baseClvlup1;
        tower.levelup2 = baseAttributes.baseClvlup2;
        tower.levelupCost = baseAttributes.baseCCost /2;
        tower.levelupReady = NO;
        
		tower.target = nil;
        
        [tower schedule:@selector(checkExperience) interval:0.5];
		
		tower.target = nil;
		[tower schedule:@selector(towerLogic:) interval:2];
		
    }
	
    return tower;
    
}

-(id) init
{
	if ((self=[super init]) ) {
		//[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
	}
	return self;
}


-(void)setClosestTarget:(Creep *)closestTarget {
	self.target = closestTarget;
}

-(void)checkExperience {
    switch (self.level) {
        case 1:
            if (self.experience >= self.levelup1 && self.levelupReady == NO) {
                //Ready lvl up
                printf("Ready upgrade");
                
                [self setTexture:[[CCTextureCache sharedTextureCache] addImage:@"CannonTurretUpgrade.png"]];
                
                self.levelupReady = TRUE;
            }
            break;
        case 2:
            if (self.experience >= self.levelup2) {
                //Ready level up 2
                self.levelupReady = TRUE;
            }
        default:
            break;
    }
}

-(void)towerLogic:(ccTime)dt {
	
	self.target = [self getClosestTarget];
	
	if (self.target != nil) {
		
		[self runAction:[CCSequence actions:
						 [CCCallFunc actionWithTarget:self selector:@selector(finishFiring)],
						 nil]];		
	}
}

-(void)creepMoveFinished:(id)sender {
    
	DataModel *data = [DataModel getModel];
	
	CCSprite *sprite = (CCSprite *)sender;
	[self.parent removeChild:sprite cleanup:YES];
	
	[data.projectiles removeObject:sprite];
	
}

- (void)finishFiring {
    self.target = [self getTagetThatClosestToEnd];
    if (self.target) {
        
        DataModel *data = [DataModel getModel];
        self.nextProjectile = [Projectile projectile: self];
        self.nextProjectile.position = self.position;
        [self.nextProjectile setColor:blueColor];
        
        [self.parent addChild:self.nextProjectile z:1];
        [data.projectiles addObject:self.nextProjectile];
        
        [self.nextProjectile runAction:[CCSequence actions:
                                        [CCMoveTo actionWithDuration:0.1 position:self.target.position],
                                        [CCCallFuncN actionWithTarget:self selector:@selector(creepMoveFinished:)],
                                        nil]];
        self.target.hp -= (rand()% self.damageRandom)+self.damageMin;
        self.target.projectileTag = 3;		
        self.target.color = blueColor;
        [self.target beingFreezedForSeconds:1];
        
        self.nextProjectile = nil;
    }
    else{
        self.target = nil; 
    }
    
}

- (void)dealloc{
    [self.target dealloc];
    [self.nextProjectile dealloc];
    [super dealloc];
}

@end
