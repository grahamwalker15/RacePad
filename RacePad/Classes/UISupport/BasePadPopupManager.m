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
@synthesize appearStyle;
@synthesize dismissStyle;
@synthesize overhang;
@synthesize preferredWidth;
@synthesize showHeadingAtStart;

-(id)init
{
	if(self = [super init])
	{
		managedViewController = nil; // N.B. managedViewController MUST be assigned by derived class in its init
		
		managedExclusionZone = POPUP_ZONE_NONE_;
		managedViewType = POPUP_NONE_;
		
		viewDisplayed = false;
		hiding = false;
		notifyAfterHide = false;
		
		xAlignment = POPUP_ALIGN_LEFT_;
		yAlignment = POPUP_ALIGN_BOTTOM_;
		
		appearStyle = POPUP_SLIDE_;
		dismissStyle = POPUP_SLIDE_;
		
		overhang = 0.0;
		preferredWidth = -1.0;
		
		showHeadingAtStart = false;
		
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
	
	[managedViewController setParentViewController:viewController];
	[managedViewController willDisplay];
	
	// Get the new positions
	CGRect superBounds = [viewController.view bounds];
	CGRect ourBounds = [managedViewController.view bounds];
	CGRect ourContainerBounds = [managedViewController.container bounds];

	xAlignment = xAlign;
	yAlignment = yAlign;
	revealDirection= direction;
	
	float initialX, finalX, initialY, finalY;
	
	// Set final position based on alignment
	if(xAlignment == POPUP_ALIGN_FULL_SCREEN_)
		finalX = 0;
	else if(xAlignment == POPUP_ALIGN_CENTRE_)
		finalX = x - CGRectGetWidth(ourBounds) * 0.5;		
	else if(xAlignment == POPUP_ALIGN_RIGHT_)
		finalX = x - CGRectGetWidth(ourBounds) + overhang;
	else // Align left
		finalX = x;
	
	if(yAlignment == POPUP_ALIGN_FULL_SCREEN_)
		finalY = 0;
	else if(yAlignment == POPUP_ALIGN_CENTRE_)
		finalY = (CGRectGetHeight(superBounds) - CGRectGetHeight(ourBounds)) * 0.5;
	else if(yAlignment == POPUP_ALIGN_TOP_)
		finalY = 0;
	else // Align bottom
		finalY = CGRectGetMaxY(superBounds) - CGRectGetHeight(ourBounds);
	
	// Set initial X position based on reveal direction
	if(direction == POPUP_DIRECTION_NONE_ || appearStyle == POPUP_FADE_)
		initialX = finalX;
	else if(direction == POPUP_DIRECTION_RIGHT_)
		initialX = showHeadingAtStart ? -CGRectGetWidth(ourContainerBounds) : -CGRectGetWidth(ourBounds);
	else if(direction == POPUP_DIRECTION_LEFT_)
		initialX = showHeadingAtStart ? CGRectGetWidth(superBounds) - CGRectGetWidth(ourBounds) + CGRectGetWidth(ourContainerBounds): CGRectGetWidth(superBounds);
	else	// Up or down
		initialX = finalX;
	
	// Set initial Y position based on reveal direction
	if(direction == POPUP_DIRECTION_NONE_ || appearStyle == POPUP_FADE_)
		initialY = finalY;
	else if(direction == POPUP_DIRECTION_DOWN_)
		initialY = showHeadingAtStart ? -CGRectGetHeight(ourContainerBounds) : -CGRectGetHeight(ourBounds);
	else if(direction == POPUP_DIRECTION_UP_)
		initialY = showHeadingAtStart ? CGRectGetHeight(superBounds) - CGRectGetHeight(ourBounds) + CGRectGetHeight(ourContainerBounds): CGRectGetHeight(superBounds);
	else
		initialY = finalY;
	
	[managedViewController.view setHidden:true];
	
	[viewController.view addSubview:managedViewController.view];
	
	if(animated)
	{
		if(direction == POPUP_DIRECTION_NONE_ || appearStyle == POPUP_FADE_)
			[managedViewController.view setAlpha:0.0];
		
		[managedViewController.view setFrame:CGRectOffset(ourBounds, initialX, initialY)];
	}
	else
	{
		[managedViewController.view setFrame:CGRectOffset(ourBounds, finalX, finalY)];
		[managedViewController.view setAlpha:1.0];
		
		if(parentViewController && [parentViewController respondsToSelector:@selector(notifyShowedPopup:)])
			[parentViewController notifyShowedPopup:managedViewType];
		
		[managedViewController didDisplay];
	}
		
	[managedViewController.view setHidden:false];
	
	if(animated)
	{
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.5];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(displayAnimationDidStop:finished:context:)];
		[managedViewController.view setFrame:CGRectOffset(ourBounds, finalX, finalY)];
        
		if(direction == POPUP_DIRECTION_NONE_ || appearStyle == POPUP_FADE_)
			[managedViewController.view setAlpha:1.0];

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
	
	[managedViewController didDisplay];
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
	
	[managedViewController willHide];

	if(!animated)
	{
		[managedViewController didHide];

		[managedViewController.view removeFromSuperview];
		[managedViewController setParentViewController:nil];
		
		viewDisplayed = false;
		[parentViewController release];
		parentViewController = nil;
		return;
	}
	
	hiding = true;
	notifyAfterHide = notify;
	
	if(hideTimer)
	{
		[hideTimer invalidate];
		hideTimer = nil;
	}
	
	// Get the new positions
	CGRect superBounds = [parentViewController.view bounds];
	CGRect ourFrame = [managedViewController.view frame];
	CGRect ourContainerBounds = [managedViewController.container bounds];
	
	float remainder = showHeadingAtStart ? CGRectGetWidth(ourFrame) - CGRectGetWidth(ourContainerBounds) : 0.0;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(hideAnimationDidStop:finished:context:)];
	
	if(revealDirection == POPUP_DIRECTION_NONE_ || dismissStyle == POPUP_FADE_)
	{
		[managedViewController.view setAlpha:0.0];
	}
	else
	{
		if(revealDirection == POPUP_DIRECTION_RIGHT_)
			[managedViewController.view setFrame:CGRectOffset(ourFrame, remainder - CGRectGetMaxX(ourFrame), 0)];
		else if(revealDirection == POPUP_DIRECTION_LEFT_)
			[managedViewController.view setFrame:CGRectOffset(ourFrame, CGRectGetWidth(superBounds) - CGRectGetMinX(ourFrame) - remainder, 0)];
		else if(revealDirection == POPUP_DIRECTION_UP_)
			[managedViewController.view setFrame:CGRectOffset(ourFrame, 0, CGRectGetHeight(superBounds) - CGRectGetMinY(ourFrame) - remainder)];
		else if(revealDirection == POPUP_DIRECTION_DOWN_)
			[managedViewController.view setFrame:CGRectOffset(ourFrame, 0, remainder - CGRectGetMaxY(ourFrame))];
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
    
	if(notifyAfterHide && parentViewController && [parentViewController respondsToSelector:@selector(notifyHidPopup:)])
		[parentViewController notifyHidPopup:managedViewType];
	
	[managedViewController didHide];
    
	[managedViewController.view removeFromSuperview];
	[managedViewController setParentViewController:nil];
	[managedViewController.view setAlpha:1.0];	// Just in case it was faded - and to get it ready for next time

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
