//
//  BasePadViewController.m
//  BasePad
//
//  Created by Gareth Griffith on 10/29/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "BasePadViewController.h"
#import "DrawingView.h"
#import "JogViewController.h"
#import "QuartzCore/QuartzCore.h"


@implementation BasePadViewController

static id timeControllerInstance = nil;

+ (void) specifyTimeControllerInstance:(id)instance
{
	timeControllerInstance = instance;
}

+ (id) timeControllerInstance
{
	return timeControllerInstance;
}

+ (bool) timeControllerDisplayed
{
	if ( timeControllerInstance && [timeControllerInstance conformsToProtocol:@protocol(TimeControllerInstance)] )
	{
		return [timeControllerInstance timeControllerDisplayed];
	}
	
	return false;
}

- (void) notifyHidingTimeControls
{
}

//////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)viewDidLoad
{
    [super viewDidLoad];

	//	Create and configure the gesture recognizers. Add each to the controlled view as a gesture recognizer.
	
	doubleTapTimer = nil;
	doubleTapEnabled = false;
	
 	lastGestureScale = 1.0;
	lastGestureAngle = 0.0;
	lastGesturePanX = 0.0;
	lastGesturePanY = 0.0;
	
	helpController = nil;
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
	if(helpController)
		[helpController release];
	
	helpController = nil;

    [super viewDidUnload];
}


- (void)dealloc
{
    [super dealloc];
}

- (HelpViewController *) helpController
{
	/*
	if(!helpController)
		helpController = [[HelpViewController alloc] initWithNibName:@"DefaultHelpView" bundle:nil];
	*/
	
	return helpController;
}

- (UIView *) timeControllerAddOnOptionsView
{
	return nil;
}

- (BOOL) wantTimeControls
{
	return YES;
}

- (void) notifyChangeToLiveMode
{
}

- (void) RequestRedraw
{
}

- (void) RequestRedrawForType:(int)type
{
}

- (void) RequestRedrawForUpdate
{
	[self RequestRedraw];
}

// View display configuration
-(void) addDropShadowToView:(UIView *)view WithOffsetX:(float)x Y:(float)y Blur:(float)blur
{
	if(view)
	{
		view.layer.shadowColor = [UIColor blackColor].CGColor;
		view.layer.shadowOpacity = 1.0;
		view.layer.shadowRadius = blur;
		view.layer.shadowOffset = CGSizeMake(x, y);
		view.clipsToBounds = false;
	}	
}

-(UIImage *) renderViewToImage:(UIView *)view
{
    UIGraphicsBeginImageContext(view.bounds.size);
    
	// Get a context
    CGContextRef ctx = UIGraphicsGetCurrentContext();
	
    // Clear whole thing
    CGContextClearRect(ctx, view.bounds);
	
	// Draw view into context
    [view.layer renderInContext:ctx];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
	
    return newImage;
}


// Time controller display

- (void) toggleTimeControllerDisplay
{
	if ( timeControllerInstance && [timeControllerInstance conformsToProtocol:@protocol(TimeControllerInstance)] )
	{
		if(![timeControllerInstance timeControllerDisplayed])
		{
			[timeControllerInstance displayTimeControllerInViewController:self Animated:true];
		}
		else
		{
			[timeControllerInstance hideTimeController];
		}
	}
}

// Gesture recognizers

-(void) addTapRecognizerToView:(UIView *)view
{
	// Tap recognizer
	UITapGestureRecognizer * recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(HandleTapFrom:)];
	[recognizer setCancelsTouchesInView:false];
	[recognizer setDelegate:self];
	[view addGestureRecognizer:recognizer];
	[recognizer release];
}

-(void) addDoubleTapRecognizerToView:(UIView *)view
{
	// Double Tap recognizer
	UITapGestureRecognizer * recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(HandleDoubleTapFrom:)];
	[(UITapGestureRecognizer *)recognizer setNumberOfTapsRequired:2];
	
	// And finally add the recognizer and release it
	[view addGestureRecognizer:recognizer];
	[recognizer release];
	
	doubleTapEnabled = true;
	
	if([view isKindOfClass:[DrawingView class]])
		[(DrawingView *)view SetDoubleTapEnabled:true];
}

-(void) addLongPressRecognizerToView:(UIView *)view
{	
	// Long press recognizer
	UILongPressGestureRecognizer * recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(HandleLongPressFrom:)];
	[recognizer setCancelsTouchesInView:false];
	[recognizer setDelegate:self];
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
	// Right Swipe recognizer - two fingers
	UISwipeGestureRecognizer * recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(HandleRightSwipeFrom:)];
	[(UISwipeGestureRecognizer *)recognizer setDirection:UISwipeGestureRecognizerDirectionRight];
	[(UISwipeGestureRecognizer *)recognizer setNumberOfTouchesRequired:2];
	[view addGestureRecognizer:recognizer];
	[recognizer release];
}

-(void) addLeftSwipeRecognizerToView:(UIView *)view
{
	// Left Swipe recognizer - two fingers
	UISwipeGestureRecognizer * recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(HandleLeftSwipeFrom:)];
	[(UISwipeGestureRecognizer *)recognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
	[(UISwipeGestureRecognizer *)recognizer setNumberOfTouchesRequired:2];
	[view addGestureRecognizer:recognizer];
	[recognizer release];
}

-(void) addUpSwipeRecognizerToView:(UIView *)view
{	
	// Right Swipe recognizer - two fingers
	UISwipeGestureRecognizer * recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(HandleRightSwipeFrom:)];
	[(UISwipeGestureRecognizer *)recognizer setDirection:UISwipeGestureRecognizerDirectionUp];
	[(UISwipeGestureRecognizer *)recognizer setNumberOfTouchesRequired:1];
	[view addGestureRecognizer:recognizer];
	[recognizer release];
}

-(void) addDownSwipeRecognizerToView:(UIView *)view
{	
	// Right Swipe recognizer - two fingers
	UISwipeGestureRecognizer * recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(HandleRightSwipeFrom:)];
	[(UISwipeGestureRecognizer *)recognizer setDirection:UISwipeGestureRecognizerDirectionDown];
	[(UISwipeGestureRecognizer *)recognizer setNumberOfTouchesRequired:1];
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

-(void) addDragRecognizerToView:(UIView *)view 
{	
	//Drag and drop - implemented as pan recognizer
	
	UIDragDropGestureRecognizer * recognizer = [[UIDragDropGestureRecognizer alloc] initWithTarget:self action:@selector(HandleDragFrom:)];
	[view addGestureRecognizer:recognizer];
	[recognizer release];
}

-(void) addJogRecognizerToView:(UIView *)view 
{	
	//Jog control - implemented as pan recognizer
	// Works only on JogControlViews
	if(!view || ![view isKindOfClass:[JogControlView class]])
		return;
	
	UIJogGestureRecognizer * recognizer = [[UIJogGestureRecognizer alloc] initWithTarget:self action:@selector(HandleJogFrom:)];
	[view addGestureRecognizer:recognizer];
	[recognizer release];
}

// Gesture recognizer callbacks

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
	if(touch && [[touch.view class] isSubclassOfClass:[UIControl class]])
		return false;	
	
	return true;
}

- (void)HandleTapFrom:(UIGestureRecognizer *)gestureRecognizer
{
	tapView = [gestureRecognizer view];
	tapPoint = [gestureRecognizer locationInView:tapView];
	
	if(doubleTapEnabled)
	{
		doubleTapTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(doubleTapTimerExpired:) userInfo:nil repeats:NO];
	}
	else
	{
		[self OnTapGestureInView:tapView AtX:tapPoint.x Y:tapPoint.y];
	}
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
	// Don't respond to end state
	if([gestureRecognizer state] == UIGestureRecognizerStateEnded)
		return;
	
	UIView * gestureView = [gestureRecognizer view];
	CGPoint point = [gestureRecognizer locationInView:gestureView];
	[self OnLongPressGestureInView:gestureView AtX:point.x Y:point.y];
}

- (void)HandlePinchFrom:(UIGestureRecognizer *)gestureRecognizer
{
	UIView * gestureView = [gestureRecognizer view];

	if([(UIPinchGestureRecognizer *)gestureRecognizer state] == UIGestureRecognizerStateEnded)
	{
		lastGestureScale = 1.0;
		return;
	}
	
	if([(UIPinchGestureRecognizer *)gestureRecognizer state] == UIGestureRecognizerStateBegan)
	{
		gestureStartPoint = [gestureRecognizer locationInView:gestureView];
		lastGestureScale = 1.0;
	}
	
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

- (void)HandleUpSwipeFrom:(UIGestureRecognizer *)gestureRecognizer
{
	UIView * gestureView = [gestureRecognizer view];
	[self OnUpSwipeGestureInView:gestureView];
}

- (void)HandleDownSwipeFrom:(UIGestureRecognizer *)gestureRecognizer
{
	UIView * gestureView = [gestureRecognizer view];
	[self OnDownSwipeGestureInView:gestureView];
}

- (void)HandlePanFrom:(UIGestureRecognizer *)gestureRecognizer
{
	int state = [(UIPanGestureRecognizer *)gestureRecognizer state];
	UIView * gestureView = [gestureRecognizer view];
	CGPoint pan = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:gestureView];
	CGPoint speed = [(UIPanGestureRecognizer *)gestureRecognizer velocityInView:gestureView];
	
	if(state == UIGestureRecognizerStateBegan)
	{
		gestureStartPoint = [gestureRecognizer locationInView:gestureView];
	}
	
	float thisGesturePanX = pan.x;
	float thisGesturePanY = pan.y;
	pan.x = pan.x - lastGesturePanX;
	pan.y = pan.y - lastGesturePanY;
	[self OnPanGestureInView:gestureView ByX:pan.x Y:pan.y SpeedX:speed.x SpeedY:speed.y State:state];
	lastGesturePanX = thisGesturePanX;
	lastGesturePanY = thisGesturePanY;

	if(state == UIGestureRecognizerStateEnded)
	{
		lastGesturePanX = 0.0;
		lastGesturePanY = 0.0;
		return;
	}
	
}

- (void)HandleDragFrom:(UIGestureRecognizer *)gestureRecognizer
{
	int state = [(UIDragDropGestureRecognizer *)gestureRecognizer state];
	UIView * gestureView = [gestureRecognizer view];
	
	CGPoint pan = [(UIDragDropGestureRecognizer *)gestureRecognizer translationInView:gestureView];
	CGPoint speed = [(UIDragDropGestureRecognizer *)gestureRecognizer velocityInView:gestureView];
	
	float thisGesturePanX = pan.x;
	float thisGesturePanY = pan.y;
	pan.x = pan.x - lastGesturePanX;
	pan.y = pan.y - lastGesturePanY;
	[self OnDragGestureInView:gestureView ByX:pan.x Y:pan.y SpeedX:speed.x SpeedY:speed.y  State:state Recognizer:(UIDragDropGestureRecognizer *)gestureRecognizer];
	lastGesturePanX = thisGesturePanX;
	lastGesturePanY = thisGesturePanY;
	
	if(state == UIGestureRecognizerStateEnded)
	{
		lastGesturePanX = 0.0;
		lastGesturePanY = 0.0;
		return;
	}
	
}

- (void)HandleJogFrom:(UIGestureRecognizer *)gestureRecognizer
{	
	UIView * gestureView = [gestureRecognizer view];
	
	int state = [(UIJogGestureRecognizer *)gestureRecognizer state];
	
	if(state == UIGestureRecognizerStateEnded)
	{
		[self OnJogGestureInView:gestureView AngleChange:0 State:state];		
		return;
	}
	
	CGPoint point = [(UIJogGestureRecognizer *)gestureRecognizer locationInView:gestureView];
	
	CGRect viewBounds = [gestureView bounds];
	
	float xCentre = viewBounds.size.width / 2;
	float yCentre = viewBounds.size.height / 2;
	
	float dx = point.x - xCentre;
	float dy = yCentre - point.y;

	// only initialise once we're 10 pixels from centre
	if(![(UIJogGestureRecognizer *)gestureRecognizer initialised])
	{
		if((dx * dx + dy * dy) > 100.0)
		{
			float angle = atan2(dy,dx);
			[(UIJogGestureRecognizer *)gestureRecognizer setLastAngle:angle];
			[(UIJogGestureRecognizer *)gestureRecognizer setDirection:0];
			[(UIJogGestureRecognizer *)gestureRecognizer setInitialised:true];
		}
	}
	else
	{
		float angle = atan2(dy,dx);
		float lastAngle = [(UIJogGestureRecognizer *)gestureRecognizer lastAngle];
		float change = angle - lastAngle;
		
		// Fast spinning is considered as maximum speed (= 90 degrees per sample)
		// First verify that we haven't crossed the +/- 180 degree line slowly
		
		int direction = [(UIJogGestureRecognizer *)gestureRecognizer direction];
		
		if(angle > M_PI * 0.75 && lastAngle < - M_PI * 0.75)
		{
			lastAngle += M_PI * 2;
			change = angle - lastAngle;
		}
		else if(angle < - M_PI * 0.75 && lastAngle > M_PI * 0.75)
		{
			lastAngle -= M_PI * 2;
			change = angle - lastAngle;
		}
		
		int newDirection = change < -0.0001 ? -1 : change > 0.0001 ? 1 : direction;

		if(fabsf(change) > M_PI * 0.75)
		{
			if(direction != 0 && newDirection != direction)
			{
				change = direction == 1 ? change + M_PI * 2.0 : change - M_PI * 2.0 ;
			}
		}
 		
		while(angle > M_PI)
			angle -= M_PI * 2;
		
		while(angle < -M_PI)
			angle += M_PI * 2;
		
		[(UIJogGestureRecognizer *)gestureRecognizer setLastAngle:angle];
		[(UIJogGestureRecognizer *)gestureRecognizer setDirection:newDirection];
		
		[self OnJogGestureInView:gestureView AngleChange:change State:state];
	}
	
}

// Action callbacks - these should be overridden if you want any specific actions

// Only the single tap does anything by default - it brings up the time controls

- (void) OnTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
	[self handleTimeControllerGestureInView:gestureView AtX:x Y:y];
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

- (void) OnUpSwipeGestureInView:(UIView *)gestureView
{
}

- (void) OnDownSwipeGestureInView:(UIView *)gestureView
{
}

- (void) OnPanGestureInView:(UIView *)gestureView ByX:(float)x Y:(float)y SpeedX:(float)speedx SpeedY:(float)speedy State:(int)state
{
}

- (void) OnDragGestureInView:(UIView *)gestureView ByX:(float)x Y:(float)y SpeedX:(float)speed_x SpeedY:(float)speed_y State:(int)state Recognizer:(UIDragDropGestureRecognizer *)recognizer
{
}

- (void) OnJogGestureInView:(UIView *)gestureView AngleChange:(float)angle State:(int)state
{
}

- (void) handleTimeControllerGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
	if ( timeControllerInstance
	  && [timeControllerInstance conformsToProtocol:@protocol(TimeControllerInstance)] )
	{
		if(![timeControllerInstance timeControllerDisplayed])
		{
			CGPoint tapScreenPoint = [[self view] convertPoint:CGPointMake(x, y) fromView:gestureView];

			// Only display if y is in bottom 150 pixels of our base view
			CGRect viewBounds = [[self view] bounds];
			
			if(tapScreenPoint.y > viewBounds.size.height - 150)
			{
				[timeControllerInstance displayTimeControllerInViewController:self Animated:true];
			}
		}
		else
		{
			[timeControllerInstance hideTimeController];
		}
	}
}


@end

// Our own drag drop gesture recognizer
@implementation UIDragDropGestureRecognizer

@synthesize downPoint;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	downPoint = [[touches anyObject] locationInView:[self view]];
	[super touchesBegan:touches withEvent:event];
}

@end

// Our own jog gesture recognizer
@implementation UIJogGestureRecognizer

@synthesize downPoint;
@synthesize initialised;
@synthesize lastAngle;
@synthesize direction;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	direction = 0;
	
	downPoint = [[touches anyObject] locationInView:[self view]];
	
	CGRect viewBounds = [[self view] bounds];
	
	float xCentre = viewBounds.size.width / 2;
	float yCentre = viewBounds.size.height / 2;
	
	float dx = downPoint.x - xCentre;
	float dy = yCentre - downPoint.y;
	
	// only initialise once we're 10 pixels from centre
	initialised = false;
	if((dx * dx + dy * dy) > 100.0)
	{
		lastAngle = atan2(dy,dx);
		initialised = true;
	}
	
	[(JogControlView *)[self view] setChange:0.0];

	[super touchesBegan:touches withEvent:event];
}

- (float)angleOfPoint:(CGPoint)point InView:(UIView *)gestureView
{
	CGRect viewBounds = [gestureView bounds];

	float xCentre = viewBounds.size.width / 2;
	float yCentre = viewBounds.size.height / 2;

	float dx = point.x - xCentre;
	float dy = yCentre - point.y;

	return atan2(dy,dx);
}

@end


