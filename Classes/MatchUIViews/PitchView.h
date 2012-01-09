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

- (void)InitialiseMembers;
- (void)InitialiseImages;
- (void)followPlayer:(NSString *)name;
- (float)interpolatedUserScale;

@end

