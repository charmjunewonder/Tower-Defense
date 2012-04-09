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
@synthesize parentTower = _parentTower;
+ (id)projectile: (id) sender{
	
    Projectile *projectile = nil;
    if ((projectile = [[[super alloc] initWithFile:@"projectile.png"] autorelease])){
        [projectile setColor:greenColor];
        projectile.parentTower = sender;
    }
	
    return projectile;
}

@end

@implementation IceProjectile

+ (id)projectile: (id) sender{
	
    IceProjectile *projectile = nil;
    
    if ((projectile = [[[super alloc] initWithFile:@"projectile.png"] autorelease])) {
        projectile.parentTower = sender;
        [projectile setColor:orangeColor];

    }    
    
    return projectile;
    
}

- (void) dealloc
{  
    [super dealloc];
}

@end

@implementation CannonProjectile

+ (id)projectile : (id) sender{
	
    CannonProjectile *projectile = nil;
    
    if ((projectile = [[[super alloc] initWithFile:@"projectile.png"] autorelease])) {
        projectile.parentTower = sender;
        [projectile setColor:blueColor];
    }    
    
    return projectile;
    
}

- (void) dealloc
{  
    [super dealloc];
}

@end