//
//  TrackMap.h
//  RacePad
//
//  Created by Mark Riches on 12/10/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataStream;
@class TrackMapView;

enum TrackMapLineType {
	TM_L_INKNOWN,
	TM_L_MARSHALL_POST,
	TM_L_TURN_NUMBER,
	TM_L_SC_LINE,
	TM_L_PIT_LINE,
	TM_L_TIMING_LINE
};

@interface TrackCar : NSObject
{
	UIColor *pointColour;
	UIColor *fillColour;
	UIColor *lineColour;
	UIColor *textColour;
	
	float x, y;
	int dotSize;
	NSString *name;
	bool moving;
}

- (id) init;

- (void) load : (DataStream *) stream Colours: (UIColor **)colours ColoursCount:(int)coloursCount;
- (void) draw : (TrackMapView *)view Scale:(float)scale;

@end


@interface TrackShape : NSObject
{
	float min_x;
	float max_x;
	float min_y;
	float max_y;
	
	float width;
	float height;
	
	CGMutablePathRef path;
	int segmentCount;
	CGMutablePathRef *segmentPaths;
}

@property (readonly) float min_x;
@property (readonly) float max_x;
@property (readonly) float min_y;
@property (readonly) float max_y;
@property (readonly) float width;
@property (readonly) float height;
@property (readonly) CGMutablePathRef path;
@property (readonly) CGMutablePathRef *segmentPaths;
@property (readonly) int segmentCount;

- (float)width;
- (float)height;

- (void) loadShape : (DataStream *) stream;

@end

@interface TrackLine : NSObject
{
	
	CGMutablePathRef path;
	UIColor *colour;
	unsigned char lineType;
}

@property (readonly) CGMutablePathRef path;
@property (readonly) UIColor *colour;
@property (readonly) unsigned char lineType;

- (void) loadShape : (DataStream *) stream Count: (int) count;

@end

@interface TrackLabel : NSObject
{
	
	CGMutablePathRef path;
	UIColor *colour;
	unsigned char labelType;
	float x0, y0, x1, y1;
	NSString *label;
}

@property (readonly) CGMutablePathRef path;
@property (readonly) UIColor *colour;
@property (readonly) unsigned char lineType;
@property (readonly) NSString * label;

- (void) loadShape : (DataStream *) stream Count: (int) count;
- (void) labelPoint : (TrackMapView *)view Scale: (float) scale X:(float *)x Y:(float *)y;

@end

@interface SegmentState : NSObject
{
	int index;
	unsigned char state;
}

@property (readonly) int index;
@property (readonly) unsigned char state;

@end


@interface TrackMap : NSObject
{
	
	TrackShape *inner;
	TrackShape *outer;
	
	float x_centre;
	float y_centre;
	
	float width;
	float height;
	
	NSMutableArray *lines;
	NSMutableArray *labels;

	NSMutableArray *cars;
	UIColor **colours;
	int coloursCount;
	
	int carCount;
	
	NSMutableArray *segmentStates;
}

- (void) loadTrack : (DataStream *) stream;
- (void) updateCars : (DataStream *) stream;

- (void) draw:(TrackMapView *)view;

@end
