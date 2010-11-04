//
//  DrawingViewController.h
//  RacePad
//
//  Created by Gareth Griffith on 10/12/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RacePadViewController.h"
#import "DrawingView.h"

@interface DrawingViewController : RacePadViewController
{
	IBOutlet DrawingView * drawingView;
	
	// Gesture recognizer state stores
	float lastGestureScale;
	float lastGestureAngle;
	float lastGesturePanX;
	float lastGesturePanY;
	
	NSTimer *doubleTapTimer;
	CGPoint tapPoint;
}

@property (readonly) DrawingView * drawingView;

// Gesture recognizer callbacks

- (void) OrientationChange:(NSNotification *)notification;

- (void)HandleTapFrom:(UIGestureRecognizer *)gestureRecognizer;
- (void)HandleDoubleTapFrom:(UIGestureRecognizer *)gestureRecognizer;
- (void)HandleLongPressFrom:(UIGestureRecognizer *)gestureRecognizer;
- (void)HandlePinchFrom:(UIGestureRecognizer *)gestureRecognizer;
- (void)HandleRotationFrom:(UIGestureRecognizer *)gestureRecognizer;
- (void)HandleRightSwipeFrom:(UIGestureRecognizer *)gestureRecognizer;
- (void)HandleLeftSwipeFrom:(UIGestureRecognizer *)gestureRecognizer;
- (void)HandlePanFrom:(UIGestureRecognizer *)gestureRecognizer;

// Action callbacks

- (void) OnGestureTapAtX:(float)x Y:(float)y;
- (void) OnGestureDoubleTapAtX:(float)x Y:(float)y;
- (void) OnGestureLongPressAtX:(float)x Y:(float)y;
- (void) OnGesturePinchAtX:(float)x Y:(float)y Scale:(float)scale Speed:(float)speed;
- (void) OnGestureRotationAtX:(float)x Y:(float)y Angle:(float)angle Speed:(float)speed;
- (void) OnGestureRightSwipe;
- (void) OnGestureLeftSwipe;
- (void) OnGesturePanByX:(float)x Y:(float)y SpeedX:(float)speed_x SpeedY:(float)speed_y;

@end
