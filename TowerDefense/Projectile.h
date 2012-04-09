//
//  Projectile.h
//  TowerDefense
//
//  Created by charmjunewonder on 4/4/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Projectile : CCSprite {
    
}
@property (nonatomic, assign) CCSprite *parentTower;

+ (id)projectile: (id) sender;

@end