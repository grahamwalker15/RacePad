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

- (void) load : (DataStream *) stream;
- (void) draw : (TrackMapView *)view Scale:(float)scale;

@end


@interface TrackShape : NSObject
{

	float *x;
	float *y;
	int count;
	
	float min_x;
	float max_x;
	float min_y;
	float max_y;
	
	float width;
	float height;
}

@property (readonly) float min_x;
@property (readonly) float max_x;
@property (readonly) float min_y;
@property (readonly) float max_y;
@property (readonly) float width;
@property (readonly) float height;

- (int) count;
- (float *)x;
- (float *)y;

- (float)width;
- (float)height;

- (void) loadShape : (DataStream *) stream;

@end

@interface TrackMap : NSObject
{
	
	TrackShape *inner;
	TrackShape *outer;
	
	CGMutablePathRef inner_path;
	CGMutablePathRef outer_path;
	
	float x_centre;
	float y_centre;
	
	float width;
	float height;

	NSMutableArray *cars;
	
	int carCount;
}

- (void) loadTrack : (DataStream *) stream;
- (void) updateCars : (DataStream *) stream;

- (void) draw:(TrackMapView *)view;

@end
