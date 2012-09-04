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
#import "MidasCameraViewController.h"
#import "MidasFollowDriverViewController.h"

#import "MidasAlertsViewController.h"
#import "MidasTwitterViewController.h"
#import "MidasFacebookViewController.h"
#import "MidasChatViewController.h"

#import "MidasDemoViewControllers.h"

#import "BasePadViewController.h"
#import "MidasSocialViewController.h"

@implementation MidasMasterMenuManager

static MidasMasterMenuManager * masterMenuInstance_ = nil;

+(MidasMasterMenuManager *)Instance
{
	if(!masterMenuInstance_)
		masterMenuInstance_ = [[MidasMasterMenuManager alloc] init];
	
	return masterMenuInstance_;
}

-(id)init
{
	if(self = [super init])
	{			
		viewController = [[MidasMasterMenuViewController alloc] initWithNibName:@"MidasMasterMenuView" bundle:nil];
		[self setManagedViewController:viewController];
		[self setManagedViewType:MIDAS_MASTER_MENU_POPUP_];
		[self setManagedExclusionZone:MIDAS_ZONE_ALL_];
		[viewController setAssociatedManager:self];
	}
	
	return self;
}

@end

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
		[self setManagedExclusionZone:MIDAS_ZONE_TOP_ | MIDAS_ZONE_MY_AREA_];
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
		[self setManagedExclusionZone:MIDAS_ZONE_TOP_ | MIDAS_ZONE_MY_AREA_];
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
		[self setManagedExclusionZone:MIDAS_ZONE_TOP_ | MIDAS_ZONE_MY_AREA_];
		[self setOverhang:(CGRectGetWidth([viewController.view bounds]) - CGRectGetWidth([viewController.container bounds]))];
		[viewController setAssociatedManager:self];
	}
	
	return self;
}

@end

@implementation MidasCameraManager

static MidasCameraManager * cameraInstance_ = nil;

+(MidasCameraManager *)Instance
{
	if(!cameraInstance_)
		cameraInstance_ = [[MidasCameraManager alloc] init];
	
	return cameraInstance_;
}

-(id)init
{
	if(self = [super init])
	{			
		viewController = [[MidasCameraViewController alloc] initWithNibName:@"MidasCamerasView" bundle:nil];
		[self setManagedViewController:viewController];
		[self setManagedViewType:MIDAS_CAMERA_POPUP_];
		[self setManagedExclusionZone:MIDAS_ZONE_TOP_ | MIDAS_ZONE_MY_AREA_];
		[viewController setAssociatedManager:self];
	}
	
	return self;
}

@end

@implementation MidasHeadToHeadManager
									   
static MidasHeadToHeadManager * headToHeadInstance_ = nil;
									   
+(MidasHeadToHeadManager *)Instance
{
	if(!headToHeadInstance_)
		headToHeadInstance_ = [[MidasHeadToHeadManager alloc] init];
			
	return headToHeadInstance_;
}
									   
-(id)init
{
	if(self = [super init])
	{			
		viewController = [[MidasHeadToHeadViewController alloc] initWithNibName:@"MidasDemoImageView" bundle:nil];
		[self setManagedViewController:viewController];
		[self setManagedViewType:MIDAS_HEAD_TO_HEAD_POPUP_];
		[self setManagedExclusionZone:MIDAS_ZONE_TOP_ | MIDAS_ZONE_MY_AREA_];
		[viewController setAssociatedManager:self];
	}
			
	return self;
}
									   
@end

@implementation MidasMyTeamManager
									   
static MidasMyTeamManager * myTeamInstance_ = nil;
									   
+(MidasMyTeamManager *)Instance
{
	if(!myTeamInstance_)
		myTeamInstance_ = [[MidasMyTeamManager alloc] init];
	
	return myTeamInstance_;
}
							   
-(id)init
{
	if(self = [super init])
	{			
		viewController = [[MidasMyTeamViewController alloc] initWithNibName:@"MidasMyTeamView" bundle:nil];
		[self setManagedViewController:viewController];
		[self setManagedViewType:MIDAS_MY_TEAM_POPUP_];
		[self setManagedExclusionZone:MIDAS_ZONE_TOP_ | MIDAS_ZONE_DATA_AREA_];
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
		[self setManagedExclusionZone:MIDAS_ZONE_BOTTOM_];
		[viewController setAssociatedManager:self];
	}
	
	return self;
}

@end

@implementation MidasSocialMediaManager

static MidasSocialMediaManager * socialmediaInstance_ = nil;

+(MidasSocialMediaManager *)Instance
{
	if(!socialmediaInstance_)
		socialmediaInstance_ = [[MidasSocialMediaManager alloc] init];
	
	return socialmediaInstance_;
}

-(id)init
{
	if(self = [super init])
	{			
		viewController = [[MidasSocialViewController alloc] init];
		[self setManagedViewController:viewController];
		[self setManagedViewType:MIDAS_SOCIAL_MEDIA_POPUP_];
		[self setManagedExclusionZone:(MIDAS_ZONE_BOTTOM_ | MIDAS_ZONE_SOCIAL_MEDIA_)];
		[viewController setAssociatedManager:self];
	}
	
	return self;
}

@end

@implementation MidasHelpManager

static MidasHelpManager * helpInstance_ = nil;

+(MidasHelpManager *)Instance
{
	if(!helpInstance_)
		helpInstance_ = [[MidasHelpManager alloc] init];
	
	return helpInstance_;
}

-(id)init
{
	if(self = [super init])
	{			
		viewController = nil;//[[MidasFacebookViewController alloc] initWithNibName:@"MidasFacebookView" bundle:nil];
		[self setManagedViewController:viewController];
		[self setManagedViewType:MIDAS_HELP_POPUP_];
		[self setManagedExclusionZone:(MIDAS_ZONE_BOTTOM_ | MIDAS_ZONE_SOCIAL_MEDIA_)];
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
		[self setManagedExclusionZone:(MIDAS_ZONE_BOTTOM_ | MIDAS_ZONE_SOCIAL_MEDIA_)];
		[viewController setAssociatedManager:self];
	}
	
	return self;
}

@end

@implementation MidasVIPManager

static MidasVIPManager * vipInstance_ = nil;

+(MidasVIPManager *)Instance
{
	if(!vipInstance_)
		vipInstance_ = [[MidasVIPManager alloc] init];
	
	return vipInstance_;
}

-(id)init
{
	if(self = [super init])
	{			
		viewController = [[MidasVIPViewController alloc] initWithNibName:@"MidasVIPView" bundle:nil];
		[self setManagedViewController:viewController];
		[self setManagedViewType:MIDAS_VIP_POPUP_];
		[self setManagedExclusionZone:MIDAS_ZONE_BOTTOM_];
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
@synthesize managedExclusionZone;
@synthesize overhang;
@synthesize preferredWidth;

-(id)init
{
	if(self = [super init])
	{			
		managedViewController = nil; // N.B. managedViewController MUST be assigned by derived class in its init
		
		managedExclusionZone = MIDAS_ZONE_NONE_;
		managedViewType = MIDAS_POPUP_NONE_;
		
		viewDisplayed = false;
		hiding = false;
		
		xAlignment = MIDAS_ALIGN_LEFT_;
		yAlignment = MIDAS_ALIGN_BOTTOM_;
		
		overhang = 0.0;
		preferredWidth = -1.0;
		
		hideTimer = nil;
		flagTimer = nil;
		
		parentViewController = nil;
		
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

- (void) grabExclusion:(UIViewController <MidasPopupParentDelegate> *)viewController
{
	if(viewController && [viewController respondsToSelector:@selector(notifyExclusiveUse:InZone:)])
		[viewController notifyExclusiveUse:managedViewType InZone:managedExclusionZone];	
}

- (void) displayInViewController:(UIViewController *)viewController AtX:(float)x Animated:(bool)animated Direction:(int)direction XAlignment:(int)xAlign YAlignment:(int)yAlign;
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
	revealDirection= direction;
	
	float initialX, finalX, initialY, finalY;
	
	if(xAlignment == MIDAS_ALIGN_FULL_SCREEN_)
	{
		if(direction == MIDAS_DIRECTION_RIGHT_)
			initialX = - CGRectGetWidth(ourBounds);
		else if(direction == MIDAS_DIRECTION_LEFT_)
			initialX = CGRectGetWidth(superBounds);
		else
			initialX = 0;

		finalX = 0;
	}
	else if(xAlignment == MIDAS_ALIGN_RIGHT_)
	{
		initialX = finalX = x - CGRectGetWidth(ourBounds) + overhang;
	}
	else
	{
		initialX = finalX = x;
	}
	
	if(yAlignment == MIDAS_ALIGN_FULL_SCREEN_)
	{
		if(direction == MIDAS_DIRECTION_DOWN_)
			initialY = - CGRectGetHeight(ourBounds);
		else if(direction == MIDAS_DIRECTION_UP_)
			initialY = CGRectGetHeight(superBounds);
		else
			initialY = 0;
		
		finalY = 0;
	}
	else if(yAlignment == MIDAS_ALIGN_TOP_)
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
		[managedViewController.view setFrame:CGRectOffset(ourBounds, initialX, initialY)];
	}
	else
	{
		[managedViewController.view setFrame:CGRectOffset(ourBounds, finalX, finalY)];
		if(parentViewController && [parentViewController respondsToSelector:@selector(notifyShowedPopup:)])
			[parentViewController notifyShowedPopup:managedViewType];
	}
	
	[managedViewController.view setHidden:false];
	
	if(animated)
	{
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.5];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(displayAnimationDidStop:finished:context:)];
		[managedViewController.view setFrame:CGRectOffset(ourBounds, finalX, finalY)];

		if(parentViewController && [parentViewController respondsToSelector:@selector(notifyShowingPopup:)])
			[parentViewController notifyShowingPopup:managedViewType];
		
		[UIView commitAnimations];
	}
	
	viewDisplayed = true;
	
}

- (void) displayAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void*)context
{
	if(parentViewController && [parentViewController respondsToSelector:@selector(notifyShowedPopup:)])
			[parentViewController notifyShowedPopup:managedViewType];
}

- (void) moveToPositionX:(float)x Animated:(bool)animated
{
	// Can't move if we're not displayed or are in the middle of hiding
	if(!parentViewController || hiding)
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
		[parentViewController release];
		parentViewController = nil;
		return;
	}
	
	hiding = true;
	
	if(hideTimer)
	{
		[hideTimer invalidate];
		hideTimer = nil;
	}
	
	// Get the new positions
	CGRect superBounds = [parentViewController.view bounds];
	CGRect ourFrame = [managedViewController.view frame];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(hideAnimationDidStop:finished:context:)];
	
	if(xAlignment == MIDAS_ALIGN_FULL_SCREEN_ || xAlignment == MIDAS_ALIGN_FULL_SCREEN_)
	{
		if(revealDirection == MIDAS_DIRECTION_RIGHT_)
			[managedViewController.view setFrame:CGRectOffset(ourFrame, -CGRectGetWidth(superBounds), 0)];
		else if(revealDirection == MIDAS_DIRECTION_LEFT_)
			[managedViewController.view setFrame:CGRectOffset(ourFrame, CGRectGetWidth(superBounds), 0)];
		else if(revealDirection == MIDAS_DIRECTION_UP_)
			[managedViewController.view setFrame:CGRectOffset(ourFrame, 0, CGRectGetHeight(superBounds))];
		else if(revealDirection == MIDAS_DIRECTION_DOWN_)
			[managedViewController.view setFrame:CGRectOffset(ourFrame, 0, -CGRectGetHeight(superBounds))];
	}
	else if(yAlignment == MIDAS_ALIGN_TOP_)
	{
		[managedViewController.view setFrame:CGRectOffset(ourFrame, 0, -CGRectGetHeight(ourFrame) )];
	}
	else
	{
		[managedViewController.view setFrame:CGRectOffset(ourFrame, 0, CGRectGetHeight(ourFrame))];
	}
	
	if(notify && parentViewController && [parentViewController respondsToSelector:@selector(notifyHidingPopup:)])
		[parentViewController notifyHidingPopup:managedViewType];
	
	[UIView commitAnimations];
	
	// We set a timer to reset the hiding flag just in case the animationDidStop doesn't get called (maybe on tab change?)
	flagTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(flagTimerExpired:) userInfo:nil repeats:NO];
		
}

- (void) hideAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void*)context
{
	hiding = false;

	[managedViewController onHide];

	[managedViewController.view removeFromSuperview];
	viewDisplayed = false;
	
	[parentViewController release];
	parentViewController = nil;
	
	if(flagTimer)
	{
		[flagTimer invalidate];
		flagTimer = nil;
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

- (float) preferredWidthOfView
{
	if(preferredWidth >= 0.0)
		return preferredWidth;
	else
		return [self widthOfView];
}

- (float) widthOfView
{
	return CGRectGetWidth([managedViewController.view bounds]) - overhang;
}

- (float) heightOfView
{
	return CGRectGetHeight([managedViewController.view bounds]);
}

@end
