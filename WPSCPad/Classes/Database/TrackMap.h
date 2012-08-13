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
@class TrackMap;
@class TrackProfileView;
@class ImageList;

enum TrackMapLineType {
	TM_L_INKNOWN,
	TM_L_MARSHALL_POST,
	TM_L_TURN_NUMBER,
	TM_L_SC_LINE,
	TM_L_PIT_LINE,
	TM_L_TIMING_LINE
};

enum TrackState {
	TM_TRACK_GREEN,
	TM_TRACK_YELLOW,
	TM_TRACK_SC,
	TM_TRACK_SCSTBY,
	TM_TRACK_SCIN,
	TM_TRACK_RED,
	TM_TRACK_GRID,
	TM_TRACK_CHEQUERED,
};

@interface TrackCar : NSObject
{
	UIColor *pointColour;
	UIColor *fillColour;
	UIColor *lineColour;
	UIColor *textColour;
	
	float x, y, lapProgress;
	int dotSize;
	NSString *name;
	NSString *team;
	bool moving;
	bool pitted;
	bool stopped;
	
	int row;
}

@property (readonly) NSString * name;
@property (readonly) NSString * team;
@property (readonly) float x;
@property (readonly) float y;
@property (readonly) float lapProgress;
@property (readonly) bool moving;
@property (readonly) bool pitted;
@property (readonly) bool stopped;

@property (nonatomic) int row;

- (id) init;

- (void) load : (DataStream *) stream Colours: (UIColor **)colours ColoursCount:(int)coloursCount;
- (void) draw:(TrackMapView *)view OnMap:(TrackMap *)trackMap Scale:(float)scale;
- (void) drawProfile:(TrackProfileView *)view Offset:(float)offset ImageList:(ImageList *)imageList;

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
	int count;
	float *x;
	float *y;

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
- (float) directionAtPoint:(float)xp Y:(float)yp;

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
- (void) getLabelPoint : (TrackMapView *)view Scale: (float) scale X:(float *)x Y:(float *)y;

@end

@interface SegmentState : NSObject
{
	int index;
	unsigned char state;
}

@property (readonly) int index;
@property (readonly) unsigned char state;

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

@interface TrackMap : NSObject
{
	
	TrackShape *inner;
	TrackShape *outer;
	
	float xCentre;
	float yCentre;
	
	float width;
	float height;
	
	float trackLength;
	float s1Length;
	float s2Length;
	float sc1Length;
	float sc2Length;
	
	float trackProfileLength;
	float s1ProfileLength;
	float s2ProfileLength;
	float sc1ProfileLength;
	float sc2ProfileLength;
	float pitStopLoss;
	float pitStopLossMargin;
	float pitStopLossSC;

	NSMutableArray *lines;
	NSMutableArray *labels;

	NSMutableArray *cars;
	NSMutableArray *turns;
	UIColor **colours;
	int coloursCount;
	
	int carCount;
	
	NSMutableArray *segmentStates;
	int overallTrackState;
}

@property (nonatomic) float trackLength;
@property (nonatomic) float s1Length;
@property (nonatomic) float s2Length;
@property (nonatomic) float sc1Length;
@property (nonatomic) float sc2Length;

@property (nonatomic) float trackProfileLength;
@property (nonatomic) float s1ProfileLength;
@property (nonatomic) float s2ProfileLength;
@property (nonatomic) float sc1ProfileLength;
@property (nonatomic) float sc2ProfileLength;

- (void) loadTrack : (DataStream *) stream;
- (void) updateCars : (DataStream *) stream;

- (bool) carExistsByName:(NSString *)name;
- (NSString *) nearestCarInView:(UIView *)view ToX:(float)x Y:(float)y;

- (void) drawInView:(TrackMapView *)view;
- (void) drawInProfileView:(TrackProfileView *)view;

- (void) constructTransformMatrixForView:(TrackMapView *)view;
- (void) constructTransformMatrixForView:(TrackMapView *)view WithCentreX:(float)x Y:(float)y Rotation:(float) rotation;
- (void) adjustScaleInView:(TrackMapView *)view Scale:(float)scale X:(float)x Y:(float)y;
- (void) adjustPanInView:(TrackMapView *)view X:(float)x Y:(float)y;

- (int) getTrackState;

- (CGPoint) getCarPositionByLabel: (NSString *) name;
- (float) directionAtPoint:(float)xp Y:(float)yp;

@end
