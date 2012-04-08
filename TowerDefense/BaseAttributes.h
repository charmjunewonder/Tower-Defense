//
//  BaseAttributes.h
//  TowerDefense
//
//  Created by charmjunewonder on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseAttributes : NSObject

//GUI & Money attributes
@property (nonatomic, assign) int baseHealth;
@property (nonatomic, assign) int baseStartingMoney;
@property (nonatomic, assign)int baseMoneyRegen;
@property (nonatomic, assign)float baseMoneyRegenRate;
@property (nonatomic, assign)int baseMoneyDropped;
@property (nonatomic, assign)float baseTowerCostPercentage;

//MG tower attributes
@property (nonatomic, assign)int baseMGCost;
@property (nonatomic, assign)int baseMGDamage;
@property (nonatomic, assign)int baseMGDamageRandom;
@property (nonatomic, assign)float baseMGFireRate;
@property (nonatomic, assign)int baseMGRange;
@property (nonatomic, assign)int baseMGlvlup1;
@property (nonatomic, assign)int baseMGlvlup2;

//Freeze tower attributes
@property (nonatomic, assign)int baseFCost;
@property (nonatomic, assign)int baseFDamage;
@property (nonatomic, assign)int baseFDamageRandom;
@property (nonatomic, assign)float baseFFireRate;
@property (nonatomic, assign)float baseFFreezeDur;
@property (nonatomic, assign)int baseFRange;
@property (nonatomic, assign)int baseFlvlup1;
@property (nonatomic, assign)int baseFlvlup2;

//Cannon tower attributes
@property (nonatomic, assign)int baseCCost;
@property (nonatomic, assign)int baseCDamage;
@property (nonatomic, assign)int baseCDamageRandom;
@property (nonatomic, assign)float baseCFireRate;
@property (nonatomic, assign)float baseCSplashDist;
@property (nonatomic, assign)int baseCRange;
@property (nonatomic, assign)int baseClvlup1;
@property (nonatomic, assign)int baseClvlup2;

//Creep attributes
@property (nonatomic, assign)int baseRedCreepHealth;
@property (nonatomic, assign)float baseRedCreepMoveDur;
@property (nonatomic, assign)int baseGreenCreepHealth;
@property (nonatomic, assign)float baseGreenCreepMoveDur;
@property (nonatomic, assign)int baseBrownCreepHealth;
@property (nonatomic, assign)float baseBrownCreepMoveDur;


+ (BaseAttributes *)sharedAttributes;

@end
