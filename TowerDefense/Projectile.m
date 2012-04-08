//
//  Projectile.m
//  TowerDefense
//
//  Created by charmjunewonder on 4/4/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Projectile.h"


@implementation Projectile
@synthesize parentTower = _parentTower;
+ (id)projectile: (id) sender{
	
    Projectile *projectile = nil;
    if ((projectile = [[[super alloc] initWithFile:@"Projectile.png"] autorelease])){
        projectile.parentTower = sender;
    }
	
    return projectile;
}

@end

@implementation IceProjectile

+ (id)projectile: (id) sender{
	
    IceProjectile *projectile = nil;
    
    if ((projectile = [[[super alloc] initWithFile:@"IceProjectile.png"] autorelease])) {
        projectile.parentTower = sender;
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
    
    if ((projectile = [[[super alloc] initWithFile:@"CannonProjectile.png"] autorelease])) {
        projectile.parentTower = sender;
    }    
    
    return projectile;
    
}

- (void) dealloc
{  
    [super dealloc];
}

@end