//
//  TrackProfile.h
//  RacePad
//
//  Created by Mark Riches on 12/10/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataStream;
@class TrackProfileView;
@class TrackProfile;
@class ImageList;

@interface TrackProfileCar : NSObject
{
	UIColor *pointColour;
	UIColor *fillColour;
	UIColor *lineColour;
	UIColor *textColour;
	
	float lapProgress;
	NSString *name;
	NSString *team;
	bool moving;
	bool pitted;
	bool stopped;
	
	int row;
}

@property (nonatomic) int row;

@property (readonly) NSString * name;
@property (readonly) NSString * team;
@property (readonly) float lapProgress;
@property (readonly) bool moving;
@property (readonly) bool pitted;
@property (readonly) bool stopped;

- (id) init;

- (void) load : (DataStream *) stream Colours: (UIColor **)colours ColoursCount:(int)coloursCount;
- (void) draw:(TrackProfileView *)view OnMap:(TrackProfile *)trackProfile Offset:(float)offset ImageList:(ImageList *)imageList;

@end


@interface TrackTurn : NSObject
{
	
	float distance;
	NSString *name;
}

@property (readonly) float distance;
@property (readonly) NSString * name;

- (void) load : (DataStream *) stream;

@end

@interface TrackProfile : NSObject
{
	
	float trackLength;
	float s1Length;
	float s2Length;
	float sc1Length;
	float sc2Length;
	float pitStopLoss;
	float pitStopLossMargin;
	float pitStopLossSC;
	
	NSMutableArray *cars;
	NSMutableArray *turns;
	UIColor **colours;
	int coloursCount;
	
	int carCount;
}

@property (nonatomic) float trackLength;
@property (nonatomic) float s1Length;
@property (nonatomic) float s2Length;
@property (nonatomic) float sc1Length;
@property (nonatomic) float sc2Length;

- (void) loadTrack : (DataStream *) stream;
- (void) updateCars : (DataStream *) stream;

- (void) drawInView:(TrackProfileView *)view;

@end
