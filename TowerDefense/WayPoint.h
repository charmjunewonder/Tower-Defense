//
//  WayPoint.h
//  TowerDefense
//
//  Created by charmjunewonder on 4/3/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#import "cocos2d.h"

@interface WayPoint : CCNode {
    
}

@property (nonatomic, retain) NSMutableArray *adjacentNodes;
@property (nonatomic, retain) WayPoint *fromNode;
@property (nonatomic, assign) BOOL isVisited;
@property (nonatomic) BOOL isOccupied;
@property (nonatomic) CGPoint tileLocation;

@end
