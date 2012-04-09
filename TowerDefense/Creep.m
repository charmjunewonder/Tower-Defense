//
//  Creep.m
//  TowerDefense
//
//  Created by charmjunewonder on 4/3/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Creep.h"
#import "GameHUD.h"


@implementation Creep

@synthesize hp = _hp;
@synthesize moveDuration = _moveDuration;
@synthesize lastWaypoint = _lastWaypoint;
@synthesize healthBar = _healthBar;
@synthesize totalHp = _totalHp;
@synthesize currentWaypoint = _currentWaypoint;
@synthesize path = _path;
@synthesize isGone = _isGone;
@synthesize rotateAddition = _rotateAddition;
//@synthesize scale = _scale;

- (id)copyWithZone:(NSZone *)zone {
	Creep *copy = [[[self class] allocWithZone:zone] initWithCreep:self];
	return copy;
}

- (Creep *)initWithCreep:(Creep *) copyFrom {
    if ((self = [[Creep alloc] initWithFile:@"Enemy1.png"])) {
        self.hp = copyFrom.hp;
        self.moveDuration = copyFrom.moveDuration;
        self.lastWaypoint = copyFrom.lastWaypoint;
        self.totalHp = copyFrom.totalHp;
        self.currentWaypoint = copyFrom.currentWaypoint;
	}
	[self retain];
	return self;
}

+ (id)alloc{
    Creep *creep = [super alloc];
    creep.path = [[NSMutableArray alloc] initWithCapacity:50];
    
    return creep;
}
int inum = 0;
- (WayPoint *)getNextWaypoint{
	
	DataModel *data = [DataModel getModel];
	if (inum == 6) {
        //[self stopAllActions];
        //[self unscheduleAllSelectors];
        //[self pauseSchedulerAndActions];
    }
    if (inum == 7) {
        //[self dealloc];
    }
	if (currentIndexAtPath == 0){
        gameHUD = [GameHUD sharedHUD];
        if (gameHUD.baseHpPercentage > 0) {
            [gameHUD updateBaseHp:-10];
        }
        
        Creep *target = (Creep *) self;
        [self stopAllActions];
        [self unscheduleAllSelectors];
        NSMutableArray *endtargetsToDelete = [[NSMutableArray alloc] init];
        [endtargetsToDelete addObject:target];
        for (Creep *target in endtargetsToDelete) {
            [data.targets removeObject:target];
            [self.parent removeChild:target.healthBar cleanup:YES];
            [self.parent removeChild:target cleanup:YES];
            self.healthBar = nil;
            [target stopAllActions];
            [target unscheduleAllSelectors];
            target.isGone = YES;
            [target.path release];
            [target release];
        }
        endtargetsToDelete = nil;
        target = nil;
        return nil;
    }
    inum++;
	return [self.path objectAtIndex:currentIndexAtPath-1];
}

- (WayPoint *)getLastWaypoint{
	return [self.path objectAtIndex:(currentIndexAtPath+1)];
}

- (void)findShortestPath{
    NSMutableArray *fakeQueue = [NSMutableArray arrayWithCapacity:50];
    [fakeQueue addObject:self.currentWaypoint];
    
    DataModel *data = [DataModel getModel];
    for (WayPoint *point in data.waypoints){
        point.isVisited = NO;
        point.fromNode = NULL;
    }
    
    int currentQueueObjectIndex = 0;
    int totalQueueObjectNum = 0;
    self.currentWaypoint.isVisited = YES;
    WayPoint *queueObject = nil;
    totalQueueObjectNum++;
    while (fakeQueue.count != 0) {
        queueObject = [fakeQueue objectAtIndex:0];
        //NSMutableArray *array = queueObject.adjacentNodes;
        for (WayPoint *adjacentPoint in queueObject.adjacentNodes){
            if (!adjacentPoint.isVisited) {
                [fakeQueue addObject:adjacentPoint];
                totalQueueObjectNum++;
                adjacentPoint.fromNode = queueObject;
                adjacentPoint.isVisited = YES;
            }
        }
        [fakeQueue removeObject:queueObject];
        ++currentQueueObjectIndex;
    }
    
    WayPoint *fromNode = data.endNode;
    while (fromNode) {
        [self.path addObject:fromNode];
        fromNode = fromNode.fromNode;
    }
    currentIndexAtPath = self.path.count;
}
-(void)creepLogic:(ccTime)dt {	
	
	// Rotate creep to face next waypoint
	WayPoint *waypoint = [self getNextWaypoint];
    //self.currentWaypoint = [self getNextWaypoint];
    currentIndexAtPath--;    
    
	CGPoint waypointVector = ccpSub(waypoint.position, self.position);
	CGFloat waypointAngle = ccpToAngle(waypointVector);
	CGFloat cocosAngle = self.rotateAddition + CC_RADIANS_TO_DEGREES(-1 * waypointAngle);
    
	float rotateSpeed = 0.02 / M_PI; // 1/2 second to roate 180 degrees
	float rotateDuration = fabs(waypointAngle * rotateSpeed); 
    id actionRotate = [CCRotateTo actionWithDuration:rotateDuration angle:cocosAngle];
    id actionMove = [CCMoveTo actionWithDuration:self.moveDuration position:waypoint.position];
	[self runAction:[CCSequence actions:actionRotate, actionMove, nil]];
}

- (void)scalingWhenMoving{
    id bigger = [CCScaleTo actionWithDuration:0.3 scale:0.55];
    id smaller = [CCScaleTo actionWithDuration:0.2 scale:0.5];
    [self runAction:[CCSequence actions:bigger, smaller, nil]];
}

- (void)healthBarLogic:(ccTime)dt {
    
    //Update health bar pos and percentage.
    self.healthBar.position = ccp(self.position.x, (self.position.y+20));
    self.healthBar.percentage = ((float)self.hp/(float)self.totalHp) *100;
    if (self.healthBar.percentage <= 0) {
        [self removeChild:self.healthBar cleanup:YES];
    }
}

- (void)randomlyChooseStartNode{
    DataModel *data = [DataModel getModel];
        
    self.currentWaypoint = [data.startNodes objectAtIndex:(rand() % data.startNodes.count)];
    [self findShortestPath];
}

- (void)dealloc{
    [gameHUD release];

    [self.healthBar release];
    [self.currentWaypoint release];
    [self.path release];
    [super dealloc];
}

@end

@implementation FastRedCreep

+ (id)creep {
    
    FastRedCreep *creep = nil;
    if ((creep = [[[super alloc] initWithFile:@"cockroach.png"] autorelease])) {
        BaseAttributes* baseAttributes = [BaseAttributes sharedAttributes];
        creep.hp = creep.totalHp = baseAttributes.baseRedCreepHealth;
        creep.moveDuration = baseAttributes.baseRedCreepMoveDur;
        creep.rotateAddition = 90;
        [creep randomlyChooseStartNode];
        [creep schedule:@selector(healthBarLogic:)];
        [creep schedule:@selector(creepLogic:) interval:creep.moveDuration];
    }
    return creep;
}

@end

@implementation StrongGreenCreep

+ (id)creep {
    
    StrongGreenCreep *creep = nil;
    if ((creep = [[[super alloc] initWithFile:@"image 1797.png"] autorelease])) {
        BaseAttributes* baseAttributes = [BaseAttributes sharedAttributes];
        creep.hp = creep.totalHp = baseAttributes.baseGreenCreepHealth;
        creep.moveDuration = baseAttributes.baseGreenCreepMoveDur;
        creep.rotateAddition = 90;
        creep.scale = 0.5;
        [creep randomlyChooseStartNode];
        [creep schedule:@selector(creepLogic:) interval:creep.moveDuration];
        [creep schedule:@selector(healthBarLogic:)];
        [creep schedule:@selector(scalingWhenMoving) interval:1];
    }
    return creep;
}

@end

@implementation BossBrownCreep

+ (id)creep {
    BossBrownCreep *creep = nil;
    
    if ((creep = [[[super alloc] initWithFile:@"Enemy3.png"] autorelease])) {
        BaseAttributes* baseAttributes = [BaseAttributes sharedAttributes];
        creep.hp = creep.totalHp = baseAttributes.baseBrownCreepHealth;
        creep.moveDuration = baseAttributes.baseBrownCreepMoveDur;
        [creep randomlyChooseStartNode];
        [creep schedule:@selector(creepLogic:) interval:creep.moveDuration];
        [creep schedule:@selector(healthBarLogic:)];
    } 
    
    return creep;
}
@end