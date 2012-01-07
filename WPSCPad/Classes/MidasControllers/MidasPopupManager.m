//
//  MidasPopupManager.m
//  MidasDemo
//
//  Created by Gareth Griffith on 1/6/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import "MidasPopupManager.h"

#import "MidasCoordinator.h"
#import "MidasStandingsViewController.h"
#import "MidasCircuitViewController.h"
#import "MidasFollowDriverViewController.h"
#import "BasePadViewController.h"

@implementation MidasStandingsManager

static MidasStandingsManager * standingsInstance_ = nil;

+(MidasStandingsManager *)Instance
{
	if(!standingsInstance_)
		standingsInstance_ = [[MidasStandingsManager alloc] init];
	
	return standingsInstance_;
}

-(id)init
{
	if(self = [super init])
	{			
		standingsViewController = [[MidasStandingsViewController alloc] initWithNibName:@"MidasStandingsView" bundle:nil];
		[self setManagedViewController:standingsViewController];
		[self setManagedViewType:MIDAS_STANDINGS_POPUP_];
	}
	
	return self;
}

@end

@implementation MidasCircuitViewManager

static MidasCircuitViewManager * circuitViewInstance_ = nil;

+(MidasCircuitViewManager *)Instance
{
	if(!circuitViewInstance_)
		circuitViewInstance_ = [[MidasCircuitViewManager alloc] init];
	
	return circuitViewInstance_;
}

-(id)init
{
	if(self = [super init])
	{			
		circuitViewController = [[MidasCircuitViewController alloc] initWithNibName:@"MidasCircuitView" bundle:nil];
		[self setManagedViewController:circuitViewController];
		[self setManagedViewType:MIDAS_CIRCUIT_POPUP_];
	}
	
	return self;
}

@end

@implementation MidasFollowDriverManager

static MidasFollowDriverManager * followDriverInstance_ = nil;

+(MidasFollowDriverManager *)Instance
{
	if(!followDriverInstance_)
		followDriverInstance_ = [[MidasFollowDriverManager alloc] init];
	
	return followDriverInstance_;
}

-(id)init
{
	if(self = [super init])
	{			
		followDriverViewController = [[MidasFollowDriverViewController alloc] initWithNibName:@"MidasFollowDriverView" bundle:nil];
		[self setManagedViewController:followDriverViewController];
		[self setManagedViewType:MIDAS_FOLLOW_DRIVER_POPUP_];
	}
	
	return self;
}

@end

@implementation MidasPopupManager

@synthesize viewDisplayed;
@synthesize managedViewController;
@synthesize managedViewType;

-(id)init
{
	if(self = [super init])
	{			
		managedViewController = nil; // N.B. managedViewController MUST be assigned by derived class in its init
		
		viewDisplayed = false;
		hiding = false;
		
		xAlignment = MIDAS_ALIGN_LEFT_;
		yAlignment = MIDAS_ALIGN_BOTTOM_;
		
		hideTimer = nil;
		flagTimer = nil;
		
	}
	
	return self;
}


- (void)dealloc
{
	[managedViewController release];
	[super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////

- (void) onStartUp
{
	if(managedViewController)
	{
		// Add a tap gesture recogniser to the background view to allow hiding of controls
		UITapGestureRecognizer * recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(HandleTapFrom:)];
		[recognizer setCancelsTouchesInView:false];
		[recognizer setDelegate:self];
		[[managedViewController view] addGestureRecognizer:recognizer];
		[recognizer release];
	}
}

- (void) displayInViewController:(UIViewController *)viewController AtX:(float)x Animated:(bool)animated XAlignment:(int)xAlign YAlignment:(int)yAlign;
{	
	// Can't display if we're in the middle of hiding
	if(hiding)
		return;
	
	// Get the new positions
	CGRect superBounds = [viewController.view bounds];
	CGRect ourBounds = [managedViewController.view bounds];
	
	xAlignment = xAlign;
	yAlignment = yAlign;
	
	float finalX, initialY, finalY;
	
	if(xAlignment == MIDAS_ALIGN_RIGHT_)
		finalX = x - CGRectGetWidth(ourBounds);
	else 
		finalX = x;
	
	if(yAlignment == MIDAS_ALIGN_TOP_)
	{
		initialY = - CGRectGetHeight(ourBounds);
		finalY = 0;
	}
	else
	{
		initialY = CGRectGetMaxY(superBounds);
		finalY = initialY - CGRectGetHeight(ourBounds);
	}
	
	
	[managedViewController.view setHidden:true];
	
	[viewController.view addSubview:managedViewController.view];
	
	if(animated)
	{
		[managedViewController.view setFrame:CGRectOffset(ourBounds, finalX, initialY)];
	}
	else
	{
		[managedViewController.view setFrame:CGRectOffset(ourBounds, finalX, finalY)];
	}
	
	[managedViewController.view setHidden:false];
	
	if(animated)
	{
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.5];
		[managedViewController.view setFrame:CGRectOffset(ourBounds, finalX, finalY)];
		[UIView commitAnimations];
	}
	
	viewDisplayed = true;
	
	// Don't do automatic hiding : [self setHideTimer];
	
	parentController = [viewController retain];
}

- (void) moveToPositionX:(float)x Animated:(bool)animated
{
	// Can't move if we're not displayed or are in the middle of hiding
	if(!viewDisplayed || !parentController || hiding)
		return;
	
	
	// Get the new positions
	CGRect ourFrame = [managedViewController.view frame];
	
	float finalX;
	
	if(xAlignment == MIDAS_ALIGN_RIGHT_)
		finalX = x - CGRectGetWidth(ourFrame);
	else 
		finalX = x;
	
	float xOffset = finalX - CGRectGetMinX(ourFrame);
		
	if(animated)
	{
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.5];
		[managedViewController.view setFrame:CGRectOffset(ourFrame, xOffset, 0)];
		[UIView commitAnimations];
	}
	else
	{
		[managedViewController.view setFrame:CGRectOffset(ourFrame, xOffset, 0)];
	}
}

- (void) hideAnimated:(bool)animated Notify:(bool)notify
{
	if(!viewDisplayed || !parentController)
		return;
	
	if(!animated)
	{
		[managedViewController.view removeFromSuperview];
		viewDisplayed = false;
		return;
	}
	
	hiding = true;
	
	if(hideTimer)
	{
		[hideTimer invalidate];
		hideTimer = nil;
	}
	
	// Get the new positions
	CGRect superBounds = [parentController.view bounds];
	CGRect ourFrame = [managedViewController.view frame];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	[managedViewController.view setFrame:CGRectOffset(ourFrame, 0, CGRectGetHeight(superBounds))];
	[UIView commitAnimations];
	
	// We set a timer to reset the hiding flag just in case the animationDidStop doesn't get called (maybe on tab change?)
	flagTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(flagTimerExpired:) userInfo:nil repeats:NO];
	
	if(notify && parentController && [parentController respondsToSelector:@selector(notifyHidingPopup:)])
		[parentController notifyHidingPopup:managedViewType];
	
	[parentController release];
	parentController = nil;
	
}

- (void) animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void*)context
{
	if([finished intValue] == 1)
	{
		[managedViewController.view removeFromSuperview];
		hiding = false;
		viewDisplayed = false;
		
		if(flagTimer)
		{
			[flagTimer invalidate];
			flagTimer = nil;
		}
	}
}

- (void) flagTimerExpired:(NSTimer *)theTimer
{
	flagTimer = nil;
	[self resetHidingFlag];
}

- (void) resetHidingFlag
{
	hiding = false;
}

- (void) setHideTimer
{
	// Timer to hide the controls if they're not touched for 5 seconds
	if(hideTimer)
		[hideTimer invalidate];
	
	hideTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(hideTimerExpired:) userInfo:nil repeats:NO];
	
}

- (void) hideTimerExpired:(NSTimer *)theTimer
{
	[self hideAnimated:true Notify:true];
	hideTimer = nil;
}

//////////////////////////////////////////////////////////
// Gesture recogniser handling

- (void)HandleTapFrom:(UIGestureRecognizer *)gestureRecognizer
{
	[self hideAnimated:true Notify:true];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
	/*
	 if(touch && [touch view] == [timeController view])
	 return true;	
	 */
	return false;
}

///////////////////////////////////////////////////////////
// Information enquiry

- (float) widthOfView
{
	return CGRectGetWidth([managedViewController.view bounds]);
}

- (float) heightOfView
{
	return CGRectGetHeight([managedViewController.view bounds]);
}

@end
