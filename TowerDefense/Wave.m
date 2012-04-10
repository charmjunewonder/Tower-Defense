//
//  Wave.m
//  TowerDefense
//
//  Created by charmjunewonder on 4/4/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Wave.h"


@implementation Wave
@synthesize spawnRate = _spawnRate;
@synthesize redCreeps = _redCreeps;
@synthesize greenCreeps = _greenCreeps;
@synthesize brownCreeps = _brownCreeps;

-(id) init
{
	if( (self=[super init]) ) {
		
	}
	
	return self;
}

- (id) initWithSpawnRate:(float)spawnrate RedCreeps:(int)redcreeps GreenCreeps: (int)greencreeps BrownCreeps: (int)browncreeps
{
	//NSAssert(creep!=nil, @"Invalid creep for wave.");
    
	if( (self = [self init]) )
	{
		_spawnRate = spawnrate;
		_redCreeps = redcreeps;
        _greenCreeps = greencreeps;
        _brownCreeps = browncreeps;
        
	}
	return self;
}

- (void)dealloc{
    //[self.creepType release];
    [super dealloc];
}

@end
