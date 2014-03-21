//
//  RacePadViewController.h
//  RacePad
//
//  Created by Gareth Griffith on 10/29/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

#import "HelpViewController.h"

// Virtual class to ensure that all of our view controllers have certain methods

@interface BasePadTimeController : NSObject <UIGestureRecognizerDelegate>
{
	bool displayed;
}

@property(nonatomic) bool displayed;

+(BasePadTimeController *)Instance;

- (void) displayInViewController:(UIViewController *)viewController Animated:(bool)animated;
- (void) hide;

@end


// Declare our own drag drop gesture recognizer
@interface UIDragDropGestureRecognizer : UIPanGestureRecognizer
{
	CGPoint downPoint;
}

@property (readonly) CGPoint downPoint;

@end

// Declare our own jog control gesture recognizer
@interface UIJogGestureRecognizer : UIPanGestureRecognizer
{
	CGPoint downPoint;
	bool initialised;
	float lastAngle;
	int direction;
}

@property (readonly) CGPoint downPoint;
@property (nonatomic) bool initialised;
@property (nonatomic) float lastAngle;
@property (nonatomic) int direction;

- (float)angleOfPoint:(CGPoint)point InView:(UIView *)gestureView;

@end

// The view controller base

@interface RacePadViewController : UIViewController
{
	// Gesture recognizer state stores
	float lastGestureScale;
	float lastGestureAngle;
	float lastGesturePanX;
	float lastGesturePanY;
	
	NSTimer *doubleTapTimer;
	CGPoint tapPoint;
	UIView * tapView;
	
	HelpViewController * helpController;
}

// Virtual method to be overwritten to set the help view to be used for this view controller
- (HelpViewController *) helpController;

// Virtual method to be overwritten if you want any other options to appear with time controller
- (UIView *) timeControllerAddOnOptionsView;

//Virtual method - defaults YES, override if you don't want them
- (BOOL) wantTimeControls;

// Virtual method to be overwritten in order to update any title bars etc.
- (void) RequestRedrawForType:(int)type;

// View display configuration
-(void) addDropShadowToView:(UIView *)view WithOffsetX:(float)x Y:(float)y Blur:(float)blur;

// Gesture recognizer creation

-(void) addTapRecognizerToView:(UIView *)view;
-(void) addDoubleTapRecognizerToView:(UIView *)view;
-(void) addLongPressRecognizerToView:(UIView *)view;
-(void) addPinchRecognizerToView:(UIView *)view;
-(void) addRotationRecognizerToView:(UIView *)view;
-(void) addRightSwipeRecognizerToView:(UIView *)view;
-(void) addLeftSwipeRecognizerToView:(UIView *)view;
-(void) addPanRecognizerToView:(UIView *)view;
-(void) addDragRecognizerToView:(UIView *)view WithTarget:(UIView *)targetView;
-(void) addJogRecognizerToView:(UIView *)view;

// Gesture recognizer callbacks

- (void)HandleTapFrom:(UIGestureRecognizer *)gestureRecognizer;
- (void)HandleDoubleTapFrom:(UIGestureRecognizer *)gestureRecognizer;
- (void)HandleLongPressFrom:(UIGestureRecognizer *)gestureRecognizer;
- (void)HandlePinchFrom:(UIGestureRecognizer *)gestureRecognizer;
- (void)HandleRotationFrom:(UIGestureRecognizer *)gestureRecognizer;
- (void)HandleRightSwipeFrom:(UIGestureRecognizer *)gestureRecognizer;
- (void)HandleLeftSwipeFrom:(UIGestureRecognizer *)gestureRecognizer;
- (void)HandlePanFrom:(UIGestureRecognizer *)gestureRecognizer;
- (void)HandleDragFrom:(UIGestureRecognizer *)gestureRecognizer; // Works only on UITableViews
- (void)HandleJogFrom:(UIGestureRecognizer *)gestureRecognizer; // Works only on JogControlViews

// Action callbacks

- (void) OnTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y;
- (void) OnDoubleTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y;
- (void) OnLongPressGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y;
- (void) OnPinchGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y Scale:(float)scale Speed:(float)speed;
- (void) OnRotationGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y Angle:(float)angle Speed:(float)speed;
- (void) OnRightSwipeGestureInView:(UIView *)gestureView;
- (void) OnLeftSwipeGestureInView:(UIView *)gestureView;
- (void) OnPanGestureInView:(UIView *)gestureView ByX:(float)x Y:(float)y SpeedX:(float)speed_x SpeedY:(float)speed_y State:(int)state;
- (void) OnDragGestureInView:(UIView *)gestureView ByX:(float)x Y:(float)y SpeedX:(float)speed_x SpeedY:(float)speed_y State:(int)state Recognizer:(UIDragDropGestureRecognizer *)recognizer;
- (void) OnJogGestureInView:(UIView *)gestureView AngleChange:(float)angle State:(int)state;

- (void) handleTimeControllerGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y;

@end


