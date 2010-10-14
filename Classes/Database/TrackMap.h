//
//  TrackMap.h
//  RacePad
//
//  Created by Mark Riches on 12/10/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RacePadClientSocket;
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

-(id) init;

- (void) load : (RacePadClientSocket *) socket;
- (void) draw : (TrackMapView *) view Scale: (float) scale;

@end


@interface TrackShape : NSObject {

	float *x;
	float *y;
	int count;
	
}

- (id) init;
- (void) dealloc;

- (int) count;
- (float *)x;
- (float *)y;

- (void) loadShape : (RacePadClientSocket *) socket;

@end

@interface TrackMap : NSObject {
	
	TrackShape *inner;
	TrackShape *outer;
	NSMutableArray *cars;
	int carCount;
}

- (id) init;
- (void) dealloc;

- (void) loadTrack : (RacePadClientSocket *) socket;
- (void) updateCars : (RacePadClientSocket *) socket;

- (void) draw:(TrackMapView *)view;

@end
