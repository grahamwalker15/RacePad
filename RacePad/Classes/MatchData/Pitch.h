//
//  Pitch.h
//  MatchPad
//
//  Created by Mark Riches on 12/10/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataStream;
@class PitchView;
@class Pitch;
@class ImageList;


@interface PitchLine : NSObject
{
	UIColor *colour;
	unsigned char lineType;
	float x0, y0, x1, y1;
	NSString *player;
	UIColor *playerColour;
	UIColor *playerBG;
}

@property (readonly) UIColor *colour;
@property (readonly) unsigned char lineType;
@property (readonly) float x0;
@property (readonly) float y0;
@property (readonly) float x1;
@property (readonly) float y1;
@property (nonatomic, retain) NSString *player;
@property (nonatomic, retain) UIColor *playerColour;
@property (nonatomic, retain) UIColor *playerBG;

- (void) loadShape : (DataStream *) stream Count: (int) count Colours: (UIColor **)colours ColoursCount:(int)coloursCount AllNames:(bool)allNames;

@end

@interface Pitch : NSObject
{
	NSMutableArray *lines;
	UIColor **colours;
	int coloursCount;
	
	float playerX, playerY;
	NSString *player;
	UIColor *playerColour;
	UIColor *playerBG;
	float nextPlayerX, nextPlayerY;
	NSString *nextPlayer;
	UIColor *nextPlayerColour;
	UIColor *nextPlayerBG;
	float thirdX, thirdY;
	NSString *third;
	UIColor *thirdColour;
	UIColor *thirdBG;
	
	int playerNameFont;
}

- (void) loadPitch : (DataStream *) stream AllNames:(bool) allNames;

- (void) drawPassesInView:(PitchView *)view AllNames: (bool) allNames Scale: (float) scale XScale: (float) x_scale YScale:(float) y_scale;
- (void) drawNamesInView:(PitchView *)view AllNames: (bool) allNames Scale: (float) scale XScale: (float) x_scale YScale:(float) y_scale;

@end
