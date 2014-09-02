//
//  TrackMap.h
//  RacePad
//
//  Created by Mark Riches on 12/10/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataStream;
@class OutputStream;
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
	TM_TRACK_SEGMENT_BLUE,
	TM_TRACK_SEGMENT_SLIPPERY,
	TM_TRACK_PANEL_NONE,
	TM_TRACK_DOUBLE_YELLOW,
};

@interface TrackCar : NSObject
{
	UIColor *pointColour;
	UIColor *fillColour;
	UIColor *lineColour;
	UIColor *textColour;
	
    int number;
	float x, y, lapProgress;
	int dotSize;
	NSString *name;
	NSString *team;
	bool moving;
	bool pitted;
	bool stopped;
	
	int row;
}

@property (nonatomic, retain) NSString * name;
@property (readonly) NSString * team;
@property (nonatomic) float x;
@property (nonatomic) float y;
@property (nonatomic) int number;
@property (readonly) float lapProgress;
@property (nonatomic) bool moving;
@property (nonatomic) bool pitted;
@property (nonatomic) bool stopped;

@property (nonatomic) int row;

- (id) init;

- (void) load : (DataStream *) stream Colours: (UIColor **)colours ColoursCount:(int)coloursCount;
- (void) draw:(TrackMapView *)view OnMap:(TrackMap *)trackMap Scale:(float)scale;
- (void) drawProfile:(TrackProfileView *)view Offset:(float)offset ImageList:(ImageList *)imageList;
- (void) setup: (unsigned char)type Colours:(UIColor **)colours ColoursCount:(int)coloursCount;

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

- (void) loadShape : (DataStream *) stream Save:(OutputStream *)saveFile;
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

- (void) loadShape : (DataStream *) stream Count: (int) count Save:(OutputStream *)saveFile;

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

- (void) loadShape : (DataStream *) stream Count: (int) count Save:(OutputStream *)saveFile;
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

- (void) load : (DataStream *) stream Save:(OutputStream *)saveFile;

@end

@interface DistanceMap : NSObject
{
    int length;
    float *x;
    float *y;
}

- (void) load : (DataStream *) stream Save:(OutputStream *)saveFile;

@end

@interface TLA : NSObject
{
    int car;
    NSString *name;
}

@property (nonatomic) int car;
@property (nonatomic, retain) NSString * name;

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
    
    DistanceMap *distanceMap;
    NSMutableArray *tlaMap;
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

- (void) loadTrack : (DataStream *) stream Save:(bool)save;
- (void) loadDistanceMap : (DataStream *) stream Save:(bool)save;
- (void) loadTLAMap : (DataStream *) stream Save:(bool)save;
- (void) updateCars : (DataStream *) stream;
- (void) updateCarFromDistance : (int)number S:(int)distance Pit:(bool) pit Type:(unsigned char)type;
- (void) clearCars;

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
