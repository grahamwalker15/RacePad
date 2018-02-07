//
//  Positions.h
//  MatchPad
//
//  Created by Mark Riches on Aug 2012
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataStream;
@class PositionsView;
@class PitchView;
@class ImageList;

@interface TrailPoint : NSObject
{
	unsigned char opacity;
	float x;
	float y;
}

@property (assign) unsigned char opacity;
@property (assign) float x;
@property (assign) float y;

@end

@interface Position : NSObject
{
	unsigned char team;
	unsigned char player;
	float x;
	float y;
	NSMutableArray *trail;
}

@property (readonly) unsigned char team;
@property (readonly) unsigned char player;
@property (readonly) float x;
@property (readonly) float y;
@property (readonly) NSMutableArray *trail;

- (void) loadPosition : (DataStream *) stream Team: (unsigned char)team;

@end


@interface Positions : NSObject
{
	NSMutableArray *positions;
	float ballX, ballY;
	NSMutableArray *ballTrail;

	UIColor *teamColour[5];

}

@property (readonly) float ballX;
@property (readonly) float ballY;

- (void) loadPositions : (DataStream *) stream;

- (void) drawBallTrailInView:(PitchView *)view Scale: (float) scale XScale: (float) x_scale YScale:(float) y_scale;
- (void) drawTrailsInView:(PitchView *)view Scale: (float) scale XScale: (float) x_scale YScale:(float) y_scale;
- (void) drawPlayersInView:(PitchView *)view Scale: (float) scale XScale: (float) x_scale YScale:(float) y_scale;

@end
