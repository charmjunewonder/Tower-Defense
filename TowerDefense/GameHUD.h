//
//  GameHUD.h
//  TowerDefense
//
//  Created by charmjunewonder on 4/4/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BaseAttributes.h"

@interface GameHUD : CCLayer {
    CCSprite *background;	// the background image to the CCLayer
    // the range image (much like the one that is used on the tower once it has been placed). 
	CCSprite *selSpriteRange; 
    // the copy of the tower image that we’ll be moving around the screen 
    // when the person selects the tower from the gameLayer.
    CCSprite *selSprite;
    // just an array of CCSprites that we’re drawing to the gameLayer 
    // that represent the towers we’ll have.
    NSMutableArray *movableSprites;
    
    CCLabelTTF *resourceLabel;
    CCLabelTTF *waveCountLabel;
    CCLabelTTF *newWaveLabel;

    CCProgressTimer *healthBar;
    BaseAttributes *baseAttributes;
    int waveCount;
}

@property (nonatomic, assign) int resources;
@property (nonatomic, assign) float baseHpPercentage;
@property (nonatomic, assign) int waveCount;
@property (nonatomic, retain) NSDictionary *baseAttribute;

+ (GameHUD *)sharedHUD;
-(void) updateBaseHp:(int)amount;
-(void) updateResources:(int)amount;
-(void) updateResourcesNom;
-(void) updateWaveCount;
-(void) newWaveApproaching;
-(void) newWaveApproachingEnd;

@end
