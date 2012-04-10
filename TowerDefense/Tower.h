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

@interface MagicBuilding : CCSprite {
}
@property (nonatomic) CGPoint tileLocation;
@property (nonatomic) BOOL isOccupied;
@end

@interface Tower : MagicBuilding 
+ (id)tower;
@end

@interface Trap : MagicBuilding
@end

@interface Amplifier : MagicBuilding 
@end