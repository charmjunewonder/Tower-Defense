//
//  Tower.m
//  TowerDefense
//
//  Created by charmjunewonder on 4/4/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Tower.h"
#import "Projectile.h"

@implementation MagicBuilding
@synthesize tileLocation = _tileLocation;
@synthesize isOccupied = _isOccupied;
@end

@implementation Tower

+ (id)tower{
    Tower *tower = nil;
    if ((tower = [[[super alloc] initWithFile:@"tower.png"] autorelease])) {
    }
	
    return tower;
}
@end

@implementation Trap
@end

@implementation Amplifier
@end
