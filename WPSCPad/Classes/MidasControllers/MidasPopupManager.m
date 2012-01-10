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

#import "MidasAlertsViewController.h"
#import "MidasTwitterViewController.h"
#import "MidasFacebookViewController.h"
#import "MidasChatViewController.h"

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
		viewController = [[MidasStandingsViewController alloc] initWithNibName:@"MidasStandingsView" bundle:nil];
		[self setManagedViewController:viewController];
		[self setManagedViewType:MIDAS_STANDINGS_POPUP_];
		[viewController setAssociatedManager:self];
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
		viewController = [[MidasCircuitViewController alloc] initWithNibName:@"MidasCircuitView" bundle:nil];
		[self setManagedViewController:viewController];
		[self setManagedViewType:MIDAS_CIRCUIT_POPUP_];
		[viewController setAssociatedManager:self];
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
		viewController = [[MidasFollowDriverViewController alloc] initWithNibName:@"MidasFollowDriverView" bundle:nil];
		[self setManagedViewController:viewController];
		[self setManagedViewType:MIDAS_FOLLOW_DRIVER_POPUP_];
		[self setOverhang:(CGRectGetWidth([viewController.view bounds]) - CGRectGetWidth([viewController.container bounds]))];
		[viewController setAssociatedManager:self];
	}
	
	return self;
}

@end

@implementation MidasAlertsManager

static MidasAlertsManager * alertsInstance_ = nil;

+(MidasAlertsManager *)Instance
{
	if(!alertsInstance_)
		alertsInstance_ = [[MidasAlertsManager alloc] init];
	
	return alertsInstance_;
}

-(id)init
{
	if(self = [super init])
	{			
		viewController = [[MidasAlertsViewController alloc] initWithNibName:@"MidasAlertsView" bundle:nil];
		[self setManagedViewController:viewController];
		[self setManagedViewType:MIDAS_ALERTS_POPUP_];
		[viewController setAssociatedManager:self];
	}
	
	return self;
}

@end

@implementation MidasTwitterManager

static MidasTwitterManager * twitterInstance_ = nil;

+(MidasTwitterManager *)Instance
{
	if(!twitterInstance_)
		twitterInstance_ = [[MidasTwitterManager alloc] init];
	
	return twitterInstance_;
}

-(id)init
{
	if(self = [super init])
	{			
		viewController = [[MidasTwitterViewController alloc] initWithNibName:@"MidasTwitterView" bundle:nil];
		[self setManagedViewController:viewController];
		[self setManagedViewType:MIDAS_TWITTER_POPUP_];
		[viewController setAssociatedManager:self];
	}
	
	return self;
}

@end

@implementation MidasFacebookManager

static MidasFacebookManager * facebookInstance_ = nil;

+(MidasFacebookManager *)Instance
{
	if(!facebookInstance_)
		facebookInstance_ = [[MidasFacebookManager alloc] init];
	
	return facebookInstance_;
}

-(id)init
{
	if(self = [super init])
	{			
		viewController = [[MidasFacebookViewController alloc] initWithNibName:@"MidasFacebookView" bundle:nil];
		[self setManagedViewController:viewController];
		[self setManagedViewType:MIDAS_FACEBOOK_POPUP_];
		[viewController setAssociatedManager:self];
	}
	
	return self;
}

@end

@implementation MidasChatManager

static MidasChatManager * chatInstance_ = nil;

+(MidasChatManager *)Instance
{
	if(!chatInstance_)
		chatInstance_ = [[MidasChatManager alloc] init];
	
	return chatInstance_;
}

-(id)init
{
	if(self = [super init])
	{			
		viewController = [[MidasChatViewController alloc] initWithNibName:@"MidasChatView" bundle:nil];
		[self setManagedViewController:viewController];
		[self setManagedViewType:MIDAS_CHAT_POPUP_];
		[viewController setAssociatedManager:self];
	}
	
	return self;
}

@end

@implementation MidasPopupManager

@synthesize viewDisplayed;
@synthesize managedViewController;
@synthesize parentViewController;
@synthesize managedViewType;
@synthesize overhang;
@synthesize preferredWidth;

-(id)init
{
	if(self = [super init])
	{			
		managedViewController = nil; // N.B. managedViewController MUST be assigned by derived class in its init
		
		viewDisplayed = false;
		hiding = false;
		
		xAlignment = MIDAS_ALIGN_LEFT_;
		yAlignment = MIDAS_ALIGN_BOTTOM_;
		
		overhang = 0.0;
		preferredWidth = -1.0;
		
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
	
	parentViewController = [viewController retain];

	[managedViewController onDisplay];
	
	// Get the new positions
	CGRect superBounds = [viewController.view bounds];
	CGRect ourBounds = [managedViewController.view bounds];
	
	xAlignment = xAlign;
	yAlignment = yAlign;
	
	float finalX, initialY, finalY;
	
	if(xAlignment == MIDAS_ALIGN_RIGHT_)
		finalX = x - CGRectGetWidth(ourBounds) + overhang;
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
		if(parentViewController && [parentViewController respondsToSelector:@selector(notifyShowingPopup:)])
			[parentViewController notifyShowingPopup:managedViewType];
	}
	
	[managedViewController.view setHidden:false];
	
	if(animated)
	{
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.5];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(displayAnimationDidStop:finished:context:)];
		[managedViewController.view setFrame:CGRectOffset(ourBounds, finalX, finalY)];
		[UIView commitAnimations];
	}
	
	viewDisplayed = true;
	
	// Don't do automatic hiding : [self setHideTimer];
}

- (void) displayAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void*)context
{
	if([finished intValue] == 1)
	{
		if(parentViewController && [parentViewController respondsToSelector:@selector(notifyShowingPopup:)])
			[parentViewController notifyShowingPopup:managedViewType];
	}
}
- (void) moveToPositionX:(float)x Animated:(bool)animated
{
	// Can't move if we're not displayed or are in the middle of hiding
	if(!viewDisplayed || !parentViewController || hiding)
		return;
	
	// Get the new positions
	CGRect ourFrame = [managedViewController.view frame];
	
	float newWidth = (preferredWidth > 0.0) ? preferredWidth : CGRectGetWidth(ourFrame);
	
	float finalX;
	
	if(xAlignment == MIDAS_ALIGN_RIGHT_)
		finalX = x - newWidth + overhang;
	else 
		finalX = x;
			
	if(animated)
	{
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.5];
		[managedViewController.view setFrame:CGRectMake(finalX, CGRectGetMinY(ourFrame), newWidth, CGRectGetHeight(ourFrame))];
		[UIView commitAnimations];
	}
	else
	{
		[managedViewController.view setFrame:CGRectMake(finalX, CGRectGetMinY(ourFrame), newWidth, CGRectGetHeight(ourFrame))];
	}
}

- (void) hideAnimated:(bool)animated Notify:(bool)notify
{
	if(!viewDisplayed || !parentViewController)
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
	CGRect ourFrame = [managedViewController.view frame];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(hideAnimationDidStop:finished:context:)];
	
	if(yAlignment == MIDAS_ALIGN_TOP_)
		[managedViewController.view setFrame:CGRectOffset(ourFrame, 0, -CGRectGetHeight(ourFrame) )];
	else
		[managedViewController.view setFrame:CGRectOffset(ourFrame, 0, CGRectGetHeight(ourFrame))];
	
	[UIView commitAnimations];
	
	// We set a timer to reset the hiding flag just in case the animationDidStop doesn't get called (maybe on tab change?)
	flagTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(flagTimerExpired:) userInfo:nil repeats:NO];
	
	if(notify && parentViewController && [parentViewController respondsToSelector:@selector(notifyHidingPopup:)])
		[parentViewController notifyHidingPopup:managedViewType];
	
	[parentViewController release];
	parentViewController = nil;
	
}

- (void) hideAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void*)context
{
	if([finished intValue] == 1)
	{
		[managedViewController.view removeFromSuperview];
		hiding = false;
		viewDisplayed = false;
		
		[managedViewController onHide];
		
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
	if(parentViewController)
	{
		//CGPoint tapPoint = [gestureRecognizer locationInView:tapView];	
		[parentViewController HandleTapFrom:(UIGestureRecognizer *)gestureRecognizer];
	}
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
	if(touch && [touch view] == [managedViewController view])
		return true;	

	return false;
}

///////////////////////////////////////////////////////////
// Information enquiry

- (float) widthOfView
{
	return CGRectGetWidth([managedViewController.view bounds]) - overhang;
}

- (float) heightOfView
{
	return CGRectGetHeight([managedViewController.view bounds]);
}

@end
