//
//  SurveyView.h
//  TrackSurvey
//
//  Created by Mark Riches 2/5/2011.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DrawingView.h"

@interface SurveyPoint : NSObject
{
	double lat, lng;
}

@property double lat;
@property double lng;

@end


@interface SurveyView : DrawingView
{
	float homeXOffset;
	float homeYOffset;	
	float homeScaleX;
	float homeScaleY;
	
	float userXOffset;
	float userYOffset;	
	float userScale;
	
	bool autoRotate;
	
	bool isAnimating;
	float animationScaleTarget;
	float animationAlpha;
	int animationDirection;
	
	float x_scale_, y_scale_, x_offset_, y_offset_;
	
	double surveyX0;
	double surveyY0;
	
	NSString *text;
	
	NSMutableArray *points;
}

@property (nonatomic) float homeXOffset;
@property (nonatomic) float homeYOffset;
@property (nonatomic) float homeScaleX;
@property (nonatomic) float homeScaleY;

@property (nonatomic) float userXOffset;
@property (nonatomic) float userYOffset;
@property (nonatomic) float userScale;

@property (nonatomic) bool isAnimating;
@property (nonatomic) float animationScaleTarget;
@property (nonatomic) float animationAlpha;
@property (nonatomic) int animationDirection;

@property (nonatomic) bool autoRotate;

@property (nonatomic,retain) NSString *text;

- (void)InitialiseMembers;
- (void)InitialiseImages;
- (float)interpolatedUserScale;

- (void) transformPoint: (double) x Y: (double) y X0: (float *) x0 Y0: (float *) y0;
- (void) unTransformPoint: (int) x Y: (int) y X0: (float *) x0 Y0: (float *) y0;

- (void) addPoint:(double)lng Lat:(double)lat;
- (void) saveSurvey;
- (void) startSurvey;

@end

