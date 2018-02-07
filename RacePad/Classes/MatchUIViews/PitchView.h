//
//  PitchView.h
//  RacePad
//
//  Created by Gareth Griffith on 10/12/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DrawingView.h"

@interface PitchView : DrawingView
{
	bool isZoomView;
	bool isOverlayView;
	bool smallSized;
	
	float homeXOffset;
	float homeYOffset;	
	float homeScaleX;
	float homeScaleY;
	
	float userXOffset;
	float userYOffset;	
	float userScale;
	
	NSString * playerToFollow;
	bool autoRotate;
	
	bool isAnimating;
	float animationScaleTarget;
	float animationAlpha;
	int animationDirection;
	
	bool showWholeMove;

	UIColor *pitchColour;
	float a13, a23, a11, a21, a31, a12, a22, a32;
	
	bool pitchBackground, playerTrails, playerPos, passes, passNames, ballTrail;
}

@property (nonatomic) bool isZoomView;
@property (nonatomic) bool isOverlayView;
@property (nonatomic) bool smallSized;

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

@property (nonatomic, retain) NSString * playerToFollow;
@property (nonatomic) bool autoRotate;

@property (nonatomic) bool showWholeMove;
@property (nonatomic) bool pitchBackground;
@property (nonatomic) bool playerTrails;
@property (nonatomic) bool playerPos;
@property (nonatomic) bool passes;
@property (nonatomic) bool passNames;
@property (nonatomic) bool ballTrail;

- (void)InitialiseMembers;
- (void)InitialiseImages;
- (void)followPlayer:(NSString *)name;
- (float)interpolatedUserScale;

- (void) initialisePerspective;

- (void) transformPoint:(float *)x Y:(float *)y;
- (void) viewLine: (float)x0 Y0:(float) y0 X1:(float)x1 Y1:(float) y1;
- (void) viewSpot: (float)x0 Y0:(float) y0 LineScale:(float) lineScale;

- (void) constructTransformMatrix;
- (void) constructTransformMatrix:(float)x Y:(float)y Rotation:(float) rotation;
- (void) adjustScale:(float)scale X:(float)x Y:(float)y;
- (void) adjustPan:(float)x Y:(float)y;

@end

