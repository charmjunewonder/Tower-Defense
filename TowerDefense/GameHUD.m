//
//  GameHUD.m
//  TowerDefense
//
//  Created by charmjunewonder on 4/4/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GameHUD.h"
#import "DataModel.h"
#import "TutorialScene.h"

@implementation GameHUD

@synthesize resources = _resources;
@synthesize baseHpPercentage = _baseHpPercentage;
@synthesize waveCount = _waveCount;
@synthesize baseAttribute = _baseAttribute;

static GameHUD *_sharedHUD = nil;

+ (GameHUD *)sharedHUD
{
    if (!_sharedHUD)
        @synchronized([GameHUD class])
        {
            if (!_sharedHUD)
                _sharedHUD = [[self alloc] init];
            return _sharedHUD;
        }
	return _sharedHUD;
}

- (NSDictionary *)baseAttribute{
    if (!_baseAttribute) {
        NSString *errorDesc = nil;
        NSPropertyListFormat format;
        NSString *plistPath;
        NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                  NSUserDomainMask, YES) objectAtIndex:0];
        plistPath = [rootPath stringByAppendingPathComponent:@"baseAttribute.plist"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
            plistPath = [[NSBundle mainBundle] pathForResource:@"baseAttribute" ofType:@"plist"];
        }
        NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
        _baseAttribute = (NSDictionary *)[NSPropertyListSerialization
                                              propertyListFromData:plistXML
                                              mutabilityOption:NSPropertyListImmutable
                                              format:&format
                                              errorDescription:&errorDesc];
        if (!_baseAttribute) {
            NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
        }
    }
    return _baseAttribute;

}

/* 
    We are first loading the gameLayer background image and then we 
    loop through an array of image names, load and store the image 
    as a CCSprite, give them a position with a little offset for 
    distance and then add it to the gameLayer and store it in 
    moveableSprite for lookup later...
*/
- (id)init{
    if ((self = [super init])) {
        baseAttributes = [BaseAttributes sharedAttributes];

        CGSize winSize = [CCDirector sharedDirector].winSize;
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        background = [CCSprite spriteWithFile:@"hud.png"];
        background.anchorPoint = ccp(0, 0);
        [self addChild:background];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
        
        movableSprites = [[NSMutableArray alloc] init];
        NSArray *images = [NSArray arrayWithObjects:@"build tower.jpg", @"gem 1.png", @"gem 2.png", @"gem 3.jpg", nil]; 
        for (int i = 0; i < images.count; ++i) {
            NSString *image = [images objectAtIndex:i];
            CCSprite *sprite = [CCSprite spriteWithFile:image];
            float offsetFraction = ((float)(i+1)/(images.count+1));
            sprite.position = ccp(background.contentSize.width*offsetFraction, 35);
            sprite.tag = i+1;
            [self addChild:sprite];
            [movableSprites addObject:sprite];
            
            //Set up and place towerCost labels
            CCLabelTTF *towerCost = [CCLabelTTF labelWithString:@"$" fontName:@"Marker Felt" fontSize:10];
            towerCost.position = ccp(winSize.width*offsetFraction, 15);
            towerCost.color = ccc3(0, 0, 0);
            [self addChild:towerCost z:1];
            
            //Set cost values
            switch (i) {
                case 0:
                    [towerCost setString:[NSString stringWithFormat:@"$ %i", (int)(baseAttributes.baseMGCost*baseAttributes.baseTowerCostPercentage)]];
                    break;
                case 1:
                    [towerCost setString:[NSString stringWithFormat:@"$ %i",(int)(baseAttributes.baseFCost*baseAttributes.baseTowerCostPercentage)]];
                    break;
                case 2:
                    [towerCost setString:[NSString stringWithFormat:@"$ %i",(int)(baseAttributes.baseCCost*baseAttributes.baseTowerCostPercentage)]];
                    break;
                    
                default:
                    break;
            }
        }
        
        // Set up Resources and Resource label
        self->resourceLabel = [CCLabelTTF labelWithString:@"Money $100" dimensions:CGSizeMake(150, 25) alignment:UITextAlignmentRight fontName:@"Marker Felt" fontSize:20];
        resourceLabel.position = ccp(30, (winSize.height - 15));
        resourceLabel.color = ccc3(255,80,20);
        [self addChild:resourceLabel z:1];
        
        self.resources = [[self.baseAttribute objectForKey:@"baseStartingMoney"] intValue];
        [self->resourceLabel setString:[NSString stringWithFormat: @"Money $%i",self.resources]];

        // Set up BaseHplabel
        CCLabelTTF *baseHpLabel = [CCLabelTTF labelWithString:@"Base Health" dimensions:CGSizeMake(150, 25) alignment:UITextAlignmentRight fontName:@"Marker Felt" fontSize:20];
        baseHpLabel.position = ccp((winSize.width - 185), (winSize.height - 15));
        baseHpLabel.color = ccc3(255,80,20);
        [self addChild:baseHpLabel z:1];
        
        // Set up wavecount label
        waveCount = 1;
        self->waveCountLabel = [CCLabelTTF labelWithString:@"Wave 1" dimensions:CGSizeMake(150, 25) alignment:UITextAlignmentRight fontName:@"Marker Felt" fontSize:20];
        waveCountLabel.position = ccp(((winSize.width/2)-80), (winSize.height-15));
        waveCountLabel.color = ccc3(255,80,20);
        [self addChild:waveCountLabel z:1];
        
        int baseHp = [[self.baseAttribute objectForKey:@"baseHealth"] intValue];
        self.baseHpPercentage = (baseHp/baseHp) *100;
        
        //Set up helth Bar
        self->healthBar = [CCProgressTimer progressWithFile:@"health_bar_green.png"];
        self->healthBar.type = kCCProgressTimerTypeHorizontalBarLR;
        self->healthBar.percentage = self.baseHpPercentage;
        [self->healthBar setScale:0.5]; 
        self->healthBar.position = ccp(winSize.width -55, winSize.height -15);
        [self addChild:healthBar z:1];

        // Set up new Wave label
        newWaveLabel = [CCLabelTTF labelWithString:@"" dimensions:CGSizeMake(300, 50) alignment:UITextAlignmentRight fontName:@"TrebuchetMS-Bold" fontSize:30];
        newWaveLabel.position = ccp((winSize.width/2)-20, (winSize.height/2)+30);
        newWaveLabel.color = ccc3(255,50,50);
        [self addChild:newWaveLabel z:1];

        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
        
        [self schedule:@selector(updateResourcesNom) interval: [[self.baseAttribute objectForKey:@"baseMoneyRegenRate"] intValue]];
        [self schedule:@selector(update:)];
                
    }
    return self;
}

+(id)alloc
{
	@synchronized([GameHUD class])
	{
		NSAssert(_sharedHUD == nil, @"Attempted to allocate a second instance of a singleton.");
		_sharedHUD = [super alloc];
		return _sharedHUD;
	}
	// to avoid compiler warning
	return nil;
}


-(void) newWaveApproaching{
    [newWaveLabel setString:[NSString stringWithFormat: @"HERE THEY COME!"]];
}
-(void) newWaveApproachingEnd{
    [newWaveLabel setString:[NSString stringWithFormat: @" "]];
}


/*
    we were storing the CCSprites that represented the tower images in the array 
    "movableSprites", well here we're looping through them and using 
    CCRectContainsPoint to determine is the touchLocation is contained within 
    one of the images. If it is them we call the model and tell it to first 
    turn off "gestureRecognizer" - You remember that's the variable that's a 
    pointer to the "UIPanGestureRecognizer" and it basically says... while 
    we're playing around with the towers dont move the screen. We them make 
    a copy of the tower being moved and add the value to "selSprite" and to 
    boot we also add the range image as well... So when you're placing a 
    tower you know how far it can shoot.
*/
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {    
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    CCSprite * newSprite = nil;
    for (CCSprite *sprite in movableSprites) {
        if (CGRectContainsPoint(sprite.boundingBox, touchLocation)) { 
            if (sprite.opacity == 255) {
                
                
                DataModel *data = [DataModel getModel];
                data.gestureRecognizer.enabled = NO;
                
                selSpriteRange = [CCSprite spriteWithFile:@"Range.png"];
                CCTexture2D* tex = nil;

                switch (sprite.tag) {
                    case 1:
                        tex = [[CCTextureCache sharedTextureCache] addImage:@"build tower selected.jpg"];
                        [sprite setTexture: tex];
                        break;
                    case 2:
                        selSpriteRange.scale = (baseAttributes.baseMGRange/50);
                        break;
                    case 3:
                        selSpriteRange.scale = (baseAttributes.baseFRange/50);
                        break; 
                    case 4:
                        selSpriteRange.scale = (baseAttributes.baseCRange/50);
                        break;
                    default:
                        break;
                }
                [self addChild:selSpriteRange z:-1];
                selSpriteRange.position = sprite.position;
                
                newSprite = [CCSprite spriteWithTexture:[sprite texture]]; //sprite;
                newSprite.position = sprite.position;
                selSprite = newSprite;
                selSprite.tag = sprite.tag;
                [self addChild:newSprite];
                
			}
            break;
        }
    }     
	return YES;

}

/*
    we can move the "fake" tower around the screen so the player can 
    know where he may drop it when he/she lets go. The more interesting 
    part is that I added additional code (calling a function in the 
    gameLayer called "canBuildOnTilePosition") which will allow me 
    to do a check on the tile location that we're hovering over 
    and see if it is buildable.
*/
- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    
    CGPoint oldTouchLocation = [touch previousLocationInView:touch.view];
    oldTouchLocation = [[CCDirector sharedDirector] convertToGL:oldTouchLocation];
    oldTouchLocation = [self convertToNodeSpace:oldTouchLocation];
    
    CGPoint translation = ccpSub(touchLocation, oldTouchLocation);
    
    if (selSprite) {
        CGPoint newPosition = ccpAdd(selSprite.position, translation);
        selSprite.position = newPosition;
        selSpriteRange.position = newPosition;
        
        DataModel *data = [DataModel getModel];
        CGPoint touchLocationInGameLayer = [data.gameLayer convertTouchToNodeSpace:touch];
        BOOL isBuildable = [data.gameLayer canBuildOnTilePosition: touchLocationInGameLayer];
        if (isBuildable) {
            selSprite.opacity = 200;
        }else{
            selSprite.opacity = 50;
        }
    }
}

/*
    one thing we need to check for before we can place a tower is to have 
    a "cancel" build location. Our default location is if the player drops 
    the tower on the gameHUD layer itself. So we do a check to see if the 
    touch end location is within the confines of the background image. If 
    it is verified to be on the gameLayer we call the "addTower" method 
    that we explained earlier. In all other cases, we just do clean up and 
    remove the "fake" tower image and its range as well.
*/
- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {  
	CGPoint touchLocation = [self convertTouchToNodeSpace:touch];	
	DataModel *data = [DataModel getModel];
    
	if (selSprite) {
		CGRect backgroundRect = CGRectMake(background.position.x, 
                                           background.position.y, 
                                           background.contentSize.width, 
                                           background.contentSize.height);
		
		if (!CGRectContainsPoint(backgroundRect, touchLocation)) {
			CGPoint touchLocationInGameLayer = [data.gameLayer convertTouchToNodeSpace:touch];
            switch (selSprite.tag) {
                case 1:
                    [data.gameLayer addTower: touchLocationInGameLayer];
                    break;
                case 2:
                    [data.gameLayer addMagicStone:touchLocationInGameLayer stoneTag:1];
                    break;
                case 3:
                    [data.gameLayer addMagicStone:touchLocationInGameLayer stoneTag:2];
                    break; 
                case 4:
                    [data.gameLayer addMagicStone:touchLocationInGameLayer stoneTag:3];
                    break;
                default:
                    break;
            }

		}
		
		[self removeChild:selSprite cleanup:YES];
		selSprite = nil;		
		[self removeChild:selSpriteRange cleanup:YES];
		selSpriteRange = nil;			
	}
	
	data.gestureRecognizer.enabled = YES;
}

-(void) updateBaseHp:(int)amount{
    self.baseHpPercentage += amount;
    
    if (self.baseHpPercentage <= 25) {
        [self->healthBar setSprite:[CCSprite spriteWithFile:@"health_bar_red.png"]];
        [self->healthBar setScale:0.5]; 
    }
    
    if (self.baseHpPercentage <= 0) {
    }
    
    [self->healthBar setPercentage:self.baseHpPercentage];
}

-(void) updateResources:(int)amount{
    self.resources += amount;
    [self->resourceLabel setString:[NSString stringWithFormat: @"Money $%i",self.resources]];
}

-(void) updateResourcesNom{
    self.resources += baseAttributes.baseMoneyRegen;
    [self->resourceLabel setString:[NSString stringWithFormat: @"Money $%i",self.resources]];
}
-(void) updateWaveCount{
    waveCount++;
    [self->waveCountLabel setString:[NSString stringWithFormat: @"Wave %i",waveCount]];
}
-(void) update:(ccTime) dt{
    
    for (CCSprite *sprite in movableSprites){
        switch (sprite.tag) {
            case 1:
                if (baseAttributes.baseMGCost*baseAttributes.baseTowerCostPercentage > self.resources)
                {
                    sprite.opacity = 50;
                    break;
                }
                else
                    sprite.opacity = 255;
                break;
            case 2:
                if (baseAttributes.baseFCost*baseAttributes.baseTowerCostPercentage > self.resources)
                {
                    sprite.opacity = 50;
                    break;
                }
                else
                    sprite.opacity = 255;
                break;
            case 3:
                if (baseAttributes.baseCCost*baseAttributes.baseTowerCostPercentage > self.resources)
                {
                    sprite.opacity = 50;
                    break;
                }
                else
                    sprite.opacity = 255;
                break;
            default:
                break;
        }
        
    }
}

- (void)dealloc{
    [movableSprites release];
    [super dealloc];
}

@end
