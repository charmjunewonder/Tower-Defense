//
//  WayPoint.m
//  TowerDefense
//
//  Created by charmjunewonder on 4/3/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "WayPoint.h"

@implementation WayPoint

@synthesize adjacentNodes = _adjacentNodes;
@synthesize fromNode = _fromNode;
@synthesize isVisited = _isVisited;

- (id) init
{
	if ((self = [super init])) {
		self.adjacentNodes = [[NSMutableArray alloc] initWithCapacity:4];
	}
	return self;
}

@end