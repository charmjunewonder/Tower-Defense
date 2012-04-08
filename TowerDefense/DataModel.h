//
//  DataModel.h
//  TowerDefense
//
//  Created by charmjunewonder on 4/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "WayPoint.h"
#import "TutorialScene.h"

@interface DataModel : NSObject<NSCoding>

// gameLayer is a pointer to the actual game layer that all the action will take place on
@property (nonatomic, retain) CCLayer *gameLayer;
@property (nonatomic, retain) CCLayer *gameHUDLayer;
@property (nonatomic, retain) NSMutableArray *projectiles;
// “targets” are our creep enemies
@property (nonatomic, retain) NSMutableArray *targets;
// “waypoints” are the navigation points that the creeps will follow
@property (nonatomic, retain) NSMutableArray *waypoints;
// “waves” will store the wave classes about the numbers of creeps and how fast they spawn, etc.
@property (nonatomic, retain) NSMutableArray *waves;
// UIPanGestureRecognizer is out ticket to smooth scrolling around the screen and the ability to have a tower defense game that is limited to 480×320.
@property (nonatomic, retain) UIPanGestureRecognizer *gestureRecognizer;

@property (nonatomic, retain) NSMutableArray *towers;
@property (nonatomic, retain) WayPoint *endNode;
@property (nonatomic, retain) NSMutableArray *startNodes;

+ (DataModel*)getModel;

@end
