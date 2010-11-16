    //
//  RacePadViewController.m
//  RacePad
//
//  Created by Gareth Griffith on 10/29/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "RacePadViewController.h"


@implementation RacePadViewController

- (void)viewDidLoad
{
	//	Create and configure the gesture recognizers. Add each to the controlled view as a gesture recognizer.
	
	doubleTapTimer = nil;
	
 	lastGestureScale = 1.0;
	lastGestureAngle = 0.0;
	lastGesturePanX = 0.0;
	lastGesturePanY = 0.0;

    [super viewDidLoad];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
}


- (void)dealloc
{
    [super dealloc];
}

- (UIView *) baseView
{
	return [self view];
}

- (void) RequestRedrawForType:(int)type
{
}


// Gesture recognizers

-(void) addTapRecognizerToView:(UIView *)view
{
	// Tap recognizer
	UITapGestureRecognizer * recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(HandleTapFrom:)];
	[recognizer setCancelsTouchesInView:false];
	[view addGestureRecognizer:recognizer];
	[recognizer release];
}

-(void) addDoubleTapRecognizerToView:(UIView *)view
{
	// Double Tap recognizer
	UITapGestureRecognizer * recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(HandleDoubleTapFrom:)];
	[(UITapGestureRecognizer *)recognizer setNumberOfTapsRequired:2];
	[view addGestureRecognizer:recognizer];
	[recognizer release];
}

-(void) addLongPressRecognizerToView:(UIView *)view
{	
	// Long press recognizer
	UILongPressGestureRecognizer * recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(HandleLongPressFrom:)];
	[recognizer setCancelsTouchesInView:false];
	[view addGestureRecognizer:recognizer];
	[recognizer release];
}

-(void) addPinchRecognizerToView:(UIView *)view
{
	// Pinch recognizer
	UIPinchGestureRecognizer * recognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(HandlePinchFrom:)];
	[view addGestureRecognizer:recognizer];
	[recognizer release];
}

-(void) addRotationRecognizerToView:(UIView *)view
{	
	// Rotation recognizer
	UIRotationGestureRecognizer * recognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(HandleRotationFrom:)];
	[view addGestureRecognizer:recognizer];
	[recognizer release];
}

-(void) addRightSwipeRecognizerToView:(UIView *)view
{	
	// Right Swipe recognizer
	UISwipeGestureRecognizer * recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(HandleRightSwipeFrom:)];
	[view addGestureRecognizer:recognizer];
	[recognizer release];
}

-(void) addLeftSwipeRecognizerToView:(UIView *)view
{
	// Left Swipe recognizer
	UISwipeGestureRecognizer * recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(HandleLeftSwipeFrom:)];
	[(UISwipeGestureRecognizer *)recognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
	[view addGestureRecognizer:recognizer];
	[recognizer release];
}

-(void) addPanRecognizerToView:(UIView *)view
{	
	//	Pan recognizer
	UIPanGestureRecognizer * recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(HandlePanFrom:)];
	[view addGestureRecognizer:recognizer];
	[recognizer release];
}

// Gesture recognizer callbacks

- (void)HandleTapFrom:(UIGestureRecognizer *)gestureRecognizer
{
	UIView * gestureView = [gestureRecognizer view];
	tapPoint = [gestureRecognizer locationInView:gestureView];
	tapView = gestureView;
	doubleTapTimer = [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(doubleTapTimerExpired:) userInfo:nil repeats:NO];
}

- (void)HandleDoubleTapFrom:(UIGestureRecognizer *)gestureRecognizer
{
	if(doubleTapTimer)
	{
		[doubleTapTimer invalidate];
		doubleTapTimer = nil;
	}
	
	UIView * gestureView = [gestureRecognizer view];
	CGPoint point = [gestureRecognizer locationInView:gestureView];
	[self OnDoubleTapGestureInView:gestureView AtX:point.x Y:point.y];
}

- (void) doubleTapTimerExpired: (NSTimer *)theTimer
{
	[self OnTapGestureInView:tapView AtX:tapPoint.x Y:tapPoint.y];
	doubleTapTimer = nil;
}

- (void)HandleLongPressFrom:(UIGestureRecognizer *)gestureRecognizer
{
	// Don't rspond to end state
	if([gestureRecognizer state] == UIGestureRecognizerStateEnded)
		return;
	
	UIView * gestureView = [gestureRecognizer view];
	CGPoint point = [gestureRecognizer locationInView:gestureView];
	[self OnLongPressGestureInView:gestureView AtX:point.x Y:point.y];
}

- (void)HandlePinchFrom:(UIGestureRecognizer *)gestureRecognizer
{
	if([(UIPinchGestureRecognizer *)gestureRecognizer state] == UIGestureRecognizerStateEnded)
	{
		lastGestureScale = 1.0;
		return;
	}
	
	UIView * gestureView = [gestureRecognizer view];
	CGPoint point = [gestureRecognizer locationInView:gestureView];
	float scale = [(UIPinchGestureRecognizer *)gestureRecognizer scale];
	float speed = [(UIPinchGestureRecognizer *)gestureRecognizer velocity];
	
	if(lastGestureScale > 0.0)
	{
		float thisGestureScale = scale;
		scale = scale / lastGestureScale;
		[self OnPinchGestureInView:gestureView AtX:point.x Y:point.y Scale:scale Speed:speed];
		lastGestureScale = thisGestureScale;
	}
}

- (void)HandleRotationFrom:(UIGestureRecognizer *)gestureRecognizer
{
	if([(UIRotationGestureRecognizer *)gestureRecognizer state] == UIGestureRecognizerStateEnded)
	{
		lastGestureAngle = 0.0;
		return;
	}
	
	UIView * gestureView = [gestureRecognizer view];
	CGPoint point = [gestureRecognizer locationInView:gestureView];
	float angle = [(UIRotationGestureRecognizer *)gestureRecognizer rotation];
	float speed = [(UIRotationGestureRecognizer *)gestureRecognizer velocity];
	
	float thisGestureAngle = angle;
	angle -= lastGestureAngle;
	[self OnRotationGestureInView:gestureView AtX:point.x Y:point.y Angle:angle Speed:speed];
	lastGestureAngle = thisGestureAngle;
}

- (void)HandleRightSwipeFrom:(UIGestureRecognizer *)gestureRecognizer
{
	UIView * gestureView = [gestureRecognizer view];
	[self OnRightSwipeGestureInView:gestureView];
}

- (void)HandleLeftSwipeFrom:(UIGestureRecognizer *)gestureRecognizer
{
	UIView * gestureView = [gestureRecognizer view];
	[self OnLeftSwipeGestureInView:gestureView];
}

- (void)HandlePanFrom:(UIGestureRecognizer *)gestureRecognizer
{
	if([(UIPanGestureRecognizer *)gestureRecognizer state] == UIGestureRecognizerStateEnded)
	{
		lastGesturePanX = 0.0;
		lastGesturePanY = 0.0;
		return;
	}
	
	UIView * gestureView = [gestureRecognizer view];
	CGPoint pan = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:gestureView];
	CGPoint speed = [(UIPanGestureRecognizer *)gestureRecognizer velocityInView:gestureView];
	
	float thisGesturePanX = pan.x;
	float thisGesturePanY = pan.y;
	pan.x = pan.x - lastGesturePanX;
	pan.y = pan.y - lastGesturePanY;
	[self OnPanGestureInView:gestureView ByX:pan.x Y:pan.y SpeedX:speed.x SpeedY:speed.y];
	lastGesturePanX = thisGesturePanX;
	lastGesturePanY = thisGesturePanY;
}

// Action callbacks - these should be overridden if you want any action

- (void) OnTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
}

- (void) OnDoubleTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
}

- (void) OnLongPressGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
}

- (void) OnPinchGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y Scale:(float)scale Speed:(float)speed
{
}

- (void) OnRotationGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y Angle:(float)angle Speed:(float)speed
{
}

- (void) OnRightSwipeGestureInView:(UIView *)gestureView
{
}

- (void) OnLeftSwipeGestureInView:(UIView *)gestureView
{
}

- (void) OnPanGestureInView:(UIView *)gestureView ByX:(float)x Y:(float)y SpeedX:(float)speedx SpeedY:(float)speedy
{
}

@end
