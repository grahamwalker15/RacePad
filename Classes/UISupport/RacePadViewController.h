//
//  RacePadViewController.h
//  RacePad
//
//  Created by Gareth Griffith on 10/29/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

// Virtual class to ensure that all of our view controllers have certain methods

@interface RacePadViewController : UIViewController
{
	// Gesture recognizer state stores
	float lastGestureScale;
	float lastGestureAngle;
	float lastGesturePanX;
	float lastGesturePanY;
	
	NSTimer *doubleTapTimer;
	CGPoint tapPoint;
}

- (UIView *) baseView;

// Virtual method to be overwritten in order to update any title bars etc.
- (void) RequestRedrawForType:(int)type;


// Gesture recognizer creation

-(void) addTapRecognizerToView:(UIView *)view;
-(void) addDoubleTapRecognizerToView:(UIView *)view;
-(void) addLongPressRecognizerToView:(UIView *)view;
-(void) addPinchRecognizerToView:(UIView *)view;
-(void) addRotationRecognizerToView:(UIView *)view;
-(void) addRightSwipeRecognizerToView:(UIView *)view;
-(void) addLeftSwipeRecognizerToView:(UIView *)view;
-(void) addPanRecognizerToView:(UIView *)view;

// Gesture recognizer callbacks

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
