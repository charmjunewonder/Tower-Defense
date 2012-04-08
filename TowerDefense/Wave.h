//
//  Wave.h
//  TowerDefense
//
//  Created by charmjunewonder on 4/4/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Creep.h"

@class Creep;

@interface Wave : CCNode {
    
}

@property (nonatomic) float spawnRate;
@property (nonatomic) int redCreeps;
@property (nonatomic) int greenCreeps;
@property (nonatomic) int brownCreeps;
@property (nonatomic, copy)Creep *creepType;

- (id)initWithCreep:(Creep *)creep SpawnRate:(float)spawnrate RedCreeps:(int)redcreeps GreenCreeps: (int)greencreeps BrownCreeps: (int)browncreeps;

@end
