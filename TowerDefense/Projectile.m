//
//  Projectile.m
//  TowerDefense
//
//  Created by charmjunewonder on 4/4/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Projectile.h"

#define greenColor ccc3(191, 224, 93)
#define orangeColor ccc3(251, 178, 78)
#define blueColor ccc3(73, 172, 249)
#define redColor ccc3(255, 96, 84)
#define yellowColor ccc3(244, 223, 91)
#define purpleColor ccc3(73, 172, 249)


@implementation Projectile
@synthesize parentStone = _parentStone;
+ (id)projectile: (id) sender{
	
    Projectile *projectile = nil;
    if ((projectile = [[[super alloc] initWithFile:@"projectile.png"] autorelease])){
        [projectile setColor:greenColor];
        projectile.parentStone = sender;
    }
	
    return projectile;
}

@end