//
//  BasePadPopupManager.m
//
//  Created by Gareth Griffith on 10/12/12.
//  Copyright (c) 2012 SBG Sports Software Ltd.. All rights reserved.
//

#import "BasePadPopupManager.h"
#import "BasePadViewController.h"

@implementation BasePadPopupManager

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
		
		managedExclusionZone = POPUP_ZONE_NONE_;
		managedViewType = POPUP_NONE_;
		
		viewDisplayed = false;
		hiding = false;
		
		xAlignment = POPUP_ALIGN_LEFT_;
		yAlignment = POPUP_ALIGN_BOTTOM_;
		
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

- (void) grabExclusion:(UIViewController <BasePadPopupParentDelegate> *)viewController
{
	if(viewController && [viewController respondsToSelector:@selector(notifyExclusiveUse:InZone:)])
		[viewController notifyExclusiveUse:managedViewType InZone:managedExclusionZone];
}

- (void) displayInViewController:(UIViewController *)viewController AtX:(float)x Animated:(bool)animated Direction:(int)direction XAlignment:(int)xAlign YAlignment:(int)yAlign
{
	// Can't display if we're in the middle of hiding
	if(hiding)
		return;
	
	parentViewController = (BasePadViewController <BasePadPopupParentDelegate>  *)[viewController retain];
	
	[managedViewController onDisplay];
	
	// Get the new positions
	CGRect superBounds = [viewController.view bounds];
	CGRect ourBounds = [managedViewController.view bounds];
	
	xAlignment = xAlign;
	yAlignment = yAlign;
	revealDirection= direction;
	
	float initialX, finalX, initialY, finalY;
	
	if(xAlignment == POPUP_ALIGN_FULL_SCREEN_)
	{
		if(direction == POPUP_DIRECTION_RIGHT_)
			initialX = - CGRectGetWidth(ourBounds);
		else if(direction == POPUP_DIRECTION_LEFT_)
			initialX = CGRectGetWidth(superBounds);
		else
			initialX = 0;
        
		finalX = 0;
	}
	else if(xAlignment == POPUP_ALIGN_RIGHT_)
	{
		initialX = finalX = x - CGRectGetWidth(ourBounds) + overhang;
	}
	else
	{
		initialX = finalX = x;
	}
	
	if(yAlignment == POPUP_ALIGN_FULL_SCREEN_)
	{
		if(direction == POPUP_DIRECTION_DOWN_)
			initialY = - CGRectGetHeight(ourBounds);
		else if(direction == POPUP_DIRECTION_UP_)
			initialY = CGRectGetHeight(superBounds);
		else
			initialY = 0;
		
		finalY = 0;
	}
	else if(yAlignment == POPUP_ALIGN_TOP_)
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
	
	if(xAlignment == POPUP_ALIGN_RIGHT_)
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
	
	if(xAlignment == POPUP_ALIGN_FULL_SCREEN_ || xAlignment == POPUP_ALIGN_FULL_SCREEN_)
	{
		if(revealDirection == POPUP_DIRECTION_RIGHT_)
			[managedViewController.view setFrame:CGRectOffset(ourFrame, -CGRectGetWidth(superBounds), 0)];
		else if(revealDirection == POPUP_DIRECTION_LEFT_)
			[managedViewController.view setFrame:CGRectOffset(ourFrame, CGRectGetWidth(superBounds), 0)];
		else if(revealDirection == POPUP_DIRECTION_UP_)
			[managedViewController.view setFrame:CGRectOffset(ourFrame, 0, CGRectGetHeight(superBounds))];
		else if(revealDirection == POPUP_DIRECTION_DOWN_)
			[managedViewController.view setFrame:CGRectOffset(ourFrame, 0, -CGRectGetHeight(superBounds))];
	}
	else if(yAlignment == POPUP_ALIGN_TOP_)
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

- (void) bringToFront
{
	if(!viewDisplayed || !parentViewController || !parentViewController.view)
		return;
	
	[parentViewController.view bringSubviewToFront:managedViewController.view];
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
