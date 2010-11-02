//
//  DrawingViewController.m
//  RacePad
//
//  Created by Gareth Griffith on 10/12/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "DrawingViewController.h"

@implementation DrawingViewController

@synthesize drawingView;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	// Make the view aware of orientation changes.
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OrientationChange:) name:@"UIDeviceOrientationDidChangeNotification"  object:nil];
	
    //	Create and configure the gesture recognizers. Add each to the controlled view as a gesture recognizer.

    UIGestureRecognizer *recognizer;
    
    //	Tap recognizer
	recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(HandleTapFrom:)];
	[recognizer setCancelsTouchesInView:false];
    [self.view addGestureRecognizer:recognizer];
    [recognizer release];
	
    //	Double Tap recognizer
	recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(HandleDoubleTapFrom:)];
	[(UITapGestureRecognizer *)recognizer setNumberOfTapsRequired:2];
    [self.view addGestureRecognizer:recognizer];
    [recognizer release];
	
    //	Long press recognizer
	recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(HandleLongPressFrom:)];
 	[recognizer setCancelsTouchesInView:false];
	[self.view addGestureRecognizer:recognizer];
    [recognizer release];
	
	/* Take other recognizers out for the moment - they interfere with scrolling
	 
    //	Pinch recognizer
	recognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(HandlePinchFrom:)];
    [self.view addGestureRecognizer:recognizer];
    [recognizer release];
	
    //	Rotation recognizer
	recognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(HandleRotationFrom:)];
    [self.view addGestureRecognizer:recognizer];
    [recognizer release];
	
    //	Right Swipe recognizer
	recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(HandleRightSwipeFrom:)];
    [self.view addGestureRecognizer:recognizer];
    [recognizer release];
	
    //	Left Swipe recognizer
	recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(HandleLeftSwipeFrom:)];
	[(UISwipeGestureRecognizer *)recognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:recognizer];
    [recognizer release];
	
    //	Pan recognizer
	recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(HandlePanFrom:)];
    [self.view addGestureRecognizer:recognizer];
    [recognizer release];
	 
	 */
	
	[super viewDidLoad];
}

- (void)dealloc
{
    [super dealloc];
}

// orientation view swapping logic
- (void) OrientationChange:(NSNotification *)notification
{
	[self.view setNeedsLayout];
	[self.view setNeedsDisplay];
}

// Gesture recognizer callbacks

- (void)HandleTapFrom:(UIGestureRecognizer *)gestureRecognizer
{
	CGPoint parent_point = [gestureRecognizer locationInView:self.view];
	
	// For tap events in windows with subviews, we will ignore the gesture so that the event can be passed on to the subview
	UIView * hit_view = [self.view hitTest:parent_point withEvent:nil];
	
	if(hit_view == self.drawingView)
	{
		CGPoint point = [gestureRecognizer locationInView:self.drawingView];
		[self OnGestureTapAtX:point.x Y:point.y];
	}
}

- (void)HandleDoubleTapFrom:(UIGestureRecognizer *)gestureRecognizer
{
	CGPoint parent_point = [gestureRecognizer locationInView:self.view];
	
	// For tap events in windows with subviews, we will ignore the gesture so that the event can be passed on to the subview
	UIView * hit_view = [self.view hitTest:parent_point withEvent:nil];
	
	if(hit_view == self.drawingView)
	{
		CGPoint point = [gestureRecognizer locationInView:self.drawingView];
		[self OnGestureDoubleTapAtX:point.x Y:point.y];
	}
}

- (void)HandleLongPressFrom:(UIGestureRecognizer *)gestureRecognizer
{
	CGPoint parent_point = [gestureRecognizer locationInView:self.view];
	
	// For tap events in windows with subviews, we will ignore the gesture so that the event can be passed on to the subview
	UIView * hit_view = [self.view hitTest:parent_point withEvent:nil];
	
	if(hit_view == self.drawingView)
	{
		CGPoint point = [gestureRecognizer locationInView:self.drawingView];
		[self OnGestureLongPressAtX:point.x Y:point.y];
	}
}

- (void)HandlePinchFrom:(UIGestureRecognizer *)gestureRecognizer
{
	CGPoint point = [gestureRecognizer locationInView:self.drawingView];
	float scale = [(UIPinchGestureRecognizer *)gestureRecognizer scale];
	float speed = [(UIPinchGestureRecognizer *)gestureRecognizer velocity];
	[self OnGesturePinchAtX:point.x Y:point.y Scale:scale Speed:speed];
}

- (void)HandleRotationFrom:(UIGestureRecognizer *)gestureRecognizer
{
	CGPoint point = [gestureRecognizer locationInView:self.drawingView];
	float angle = [(UIRotationGestureRecognizer *)gestureRecognizer rotation];
	float speed = [(UIRotationGestureRecognizer *)gestureRecognizer velocity];
	[self OnGestureRotationAtX:point.x Y:point.y Angle:angle Speed:speed];
}

- (void)HandleRightSwipeFrom:(UIGestureRecognizer *)gestureRecognizer
{
	[self OnGestureRightSwipe];
}

- (void)HandleLeftSwipeFrom:(UIGestureRecognizer *)gestureRecognizer
{
	[self OnGestureLeftSwipe];
}

- (void)HandlePanFrom:(UIGestureRecognizer *)gestureRecognizer
{
	CGPoint pan = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:self.drawingView];
	CGPoint speed = [(UIPanGestureRecognizer *)gestureRecognizer velocityInView:self.drawingView];
	[self OnGesturePanByX:pan.x Y:pan.y SpeedX:speed.x SpeedY:speed.y];
}

// Action callbacks - these should be overridden if you want any action

- (void) OnGestureTapAtX:(float)x Y:(float)y
{
}

- (void) OnGestureDoubleTapAtX:(float)x Y:(float)y
{
}

- (void) OnGestureLongPressAtX:(float)x Y:(float)y
{
}

- (void) OnGesturePinchAtX:(float)x Y:(float)y Scale:(float)scale Speed:(float)speed
{
}

- (void) OnGestureRotationAtX:(float)x Y:(float)y Angle:(float)angle Speed:(float)speed
{
}

- (void) OnGestureRightSwipe
{
}

- (void) OnGestureLeftSwipe
{
}

- (void) OnGesturePanByX:(float)x Y:(float)y SpeedX:(float)speedx SpeedY:(float)speedy
{
}

@end
