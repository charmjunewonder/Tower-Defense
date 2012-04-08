//
//  TutorialScene.m
//  TowerDefense
//
//  Created by charmjunewonder on 4/3/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "TutorialScene.h"
#import "DataModel.h"
#import "Tower.h"
#import "Projectile.h"

@implementation TutorialScene

@synthesize tileMap = _tileMap;
@synthesize background = _background;
@synthesize currentLevel = _currentLevel;
@synthesize gameHUD = _gameHUD;
@synthesize baseAttributes = _baseAttributes;
@synthesize buildable = _buildable;

static TutorialScene *_TutorialScene = nil;

+ (id)getTutorialScene{
    if (!_TutorialScene)
        @synchronized([TutorialScene class])
    {
        if (!_TutorialScene)
            _TutorialScene = [[self alloc] init];
        return _TutorialScene;
    }
	return _TutorialScene;
}

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	TutorialScene *layer = [TutorialScene getTutorialScene];
	
	// add layer as a child to scene
	[scene addChild: layer z:1];
	
    GameHUD *myGameHUD = [GameHUD sharedHUD];
	[scene addChild:myGameHUD z:2];
    /*
    CCLayer *menuLayer =[[[MenuLayer alloc]init ]autorelease];
    [scene addChild:menuLayer z:10];
    [[CCDirector sharedDirector] pause];
    */
	DataModel *m = [DataModel getModel];
	m.gameLayer = layer;
    m.gameHUDLayer = myGameHUD;
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init {
    if((self = [super init])) {				
		self.tileMap = [CCTMXTiledMap tiledMapWithTMXFile:@"Tower Defense 1.tmx"];
        self.background = [_tileMap layerNamed:@"Background"];
        self.buildable = [_tileMap layerNamed:@"Buildable"];
		self.background.anchorPoint = ccp(0, 0);
        //self.buildable.anchorPoint = ccp(150, 150);
        //self.background.position = ccp(150, 150);
        //self.buildable.position = ccp(150, 150);
		[self addChild:_tileMap z:0];
		
		[self addWaypoint];
		[self addWaves];
		
		// Call game logic about every second
        [self schedule:@selector(update:)];
		[self schedule:@selector(gameLogic:) interval:1.0];		
		
		self.currentLevel = 0;
		
		self.position = ccp(150, 150);
		
        self.gameHUD = [GameHUD sharedHUD];
        self.baseAttributes = [BaseAttributes sharedAttributes];
    }
    return self;
}

- (Wave *)getCurrentWave{
	
	DataModel *m = [DataModel getModel];	
	Wave * wave = (Wave *) [m.waves objectAtIndex:self.currentLevel];
	
	return wave;
}

- (Wave *)getNextWave{
	
	DataModel *m = [DataModel getModel];
	
	self.currentLevel++;
	
	if (self.currentLevel >= 5){
        //self.currentLevel = 0;
        NSLog(@"you have reached the end of the game!");
    }
	
    Wave * wave = (Wave *) [m.waves objectAtIndex:self.currentLevel];
    
    return wave;
}

-(void)addWaypoint {
    DataModel *data = [DataModel getModel];
	
	WayPoint *wp = nil;
    
    // end node, only one
    CCTMXObjectGroup *end = [self.tileMap objectGroupNamed:@"End"];
    NSMutableDictionary *endNode = [end objectNamed:@"End"];
    int x = [[endNode valueForKey:@"x"] intValue];
    int y = [[endNode valueForKey:@"y"] intValue];
    //printf("Point : (%d, %d)", x, y);

    wp = [[WayPoint alloc] init];
    wp.position = ccp(x, y);
    [data.waypoints addObject:wp];
    data.endNode = wp;
    
    // start node, maybe more than one
    CCTMXObjectGroup *startNodes = [self.tileMap objectGroupNamed:@"Factory"];
    for (NSMutableArray *point in startNodes.objects){
        x = [[point valueForKey:@"x"] intValue];
		y = [[point valueForKey:@"y"] intValue];
        //printf("Point : (%d, %d)\n", x, y);
        
        wp = [[WayPoint alloc] init];
        wp.position = ccp(x, y);
        [data.startNodes addObject:wp];
        [data.waypoints addObject:wp];
    }

    // nodes along the road
    CCTMXObjectGroup *routine = [self.tileMap objectGroupNamed:@"Routine"];
    for(NSMutableDictionary *point in routine.objects){
        x = [[point valueForKey:@"x"] intValue];
		y = [[point valueForKey:@"y"] intValue];
        //printf("Point : (%d, %d)\n", x, y);
        wp = [[WayPoint alloc] init];
		wp.position = ccp(x, y);
        
        // connect them to be a graph
        for (WayPoint *adjacentPoint in data.waypoints){
            //printf("Points : (%.0lf, %.0lf)(%.0lf, %.0lf)\n", wp.position.x, wp.position.y, adjacentPoint.position.x, adjacentPoint.position.y);
            int xx = abs(adjacentPoint.position.x - wp.position.x);
            int yy = abs(adjacentPoint.position.y - wp.position.y);
            if ((xx < 48 && yy < 16) || (yy < 48 && xx < 16)) {
                [wp.adjacentNodes addObject:adjacentPoint];
                [adjacentPoint.adjacentNodes addObject:wp];
                //printf("Points : (%.0lf, %.0lf)(%.0lf, %.0lf)%d,%d\n", wp.position.x, wp.position.y, adjacentPoint.position.x, adjacentPoint.position.y, xx, yy);
            }
        }
        
		[data.waypoints addObject:wp];
        
    }
    	
	NSAssert([data.waypoints count] > 0, @"Waypoint objects missing");
	wp = nil;
}

-(void)addTarget {
    
	DataModel *data = [DataModel getModel];
	Wave * wave = [self getCurrentWave];
	if (wave.redCreeps <= 0 && wave.greenCreeps <= 0) {
        
        return; //
	}
	
    Creep *target = nil;
    int creepChoice = (arc4random() % 3);
    int layer;
    switch (creepChoice) {
        case 0:
            if (wave.redCreeps > 0) {
                target = [FastRedCreep creep];
                target.tag = 1;
                wave.redCreeps--;
                layer = 1;
            }
            else {
                [self addTarget];
                return;
            }
            break;
        case 1:
            if (wave.greenCreeps >0) {
                target = [StrongGreenCreep creep];
                target.tag = 2;
                wave.greenCreeps--;
                layer = 1;
            }
            else {
                [self addTarget];
                return;
            }
            break;
        case 2:
            if (wave.brownCreeps >0) {
                target = [BossBrownCreep creep];
                target.tag = 3;
                wave.brownCreeps--;
                layer = 2;
            }
            else{
                [self addTarget];
                return;
            }
            break;
        default:
            break;
    }
	
	WayPoint *waypoint = target.currentWaypoint;
	target.position = waypoint.position;	
	//waypoint = [target getNextWaypoint ];
	
	[self addChild:target z:1];
	
    target.healthBar = [CCProgressTimer progressWithFile:@"health_bar_red.png"];
    target.healthBar.type = kCCProgressTimerTypeHorizontalBarLR;
    target.healthBar.percentage = 100;
    [target.healthBar setScale:0.1]; 
    target.healthBar.position = ccp(target.position.x,(target.position.y+20));
    [self addChild:target.healthBar z:3];

	/*int moveDuration = target.moveDuration;	
	id actionMove = [CCMoveTo actionWithDuration:moveDuration position:waypoint.position];
	id actionMoveDone = [CCCallFuncN actionWithTarget:self selector:@selector(FollowPath:)];
	[target runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];*/
	
	// Add to targets array
	target.tag = 1;
	[data.targets addObject:target];	
}

-(void)addWaves {
	DataModel *data = [DataModel getModel];
	
	Wave *wave = nil;
    wave = [[Wave alloc] initWithCreep:[FastRedCreep creep] SpawnRate:1.0 RedCreeps:1 GreenCreeps:0 BrownCreeps:0];
    [data.waves addObject:wave];
	wave = nil;
	wave = [[Wave alloc] initWithCreep:[FastRedCreep creep] SpawnRate:1.0 RedCreeps:0 GreenCreeps:0 BrownCreeps:0];
    [data.waves addObject:wave];
	wave = nil;
	wave = [[Wave alloc] initWithCreep:[FastRedCreep creep] SpawnRate:1.0 RedCreeps:5 GreenCreeps:5 BrownCreeps:0];
    [data.waves addObject:wave];
	wave = nil;	
    wave = [[Wave alloc] initWithCreep:[FastRedCreep creep] SpawnRate:0.8 RedCreeps:7 GreenCreeps:8 BrownCreeps:0];
    [data.waves addObject:wave];
	wave = nil;
	wave = [[Wave alloc] initWithCreep:[FastRedCreep creep] SpawnRate:1.2 RedCreeps:7 GreenCreeps:14 BrownCreeps:0];
    [data.waves addObject:wave];
    wave = nil;
    wave = [[Wave alloc] initWithCreep:[FastRedCreep creep] SpawnRate:1.5 RedCreeps:5 GreenCreeps:5 BrownCreeps:2];
    [data.waves addObject:wave];
	wave = nil;
}

-(void)waveWait
{
    [self unschedule:@selector(waveWait)];
    [self getNextWave];
    [self.gameHUD updateWaveCount];
    [self.gameHUD newWaveApproachingEnd];
}

# pragma mark - add tower

// a quick way to determine the positon of the current tile we are over and we use that 
// in the “addTower” function which actually places the tower on the map (assuming it 
// is buildable there).
- (CGPoint)tileCoordForPosition:(CGPoint) position{
    int x = position.x / self.tileMap.tileSize.width;
    int y = (self.tileMap.tileSize.height * self.tileMap.mapSize.height - position.y) /
            self.tileMap.tileSize.height;
    return ccp(x, y);
}

/*  
    checking the tile property and seeing if the "buildable" property is 
    there and if it is set to "1" it returns YES - all other tiles that 
    are either null or anything other than "1" return NO.
*/
- (BOOL) canBuildOnTilePosition:(CGPoint) position 
{
    /*CGRect gameLayerRect = CGRectMake(self.position.x,
                                      self.position.y,
                                      self.contentSize.width,
                                      self.contentSize.height);*/
    CGRect buildableLayerRect = CGRectMake(self.buildable.position.x,
                                      self.buildable.position.y,
                                      self.buildable.contentSize.width,
                                      self.buildable.contentSize.height);

    if (CGRectContainsPoint(buildableLayerRect, position)){
        CGPoint towerLocation = [self tileCoordForPosition: position];
        if (towerLocation.x >= 20 || towerLocation.y >= 17 || towerLocation.x  < 0 || towerLocation.y < 0)
            return false; // safe bound check 
        int tileGid = [self.buildable tileGIDAt:towerLocation];
        NSDictionary *properties = [self.tileMap propertiesForGID:tileGid];
        NSString *type = [properties valueForKey:@"Buildable"];
        BOOL occupied = NO;
        DataModel *data = [DataModel getModel];

        for (Tower *tower in data.towers) {
            CGRect towerRect = CGRectMake(tower.position.x - (tower.contentSize.width/2), tower.position.y - (tower.contentSize.height/2), tower.contentSize.width, tower.contentSize.height);
            if (CGRectContainsPoint(towerRect, position)) {
                occupied = YES;
            }
        } 

        if([type isEqualToString: @"1"] && occupied == NO) {
            return YES;
        }
    }
	return NO;
}

- (void)addTower: (CGPoint)position tag: (int)towerTag{
    DataModel *data = [DataModel getModel];
    Tower *tower = nil;
    CGPoint towerLocation = [self tileCoordForPosition:position];

    if ([self canBuildOnTilePosition:position]) {
        switch (towerTag) {
            case 1:
                if (self.gameHUD.resources >= (int)(self.baseAttributes.baseMGCost * self.baseAttributes.baseTowerCostPercentage)) {
                    tower = [MachineGunTower tower];
                    [self.gameHUD updateResources:-(int)(self.baseAttributes.baseMGCost*self.baseAttributes.baseTowerCostPercentage)];
                }
                else
                    return;
                break;
            case 2:
                if (self.gameHUD.resources >= (int)(self.baseAttributes.baseFCost*self.baseAttributes.baseTowerCostPercentage)) {
                    tower = [FreezeTower tower];
                    [self.gameHUD updateResources:-(int)(self.baseAttributes.baseFCost*self.baseAttributes.baseTowerCostPercentage)];
                }
                else
                    return;
                break;
            case 3:
                if (self.gameHUD.resources >= (int)(self.baseAttributes.baseCCost*self.baseAttributes.baseTowerCostPercentage)) {
                    tower = [CannonTower tower]; //To change later
                    [self.gameHUD updateResources:-(int)(self.baseAttributes.baseCCost*self.baseAttributes.baseTowerCostPercentage)];
                }
                else
                    return;
                break;
            default:
                break;
        }
        //int yy = self.tileMap.contentSize.height - (towerLocation.y * 32);
		tower.position = ccp((towerLocation.x * 32)+16, (self.tileMap.contentSize.height - (towerLocation.y * 32))-16);
        [self addChild:tower z:1];
        tower.tag = 1;
        [data.towers addObject:tower];
    }
}

-(void)FollowPath:(id)sender {
    
	Creep *creep = (Creep *)sender;
	
	WayPoint *waypoint = [creep getNextWaypoint];
    //creep.currentWaypoint = waypoint;
    
	id actionMove = [CCMoveTo actionWithDuration:creep.moveDuration position:waypoint.position];
	id actionMoveDone = [CCCallFuncN actionWithTarget:self selector:@selector(FollowPath:)];
	[creep stopAllActions];
	[creep runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
}

-(void)gameLogic:(ccTime)dt {
	
	Wave * wave = [self getCurrentWave];
	static double lastTimeTargetAdded = 0;
    double now = [[NSDate date] timeIntervalSince1970];
    if(lastTimeTargetAdded == 0 || now - lastTimeTargetAdded >= wave.spawnRate) {
        [self addTarget];
        lastTimeTargetAdded = now;
    }
	
}

- (CGPoint)boundLayerPos:(CGPoint)newPos {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    CGPoint retval = newPos;
    retval.x = MIN(retval.x, 0);
    retval.x = MAX(retval.x, -_tileMap.contentSize.width+winSize.width); 
    retval.y = MIN(0, retval.y);
    retval.y = MAX(-_tileMap.contentSize.height+winSize.height, retval.y); 
    return retval;
}

- (void)handlePanFrom:(UIPanGestureRecognizer *)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {    
        
        CGPoint touchLocation = [recognizer locationInView:recognizer.view];
        touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
        touchLocation = [self convertToNodeSpace:touchLocation];                
        
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {    
        
        CGPoint translation = [recognizer translationInView:recognizer.view];
        translation = ccp(translation.x, -translation.y);
        CGPoint newPos = ccpAdd(self.position, translation);
        self.position = [self boundLayerPos:newPos];  
        [recognizer setTranslation:CGPointZero inView:recognizer.view];    
        
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        
		float scrollDuration = 0.2;
		CGPoint velocity = [recognizer velocityInView:recognizer.view];
		CGPoint newPos = ccpAdd(self.position, ccpMult(ccp(velocity.x, velocity.y * -1), scrollDuration));
		newPos = [self boundLayerPos:newPos];
        
		[self stopAllActions];
		CCMoveTo *moveTo = [CCMoveTo actionWithDuration:scrollDuration position:newPos];            
		[self runAction:[CCEaseOut actionWithAction:moveTo rate:1]];            
        
    }        
}

-(void)ResumePath:(id)sender {
    Creep *creep = (Creep *)sender;
    
    WayPoint * cWaypoint = creep.currentWaypoint;//destination
    WayPoint * lWaypoint = [creep getLastWaypoint];//startpoint
    
    float waypointDist = fabsf(cWaypoint.position.x - lWaypoint.position.x);
    float creepDist = fabsf(cWaypoint.position.x - creep.position.x);
    float distFraction = creepDist / waypointDist;
    float moveDuration = creep.moveDuration * distFraction; //Time it takes to go from one way point to another * the fraction of how far is left to go (meaning it will move at the correct speed)
    
    id actionMove = [CCMoveTo actionWithDuration:moveDuration position:cWaypoint.position];   
    id actionMoveDone = [CCCallFuncN actionWithTarget:self selector:@selector(FollowPath:)];
	[creep stopAllActions];
	[creep runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
}

/*
    This logic will handle the collision detection of the current projectiles 
    flying about the screen with the creeps. The basic logic is simple: 
    1) loop through all the projectiles, 
    2) for each projectile, loop through all the targets present, 
    3) determine if the bounding box for the projectile intersects the bounding box for the target, 
    4) if they intersect then deduct health from the creep and add the projectile to a deletion array, 
    5) If the creep has 0 health then add the target to a deletion array, 
    6) remove all the objects from the projectile and creep deletion arrays. 
*/
- (void)update:(ccTime)dt {
    
    DataModel *data = [DataModel getModel];
	NSMutableArray *projectilesToDelete = [[NSMutableArray alloc] init];
    
    NSMutableArray *projectiles = data.projectiles;
	for (Projectile *projectile in projectiles) {
		
		CGRect projectileRect = CGRectMake(projectile.position.x - 
                                           (projectile.contentSize.width/2), 
										   projectile.position.y - 
                                           (projectile.contentSize.height/2), 
										   projectile.contentSize.width, 
										   projectile.contentSize.height);
        
		NSMutableArray *targetsToDelete = [[NSMutableArray alloc] init];
		
		for (CCSprite *target in data.targets) {
			CGRect targetRect = CGRectMake(target.position.x - (target.contentSize.width/2), 
										   target.position.y - (target.contentSize.height/2), 
										   target.contentSize.width, 
										   target.contentSize.height);
            
			if (CGRectIntersectsRect(projectileRect, targetRect)) {
                
				[projectilesToDelete addObject:projectile];
                Creep *creep = (Creep *)target;
                Creep *thisCreep;
                Tower *parentTower = (Tower *) projectile.parentTower;
                int thisHitDamage;
                CGRect splashRect;
                switch (projectile.tag) {
                    case 1:
                        thisHitDamage = (rand()%self.baseAttributes.baseMGDamageRandom)+parentTower.damageMin;
                        creep.hp -= thisHitDamage;
                        
                        parentTower.experience += thisHitDamage;
                        break;
                        
                    case 2:
                        thisHitDamage = (rand()%self.baseAttributes.baseFDamageRandom)+parentTower.damageMin;
                        creep.hp -= thisHitDamage;
                        parentTower.experience += thisHitDamage;
                        
                        id actionFreeze = [CCMoveTo actionWithDuration:parentTower.freezeDur position:creep.position];    
                        id actionMoveResume = [CCCallFuncN actionWithTarget:self selector:@selector(ResumePath:)];  
                        [creep stopAllActions];
                        [creep runAction:[CCSequence actions:actionFreeze, actionMoveResume, nil]];
                        break;
                        
                    case 3:
                        thisHitDamage = (rand()%self.baseAttributes.baseFDamageRandom)+parentTower.damageMin;
                        parentTower.experience += thisHitDamage;
                        splashRect = CGRectMake(projectile.position.x - (parentTower.splashDist), 
                                                projectile.position.y - (parentTower.splashDist), 
                                                (parentTower.splashDist*2), 
                                                (parentTower.splashDist*2));
                        for (CCSprite *target in data.targets) {
                            CGRect thistargetRect = CGRectMake(target.position.x - (target.contentSize.width/2), 
                                                               target.position.y - (target.contentSize.height/2), 
                                                               target.contentSize.width, 
                                                               target.contentSize.height);
                            if (CGRectIntersectsRect(splashRect, thistargetRect)) {
                                thisCreep = (Creep *) target;
                                thisCreep.hp -= thisHitDamage;
                                if (thisCreep.hp <= 0) {
                                    
                                    [targetsToDelete addObject:target];
                                    [self.gameHUD updateResources: rand()%(self.baseAttributes.baseMoneyDropped)];
                                    [self removeChild:thisCreep.healthBar cleanup:YES];
                                    
                                }
                            }
                        }
                        break;
                    default:
                        break;
                }
                
                if (creep.hp <= 0) {
                    
                    [targetsToDelete addObject:target];
                    [self.gameHUD updateResources: rand()%(self.baseAttributes.baseMoneyDropped)];
                    [self removeChild:creep.healthBar cleanup:YES];
                    
                }
                break;
                
			}						
		}
		
		for (CCSprite *target in targetsToDelete) {
			[data.targets removeObject:target];
			[self removeChild:target cleanup:YES];									
		}
		
		[targetsToDelete release];
	}	
    for (CCSprite *projectile in projectilesToDelete) {
        [data.projectiles removeObject:projectile];
        [self removeChild:projectile cleanup:YES];
	}
	[projectilesToDelete release];
    
    Wave *wave = [self getCurrentWave];
    //int alivecount = [m._targets count];
    if ([data.targets count] ==0 && wave.redCreeps <= 0 
        && wave.greenCreeps <= 0 && wave.brownCreeps <= 0) {
        if (self.currentLevel == 5) {
        }
        else{
            [self schedule:@selector(waveWait) interval:3.0];
            [self.gameHUD newWaveApproaching];
        }
    }

}

@end
