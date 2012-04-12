//
//  Creep.m
//  TowerDefense
//
//  Created by charmjunewonder on 4/3/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Creep.h"
#import "GameHUD.h"

#define greenColor ccc3(191, 224, 93)
#define orangeColor ccc3(251, 178, 78)
#define blueColor ccc3(73, 172, 249)
#define redColor ccc3(255, 96, 84)
#define yellowColor ccc3(244, 223, 91)
#define purpleColor ccc3(73, 172, 249)

@implementation Creep

@synthesize hp = _hp;
@synthesize projectileTag = _projectileTag;
@synthesize moveDuration = _moveDuration;
@synthesize lastWaypoint = _lastWaypoint;
@synthesize healthBar = _healthBar;
@synthesize totalHp = _totalHp;
@synthesize currentWaypoint = _currentWaypoint;
@synthesize path = _path;
@synthesize isGone = _isGone;
@synthesize rotateAddition = _rotateAddition;
@synthesize isStop = _isStop;
@synthesize selfScale = _selfScale;
@synthesize currentRotation = _currentRotation;
@synthesize creepPropertyList = _creepPropertyList;
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
        //[self stopMovingForSeconds:1];
        inum = 0;
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
            //[target release];
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
    if(!self.currentWaypoint) return;
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
    [self.path removeAllObjects];
    while (fromNode) {
        [self.path addObject:fromNode];
        fromNode = fromNode.fromNode;
    }
    currentIndexAtPath = self.path.count-1;
}

- (void)creepLogic:(ccTime)dt {	
    WayPoint *waypoint = [self getNextWaypoint];
    
    // Rotate creep to face next waypoint
    CGPoint waypointVector = ccpSub(waypoint.position, self.position);
    CGFloat waypointAngle = ccpToAngle(waypointVector);
    CGFloat cocosAngle = self.rotateAddition + CC_RADIANS_TO_DEGREES(-1 * waypointAngle);
    
    float rotateSpeed = 0.02 / M_PI; // 0.02 second to roate 180 degrees
    float rotateDuration = fabs(waypointAngle * rotateSpeed); 
    id actionRotate = [CCRotateTo actionWithDuration:rotateDuration angle:cocosAngle];
    id actionMove = [CCMoveTo actionWithDuration:self.moveDuration position:waypoint.position];
    [self runAction:[CCSequence actions:actionRotate, actionMove, nil]];
    
    // (potientially) already moved, set the current way point to 'next' one.
    self.currentWaypoint.isOccupied = NO;
    self.currentWaypoint = [self getNextWaypoint];
    self.currentWaypoint.isOccupied = YES;
    if (currentIndexAtPath > 0) {
        [self.path removeObjectAtIndex:currentIndexAtPath];
    }
    currentIndexAtPath--;      
}

- (void)scalingWhenMoving{
    id bigger = [CCScaleTo actionWithDuration:0.3 scale:self.selfScale*1.1];
    id smaller = [CCScaleTo actionWithDuration:0.2 scale:self.selfScale*0.9];
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

- (void)beingPoisonedForSeconds:(int)seconds poinsonousDamage:(int)damage{    
    //id jj = [CCActionTween actionWithDuration:2 key:@"color" from:ccGREEN to:];
    id poisoning = [CCRepeat actionWithAction:
                        [CCSequence actions:
                            [CCCallBlock actionWithBlock:^{
                                    self.hp -= damage;
                                }], 
                            [CCDelayTime actionWithDuration:1],nil] 
                                    times:seconds];
    
    [self runAction:[CCSequence actions:poisoning, 
                     [CCCallBlock actionWithBlock:^{
                          self.color = ccWHITE;
                      }],
                     
                      nil]];
}

- (void)beingShockingForSeconds:(int)seconds{
    [self stopAllActions];
    [self unschedule:@selector(creepLogic:)];
    [self unschedule:@selector(scalingWhenMoving)];
    id delay = [CCDelayTime actionWithDuration: 0.1];
    float rotateDuration = 0.1;
    //CGFloat cocosAngle = self.rotateAddition + 20;

    id rightRotate = [CCRotateBy actionWithDuration:rotateDuration angle:20];
    id leftRotate = [CCRotateBy actionWithDuration:rotateDuration angle:-20];
    id rotating = [CCRepeat actionWithAction:
                    [CCSequence actions: rightRotate, leftRotate, nil] 
                                       times:(seconds-0.1)/rotateDuration];
    id actionMoveResume = [CCCallBlock actionWithBlock:^{
        [self schedule:@selector(creepLogic:) interval:self.moveDuration];
        [self schedule:@selector(scalingWhenMoving) interval:self.moveDuration];
        self.color = ccWHITE;
        }];
    [self runAction:[CCSequence actions:rotating, delay, actionMoveResume, nil]];
}

- (void)dealloc{
    [gameHUD release];

    [self.healthBar release];
    [self.currentWaypoint release];
    [self.path release];
    [super dealloc];
}

- (NSDictionary *)creepPropertyList{
    if (!_creepPropertyList) {
        NSString *errorDesc = nil;
        NSPropertyListFormat format;
        NSString *plistPath;
        NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                  NSUserDomainMask, YES) objectAtIndex:0];
        plistPath = [rootPath stringByAppendingPathComponent:@"Creep.plist"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
            plistPath = [[NSBundle mainBundle] pathForResource:@"Creep" ofType:@"plist"];
        }
        NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
        _creepPropertyList = (NSDictionary *)[NSPropertyListSerialization
                                              propertyListFromData:plistXML
                                              mutabilityOption:NSPropertyListImmutable
                                              format:&format
                                              errorDescription:&errorDesc];
        if (!_creepPropertyList) {
            NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
        }
    }
    return _creepPropertyList;
}


@end

@implementation FastRedCreep

+ (id)creep {
    
    FastRedCreep *creep = nil;
    if ((creep = [[[super alloc] initWithFile:@"cockroach.png"] autorelease])) {
        NSDictionary *creepPList = [creep.creepPropertyList objectForKey:@"FastCreep"];
        creep.hp = creep.totalHp = [[creepPList objectForKey:@"health"] intValue];
        creep.moveDuration = [[creepPList objectForKey:@"moveDuration"] floatValue];
        creep.rotateAddition = 90;
        creep.selfScale = 1;
        [creep randomlyChooseStartNode];
        [creep schedule:@selector(healthBarLogic:)];
        [creep schedule:@selector(creepLogic:) interval:creep.moveDuration];
        
        /*CCSprite *glowSprite = creep;
        [glowSprite setColor:greenColor];
        //[glowSprite setPosition:ccp(500, 500)];
        [glowSprite setBlendFunc: (ccBlendFunc) { GL_ONE, GL_ONE }];
        [glowSprite runAction: [CCRepeatForever actionWithAction:
                                [CCSequence actions:
                                 [CCScaleTo actionWithDuration:0.9f
                                                        scaleX:3 
                                                        scaleY:3], 
                                 [CCScaleTo actionWithDuration:0.9f scaleX:3*0.75f scaleY:3*0.75f], nil] ] ];
        [glowSprite runAction: [CCRepeatForever actionWithAction:
                                [CCSequence actions:[CCFadeTo actionWithDuration:0.9f
                                                                         opacity:150], 
                                 [CCFadeTo actionWithDuration:0.9f opacity:255], nil]
                                ] ];
        creep = glowSprite;*/
    }
    return creep;
}

@end

@implementation StrongGreenCreep

+ (id)creep {
    
    StrongGreenCreep *creep = nil;
    if ((creep = [[[super alloc] initWithFile:@"image 1797.png"] autorelease])) {
        NSDictionary *creepPList = [creep.creepPropertyList objectForKey:@"GreenCreep"];
        creep.hp = creep.totalHp = [[creepPList objectForKey:@"health"] intValue];
        creep.moveDuration = [[creepPList objectForKey:@"moveDuration"] floatValue];
        creep.rotateAddition = creep.rotation = 90;
        creep.scale = creep.selfScale = 0.5;
        [creep randomlyChooseStartNode];
        [creep schedule:@selector(creepLogic:) interval:creep.moveDuration];
        [creep schedule:@selector(healthBarLogic:)];
        [creep schedule:@selector(scalingWhenMoving) interval:creep.moveDuration];
    }
    return creep;
}

@end

@implementation BossBrownCreep

+ (id)creep {
    BossBrownCreep *creep = nil;
    
    if ((creep = [[[super alloc] initWithFile:@"Enemy3.png"] autorelease])) {
        NSDictionary *creepPList = [creep.creepPropertyList objectForKey:@"BrownCreep"];
        creep.hp = creep.totalHp = [[creepPList objectForKey:@"health"] intValue];
        creep.moveDuration = [[creepPList objectForKey:@"moveDuration"] floatValue];
        [creep randomlyChooseStartNode];
        [creep schedule:@selector(creepLogic:) interval:creep.moveDuration];
        [creep schedule:@selector(healthBarLogic:)];
    } 
    
    return creep;
}
@end