//
//  MoveViewController.m
//  RacePad
//
//  Created by Gareth Griffith on 8/30/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import "MoveViewController.h"

#import "MatchPadCoordinator.h"
#import "BasePadTimeController.h"
#import "MatchPadTitleBarController.h"

#import "MatchPadDatabase.h"
#import "Moves.h"

#import "MoveView.h"
#import "BackgroundView.h"
#import "ShinyButton.h"
#import "MatchPadSponsor.h"

#import "AnimationTimer.h"

#import "UIConstants.h"


@implementation MoveViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[backgroundView setStyle:BG_STYLE_FULL_SCREEN_GRASS_];

	// Add tap, double tap, pan and pinch for graph
	[self addTapRecognizerToView:moveView];
	[self addDoubleTapRecognizerToView:moveView];
	[self addPanRecognizerToView:moveView];
	[self addPinchRecognizerToView:moveView];

	// Add tap recognizers to buttons to prevent them bringing up ti;e controls
	//[self addTapRecognizerToView:allButton];
	//[self addTapRecognizerToView:seeLapsButton];
	
	[[MatchPadCoordinator Instance] AddView:moveView WithType:MPC_MOVE_VIEW_];	
	[[MatchPadCoordinator Instance] AddView:self WithType:MPC_MOVE_VIEW_];
}

- (void)viewWillAppear:(BOOL)animated
{
	// Grab the title bar
	[[MatchPadTitleBarController Instance] displayInViewController:self];
	
	[super viewWillAppear:animated];
	
	[self positionOverlays];

	[[MatchPadCoordinator Instance] RegisterViewController:self WithTypeMask:( MPC_MOVE_VIEW_ )];
	
	[[MatchPadCoordinator Instance] SetViewDisplayed:moveView];
	[[MatchPadCoordinator Instance] SetViewDisplayed:self];
	
	// We disable the screen locking - because that seems to close the socket
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewWillDisappear:(BOOL)animated
{
	[[MatchPadCoordinator Instance] SetViewHidden:moveView];
	[[MatchPadCoordinator Instance] SetViewHidden:self];
	
	[[MatchPadCoordinator Instance] ReleaseViewController:self];
	
	// re-enable the screen locking
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self positionOverlays];

	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)prePositionOverlays
{
}

- (void) postPositionOverlays
{
}

- (void)positionOverlays
{
	/*
	int bg_inset = [backgroundView inset];
	CGRect bg_frame = [backgroundView frame];
	CGRect inset_frame = CGRectInset(bg_frame, bg_inset, bg_inset);
	*/
	
	[self addBackgroundFrames];
}

- (void)addBackgroundFrames
{
}


- (void)showOverlays
{
}

- (void)hideOverlays
{
}

////////////////////////////////////////////////////////////////////////////

- (void)RequestRedraw
{
	Moves * moves = [[MatchPadDatabase Instance] moves];
	
	if(moves)
	{
		/*
		// Get image list for the driver images
		RacePadDatabase *database = [RacePadDatabase Instance];
		ImageListStore * image_store = [database imageListStore];
		
		ImageList *photoImageList = image_store ? [image_store findList:@"DriverPhotos"] : nil;

		NSString * driver0 = [headToHead driver0];
		NSString * driver1 = [headToHead driver1];
		if(driver0 && [driver0 length] > 0)
		{
			if(photoImageList)
			{
				UIImage * image = [photoImageList findItem:driver0];
				if(image)
					[driverPhoto1 setImage:image];
				else
					[driverPhoto1 setImage:[UIImage imageNamed:@"NoPhoto.png"]];
			}
			else
			{
				[driverPhoto1 setImage:[UIImage imageNamed:@"NoPhoto.png"]];
			}
			
			NSString * firstName = [headToHead firstName0];
			NSString * surname = [headToHead surname0];
			NSString * teamName = [headToHead teamName0];
					
			[driverFirstNameLabel1 setText:firstName];
			[driverSurnameLabel1 setText:surname];
			[driverTeamLabel1 setText:teamName];	
		}
		else 
		{
			[driverPhoto1 setImage:[UIImage imageNamed:@"NoPhoto.png"]];
			if(driver1 && [driver1 length] > 0)
				[driverSurnameLabel1 setText:@"Leader"];
			else
				[driverSurnameLabel1 setText:@""];
			[driverFirstNameLabel1 setText:@""];
			[driverTeamLabel1 setText:@""];	
		}

		if(driver1 && [driver1 length] > 0)
		{
			if(photoImageList)
			{
				UIImage * image = [photoImageList findItem:driver1];
				if(image)
					[driverPhoto2 setImage:image];
				else
					[driverPhoto2 setImage:[UIImage imageNamed:@"NoPhoto.png"]];
			}
			else
			{
				[driverPhoto2 setImage:[UIImage imageNamed:@"NoPhoto.png"]];
			}
			
			NSString * firstName = [headToHead firstName1];
			NSString * surname = [headToHead surname1];
			NSString * teamName = [headToHead teamName1];
			
			[driverFirstNameLabel2 setText:firstName];
			[driverSurnameLabel2 setText:surname];
			[driverTeamLabel2 setText:teamName];	
		}
		else 
		{
			[driverPhoto2 setImage:[UIImage imageNamed:@"NoPhoto.png"]];
			if(driver0 && [driver0 length] > 0)
				[driverSurnameLabel2 setText:@"Leader"];
			else
				[driverSurnameLabel2 setText:@""];
			[driverFirstNameLabel2 setText:@""];
			[driverTeamLabel2 setText:@""];	
		}
		 */
	}
}

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
// Gesture recognizers

- (void) OnTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
	if([gestureView isKindOfClass:[UIButton class]]) // Prevents time controllers being invoked on button press
	{
		return;
	}
	
	// Reach here if either tap was outside leaderboard, or no car was found at tap point
	[self handleTimeControllerGestureInView:gestureView AtX:x Y:y];
}

- (void) OnPinchGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y Scale:(float)scale Speed:(float)speed
{
	if(!gestureView)
		return;
	
	if([gestureView isKindOfClass:[MoveView class]])
	{
		if(gestureStartPoint.x > [gestureView bounds].size.width - 50)
			[(MoveView *)gestureView adjustScaleY:scale X:x Y:y];	
		else
			[(MoveView *)gestureView adjustScaleX:scale X:x Y:y];	

		[(MoveView *)gestureView RequestRedraw];
	}
}

- (void) OnDoubleTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
	if(!gestureView)
		return;
	
	if([gestureView isKindOfClass:[MoveView class]])
	{
		[(MoveView *)gestureView setUserOffsetX:0.0];
		[(MoveView *)gestureView setUserScaleX:1.0];
		[(MoveView *)gestureView setUserOffsetY:0.0];
		[(MoveView *)gestureView setUserScaleY:1.0];
		[(MoveView *)gestureView RequestRedraw];
	}
}

- (void) OnPanGestureInView:(UIView *)gestureView ByX:(float)x Y:(float)y SpeedX:(float)speedx SpeedY:(float)speedy State:(int)state
{
	// Ignore lifting finger
	if(state == UIGestureRecognizerStateEnded)
		return;
	
	if([gestureView isKindOfClass:[PossessionView class]])
	{
		if(gestureStartPoint.x > [gestureView bounds].size.width - 50)
			[(MoveView *)gestureView adjustPanY:y];
		else
			[(MoveView *)gestureView adjustPanX:x];
		
		[(MoveView *)gestureView RequestRedraw];
	}
}

- (void) OnDragGestureInView:(UIView *)gestureView ByX:(float)x Y:(float)y SpeedX:(float)speedx SpeedY:(float)speedy State:(int)state Recognizer:(UIDragDropGestureRecognizer *)recognizer
{
}

@end

