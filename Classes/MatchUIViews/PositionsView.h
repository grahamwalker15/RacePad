//
//  PitchView.h
//  RacePad
//
//  Created by Gareth Griffith on 10/12/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DrawingView.h"

@interface PositionsView : DrawingView
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
	
	bool autoRotate;
	
	bool isAnimating;
	float animationScaleTarget;
	float animationAlpha;
	int animationDirection;
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

@property (nonatomic) bool autoRotate;

- (void)InitialiseMembers;
- (void)InitialiseImages;
- (float)interpolatedUserScale;

@end

