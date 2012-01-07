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
#import "BasePadViewController.h"

@implementation MidasStandingsManager

static MidasStandingsManager * instance_ = nil;

@synthesize standingsViewController;

+(MidasStandingsManager *)Instance
{
	if(!instance_)
		instance_ = [[MidasStandingsManager alloc] init];
	
	return instance_;
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

- (void) displayInViewController:(UIViewController *)viewController AtX:(float)x Y:(float)y Animated:(bool)animated
{	
	// Can't display if we're in the middle of hiding
	if(hiding)
		return;
	
	// Get the new positions
	CGRect superBounds = [viewController.view bounds];
	CGRect ourBounds = [managedViewController.view bounds];
	
	[managedViewController.view setHidden:true];
	
	[viewController.view addSubview:managedViewController.view];
	
	if(animated)
	{
		[managedViewController.view setFrame:CGRectOffset(ourBounds, x, CGRectGetHeight(superBounds))];
	}
	else
	{
		[managedViewController.view setFrame:CGRectOffset(ourBounds, x, y)];
	}
	
	[managedViewController.view setHidden:false];
	
	if(animated)
	{
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.5];
		[managedViewController.view setFrame:CGRectOffset(ourBounds, x, y)];
		[UIView commitAnimations];
	}
	
	viewDisplayed = true;
	
	// Don't do automatic hiding : [self setHideTimer];
	
	parentController = [viewController retain];
}

- (void) hideAnimated:(bool)animated
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
	
	if(parentController && [parentController respondsToSelector:@selector(notifyHidingPopup:)])
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
	[self hideAnimated:true];
	hideTimer = nil;
}

//////////////////////////////////////////////////////////
// Gesture recogniser handling

- (void)HandleTapFrom:(UIGestureRecognizer *)gestureRecognizer
{
	[self hideAnimated:true];
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

@end
