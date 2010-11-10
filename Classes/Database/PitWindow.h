//
//  PitWindow.h
//  RacePad
//
//  Created by Mark Riches on 12/10/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataStream;
@class PitWindowView;

@interface PitWindowCar : NSObject
{
	UIColor *fillColour;
	UIColor *lineColour;
	UIColor *textColour;
	
	float x;
	NSString *name;
	bool inPit;
	float gapNext;
	float gapThis;
	bool lapped;
	bool lapping;
	
	int px, py;
}

- (id) init;

- (void) load : (DataStream *) stream Colours: (UIColor **)colours ColoursCount:(int)coloursCount;
- (void) preDraw : (PitWindowView *)view Y:(int)y LastX:(int *) lastX LastY:(int *)lastY;
- (void) draw : (PitWindowView *)view Y:(int)y XMaxTime:(int)xMaxTime;

@end

@interface PitWindow : NSObject
{
	NSMutableArray *redCars;
	NSMutableArray *blueCars;
	UIColor **colours;
	int coloursCount;
	
	int redCarCount;
	int blueCarCount;
	
	float pitStopLoss;
	float pitStopLossMargin;
	float pitStopLossSC;
	
	int xRange;
	int xMaxTime;
		
}

- (void) loadBase: (DataStream *) stream;
- (void) load : (DataStream *) stream;

- (void) draw:(PitWindowView *)view;

@end
