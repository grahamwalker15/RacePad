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
}

@property (readonly) UIColor *colour;
@property (readonly) unsigned char lineType;
@property (readonly) float x0;
@property (readonly) float y0;
@property (readonly) float x1;
@property (readonly) float y1;

- (void) loadShape : (DataStream *) stream Count: (int) count Colours: (UIColor **)colours ColoursCount:(int)coloursCount;

@end

@interface Pitch : NSObject
{
	
	float xCentre;
	float yCentre;
	
	float width;
	float height;
	
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
	UIColor *pitchColour;

	float a13, a23, a11, a21, a31, a12, a22, a32;
}

- (void) initialisePerspective;

- (void) loadPitch : (DataStream *) stream;

- (void) drawInView:(PitchView *)view;

- (void) constructTransformMatrixForView:(PitchView *)view;
- (void) constructTransformMatrixForView:(PitchView *)view WithCentreX:(float)x Y:(float)y Rotation:(float) rotation;
- (void) adjustScaleInView:(PitchView *)view Scale:(float)scale X:(float)x Y:(float)y;
- (void) adjustPanInView:(PitchView *)view X:(float)x Y:(float)y;

@end
