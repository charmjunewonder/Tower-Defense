//
//  Creep.h
//  TowerDefense
//
//  Created by charmjunewonder on 4/3/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "WayPoint.h"
#import "DataModel.h"
#import "GameHUD.h"

@interface Creep : CCSprite<NSCopying>{
    GameHUD* gameHUD;
    float firstDistance;
    int currentIndexAtPath;
}

@property (nonatomic, assign) int hp;
@property (nonatomic, assign) float moveDuration;
@property (nonatomic, retain) WayPoint *currentWaypoint;
@property (nonatomic, assign) int lastWaypoint;
@property (nonatomic, retain) CCProgressTimer *healthBar;
@property (nonatomic, assign) int totalHp;
@property (nonatomic, retain) NSMutableArray *path; // in reverse order!!!
@property (nonatomic)BOOL isGone;


- (Creep *) initWithCreep:(Creep *) copyFrom; 
- (WayPoint *)getNextWaypoint;
- (WayPoint *)getLastWaypoint;
- (void)randomlyChooseStartNode;
- (void)creepLogic:(ccTime)dt;
@end

@interface FastRedCreep : Creep {
}
+(id)creep;
@end

@interface StrongGreenCreep : Creep {
}
+(id)creep;
@end

@interface BossBrownCreep : Creep {
}
+(id)creep;
@end