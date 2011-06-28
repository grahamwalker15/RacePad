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
	
	CGMutablePathRef path;
	UIColor *colour;
	unsigned char lineType;
}

@property (readonly) CGMutablePathRef path;
@property (readonly) UIColor *colour;
@property (readonly) unsigned char lineType;

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
}

- (void) loadPitch : (DataStream *) stream;

- (void) drawInView:(PitchView *)view;

- (void) constructTransformMatrixForView:(PitchView *)view;
- (void) constructTransformMatrixForView:(PitchView *)view WithCentreX:(float)x Y:(float)y Rotation:(float) rotation;
- (void) adjustScaleInView:(PitchView *)view Scale:(float)scale X:(float)x Y:(float)y;
- (void) adjustPanInView:(PitchView *)view X:(float)x Y:(float)y;

@end
