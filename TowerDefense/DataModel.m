//
//  DataModel.m
//  TowerDefense
//
//  Created by charmjunewonder on 4/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DataModel.h"

@implementation DataModel

@synthesize gameLayer = _gameLayer;
@synthesize gameHUDLayer = _gameHUDLayer;
@synthesize targets = _targets;
@synthesize waypoints = _waypoints;
@synthesize waves = _waves;
@synthesize gestureRecognizer = _gestureRecognizer;
@synthesize towers = _towers;
@synthesize projectiles = _projectiles;
@synthesize endNode = _endNode;
@synthesize startNodes = _startNodes;

static DataModel *sharedContext = nil;

+(DataModel*)getModel {
    if (!sharedContext) {
        @synchronized([DataModel class]){
            if (!sharedContext) {
                sharedContext = [[self alloc] init];
            }
            return sharedContext;
        }
    }
    return sharedContext;
}

-(void)encodeWithCoder:(NSCoder *)coder {
    
}

-(id)initWithCoder:(NSCoder *)coder {
    
	return self;
}

- (id) init
{
	if ((self = [super init])) {
		self.targets = [[NSMutableArray alloc] init];
		
		self.waypoints = [[NSMutableArray alloc] init];
		
		self.waves = [[NSMutableArray alloc] init];
        
        self.projectiles = [[NSMutableArray alloc] init];
        
        self.towers = [[NSMutableArray alloc] init];
        
        self.startNodes = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc {	
	self.gameLayer = nil;
	self.gestureRecognizer = nil;
	
	[self.targets release];
	self.targets = nil;	
	
	[self.waypoints release];
	self.waypoints = nil;
	
	[self.waves release];
	self.waves = nil;
    
    [self.projectiles release];
    self.projectiles = nil;
    
    [self.towers release];
	self.towers = nil;

    [self.startNodes release];
	self.startNodes = nil;

	[super dealloc];
}

@end
