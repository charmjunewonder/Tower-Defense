//
//  BaseAttributes.m
//  TowerDefense
//
//  Created by charmjunewonder on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BaseAttributes.h"

@implementation BaseAttributes
@synthesize baseHealth = _baseHealth;
@synthesize baseStartingMoney = _baseStartingMoney;
@synthesize baseMoneyRegen = _baseMoneyRegen;
@synthesize baseMoneyRegenRate = _baseMoneyRegenRate;
@synthesize baseMoneyDropped = _baseMoneyDropped;
@synthesize baseTowerCostPercentage = _baseTowerCostPercentage;

@synthesize baseMGCost = _baseMGCost;
@synthesize baseMGDamage = _baseMGDamage;
@synthesize baseMGDamageRandom = _baseMGDamageRandom;
@synthesize baseMGFireRate = _baseMGFireRate;
@synthesize baseMGRange = _baseMGRange;
@synthesize baseMGlvlup1 = _baseMGlvlup1;
@synthesize baseMGlvlup2 = _baseMGlvlup2;

@synthesize baseFCost = _baseFCost;
@synthesize baseFDamage = _baseFDamage;
@synthesize baseFDamageRandom = _baseFDamageRandom;
@synthesize baseFFireRate = _baseFFireRate;
@synthesize baseFFreezeDur = _baseFFreezeDur;
@synthesize baseFRange = _baseFRange;
@synthesize baseFlvlup1 = _baseFlvlup1;
@synthesize baseFlvlup2 = _baseFlvlup2;

@synthesize baseCCost = _baseCCost;
@synthesize baseCDamage = _baseCDamage;
@synthesize baseCDamageRandom = _baseCDamageRandom;
@synthesize baseCFireRate = _baseCFireRate;
@synthesize baseCSplashDist = _baseCSplashDist;
@synthesize baseCRange = _baseCRange;
@synthesize baseClvlup1 = _baseClvlup1;
@synthesize baseClvlup2 = _baseClvlup2;

@synthesize baseRedCreepHealth = _baseRedCreepHealth;
@synthesize baseRedCreepMoveDur = _baseRedCreepMoveDur;
@synthesize baseGreenCreepHealth = _baseGreenCreepHealth;
@synthesize baseGreenCreepMoveDur = _baseGreenCreepMoveDur;
@synthesize baseBrownCreepHealth = _baseBrownCreepHealth;
@synthesize baseBrownCreepMoveDur = _baseBrownCreepMoveDur;

static BaseAttributes *_sharedAttributes = nil;

+ (BaseAttributes *)sharedAttributes
{
	if (!_sharedAttributes) {
        @synchronized([BaseAttributes class])
        {
            if (!_sharedAttributes)
                [[self alloc] init];
            return _sharedAttributes;
        }

    }
	return _sharedAttributes;
}

+(id)alloc
{
	@synchronized([BaseAttributes class])
	{
		NSAssert(_sharedAttributes == nil, @"Attempted to allocate a second instance of a singleton.");
		_sharedAttributes = [super alloc];
		return _sharedAttributes;
	}
	// to avoid compiler warning
	return nil;
}


-(id) init
{
    if ((self=[super init]) ) {
       _baseHealth = 100;
        
       _baseStartingMoney = 200;
       _baseMoneyRegen = 5;// Affects how much money is regenerated naturally (per 5 seconds)
       _baseMoneyRegenRate = 5.0;
       _baseMoneyDropped = 8;//Affects how much money is dropped by a creep (maximum +1)
       _baseTowerCostPercentage = 1; //Makes all towers cheaper/more expensive 1 = same, 0.5 = half etc.
       
       _baseMGCost = 50;
       _baseMGDamage = 2;//Damage (minimum)
       _baseMGDamageRandom = 5;//Random amount for extra hit points
       _baseMGFireRate = 0.25;
       _baseMGRange = 200;
       _baseMGlvlup1 = 300;
       _baseMGlvlup2 = 450;
       
       _baseFCost = 70;
       _baseFDamage = 0;//Damage (minimum)
       _baseFDamageRandom = 5;//Random amount for extra hit points
       _baseFFireRate = 6.0;
       _baseFFreezeDur = 1.5;
       _baseFRange = 150;
       _baseFlvlup1 = 50;
       _baseFlvlup2 = 75;
       
       _baseCCost = 120;
       _baseCDamage = 20;//Damage (minimum)
       _baseCDamageRandom = 20;//Random amount for extra hit points
       _baseCFireRate = 10.0;
       _baseCSplashDist = 75;
       _baseCRange = 100;
       _baseClvlup1 = 500;
       _baseClvlup2 = 750;
        
       _baseRedCreepHealth = 100;
       _baseRedCreepMoveDur = 0.9;
       _baseGreenCreepHealth = 150;
       _baseGreenCreepMoveDur = 2;
       _baseBrownCreepHealth = 500;
       _baseBrownCreepMoveDur = 10;
        
    }
    
    return self;
}
@end
