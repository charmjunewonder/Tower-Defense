//
//  TutorialScene.h
//  TowerDefense
//
//  Created by charmjunewonder on 4/3/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "WayPoint.h"
#import "GameHUD.h"
#import "BaseAttributes.h"
@class  Creep;

@interface TutorialScene : CCLayer

@property (nonatomic, retain) CCTMXTiledMap *tileMap;
@property (nonatomic, retain) CCTMXLayer *background;
@property (nonatomic, retain) CCTMXLayer *buildable;
@property (nonatomic, retain) GameHUD *gameHUD;
@property (nonatomic, retain) BaseAttributes *baseAttributes;
@property (nonatomic, assign) int currentLevel;

+ (id)scene;
+ (id)getTutorialScene;
- (void)addWaypoint;
- (void)addWaves;
- (WayPoint *)findWayPointWithTilePosition:(CGPoint)position;
- (void)addTower: (CGPoint)position;
- (BOOL)canBuildOnTilePosition:(CGPoint) position;
- (CGPoint)tileCoordForPosition:(CGPoint) position;
- (void)addMagicStone:(CGPoint)position stoneTag:(int)tag;
@end
