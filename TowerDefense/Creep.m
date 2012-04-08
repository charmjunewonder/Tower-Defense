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

- (WayPoint *)getNextWaypoint{
	
	DataModel *data = [DataModel getModel];
	
	if (currentIndexAtPath == 0){
        gameHUD = [GameHUD sharedHUD];
        if (gameHUD.baseHpPercentage > 0) {
            [gameHUD updateBaseHp:-10];
        }
        
        Creep *target = (Creep *) self;
        
        NSMutableArray *endtargetsToDelete = [[NSMutableArray alloc] init];
        [endtargetsToDelete addObject:target];
        for (Creep *target in endtargetsToDelete) {
            [data.targets removeObject:target];
            [self.parent removeChild:target.healthBar cleanup:YES];
            [self.parent removeChild:target cleanup:YES];
            self.healthBar = nil;
            [target stopAllActions];
        }
        endtargetsToDelete = nil;
        return data.endNode;
    }
    
	return [self.path objectAtIndex:--currentIndexAtPath];
}

- (WayPoint *)getLastWaypoint{
	return [self.path objectAtIndex:(currentIndexAtPath+1)];
}

- (void)findShortestPath{
    NSMutableArray *fakeQueue = [NSMutableArray arrayWithCapacity:50];
    [fakeQueue addObject:self.currentWaypoint];
    printf("Point : (%.0lf, %.0lf)\n", self.currentWaypoint.position.x, self.currentWaypoint.position.y);
    
    DataModel *data = [DataModel getModel];
    for (WayPoint *point in data.waypoints){
        point.isVisited = NO;
        point.fromNode = nil;
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
	WayPoint *waypoint = self.currentWaypoint;
	
	CGPoint waypointVector = ccpSub(waypoint.position, self.position);
	CGFloat waypointAngle = ccpToAngle(waypointVector);
	CGFloat cocosAngle = CC_RADIANS_TO_DEGREES(-1 * waypointAngle);
	
	float rotateSpeed = 0.02 / M_PI; // 1/2 second to roate 180 degrees
	float rotateDuration = fabs(waypointAngle * rotateSpeed);    
	
	[self runAction:[CCSequence actions:
					 [CCRotateTo actionWithDuration:rotateDuration angle:cocosAngle],
					 nil]];		
}

-(void)healthBarLogic:(ccTime)dt {
    
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
    gameHUD = nil;
    self.healthBar = nil;
    self.currentWaypoint = nil;
    [super dealloc];
}

@end

@implementation FastRedCreep

+ (id)creep {
    
    FastRedCreep *creep = nil;
    if ((creep = [[[super alloc] initWithFile:@"Enemy1.png"] autorelease])) {
        BaseAttributes* baseAttributes = [BaseAttributes sharedAttributes];
        creep.hp = creep.totalHp = baseAttributes.baseRedCreepHealth;
        creep.moveDuration = baseAttributes.baseRedCreepMoveDur;
        [creep randomlyChooseStartNode];
        [creep schedule:@selector(creepLogic:) interval:0.2];
        [creep schedule:@selector(healthBarLogic:)];
    }
    return creep;
}

@end

@implementation StrongGreenCreep

+ (id)creep {
    
    StrongGreenCreep *creep = nil;
    if ((creep = [[[super alloc] initWithFile:@"Enemy2.png"] autorelease])) {
        BaseAttributes* baseAttributes = [BaseAttributes sharedAttributes];
        creep.hp = creep.totalHp = baseAttributes.baseGreenCreepHealth;
        creep.moveDuration = baseAttributes.baseGreenCreepMoveDur;
        [creep randomlyChooseStartNode];
        [creep schedule:@selector(creepLogic:) interval:0.2];
        [creep schedule:@selector(healthBarLogic:)];
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
        [creep schedule:@selector(creepLogic:) interval:0.2];
        [creep schedule:@selector(healthBarLogic:)];
    } 
    
    return creep;
}
@end