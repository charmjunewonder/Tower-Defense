//
//  TutorialScene.h
//  TowerDefense
//
//  Created by charmjunewonder on 4/3/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Creep.h"
#import "WayPoint.h"
#import "Wave.h"
#import "GameHUD.h"
#import "BaseAttributes.h"

@interface TutorialScene : CCLayer

@property (nonatomic, retain) CCTMXTiledMap *tileMap;
@property (nonatomic, retain) CCTMXLayer *background;
@property (nonatomic, retain) GameHUD *gameHUD;
@property (nonatomic, retain) BaseAttributes *baseAttributes;
@property (nonatomic, assign) int currentLevel;

+ (id)scene;
+ (id)getTutorialScene;
- (void)addWaypoint;
- (void)addWaves;
- (void)addTower: (CGPoint)position tag: (int)towerTag;
- (BOOL)canBuildOnTilePosition:(CGPoint) position;

@end
