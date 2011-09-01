//
//  HeadToHeadViewController.m
//  RacePad
//
//  Created by Gareth Griffith on 8/30/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import "HeadToHeadViewController.h"

#import "DriverLapListController.h"

#import "RacePadCoordinator.h"
#import "BasePadTimeController.h"
#import "RacePadTitleBarController.h"

#import "RacePadDatabase.h"
#import "HeadToHead.h"

#import "LeaderBoardView.h"
#import "CommentaryView.h"
#import "CommentaryBubble.h"
#import "HeadToHeadView.h"
#import "BackgroundView.h"
#import "ShinyButton.h"
#import "RacePadSponsor.h"

#import "AnimationTimer.h"

#import "UIConstants.h"


@implementation HeadToHeadViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
 	[draggedDriverCell removeFromSuperview];

	[leaderboardView SetTableDataClass:[[RacePadDatabase Instance] leaderBoardData]];
	[leaderboardView setAssociatedTrackMapView:nil];
	
	//[seeLapsButton setTextColour:[UIColor colorWithRed:1.0 green:0.75 blue:0.05 alpha:1.0]];
	//[seeLapsButton setButtonColour:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0]];
	//[seeLapsButton setShine:0.1];
	
	// Add tap recognizer to the leaderboard
	[self addTapRecognizerToView:leaderboardView];
	
	// Add drag recognizers to the leaderboard and driver drop zones
	[self addDragRecognizerToView:leaderboardView];
	[self addDragRecognizerToView:driverContainer1];
	[self addDragRecognizerToView:driverContainer2];
	
	// Add tap, double tap, pan and pinch for graph
	[self addTapRecognizerToView:headToHeadView];
	[self addDoubleTapRecognizerToView:headToHeadView];
	[self addPanRecognizerToView:headToHeadView];
	[self addPinchRecognizerToView:headToHeadView];

	// Add tap recognizers to buttons to prevent them bringing up ti;e controls
	//[self addTapRecognizerToView:allButton];
	//[self addTapRecognizerToView:seeLapsButton];
	
	[[RacePadCoordinator Instance] AddView:leaderboardView WithType:RPC_LEADER_BOARD_VIEW_];
	[[RacePadCoordinator Instance] AddView:headToHeadView WithType:RPC_HEAD_TO_HEAD_VIEW_];	
	[[RacePadCoordinator Instance] AddView:self WithType:RPC_HEAD_TO_HEAD_VIEW_];
	
	// Create a view controller for the driver lap times which may be displayed as an overlay
	driver_lap_list_controller_ = [[DriverLapListController alloc] initWithNibName:@"DriverLapListView" bundle:nil];
	driver_lap_list_controller_displayed_ = false;
	driver_lap_list_controller_closing_ = false;
}

- (void)viewWillAppear:(BOOL)animated
{
	if(!driver_lap_list_controller_closing_)
	{
		// Grab the title bar
		[[RacePadTitleBarController Instance] displayInViewController:self SupportCommentary: false];
		
		[super viewWillAppear:animated];
		
		[self positionOverlays];

		[[RacePadCoordinator Instance] RegisterViewController:self WithTypeMask:( RPC_LEADER_BOARD_VIEW_ | RPC_HEAD_TO_HEAD_VIEW_ )];
		
		[[RacePadCoordinator Instance] SetViewDisplayed:leaderboardView];
		[[RacePadCoordinator Instance] SetViewDisplayed:headToHeadView];
		[[RacePadCoordinator Instance] SetViewDisplayed:self];
		
		// [[CommentaryBubble Instance] allowBubbles:backgroundView];
		[[CommentaryBubble Instance] noBubbles];
		
		// We disable the screen locking - because that seems to close the socket
		[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
		
		draggedDriverName = nil;
	}
	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewWillDisappear:(BOOL)animated
{
	if(driver_lap_list_controller_displayed_)
	{
		driver_lap_list_controller_closing_ = true; // This prevents the resultant viewWillAppear from registering everything
		[self HideDriverLapListAnimated:false];
	}
	
	if(!driver_lap_list_controller_closing_)
	{
		[[RacePadCoordinator Instance] SetViewHidden:headToHeadView];
		[[RacePadCoordinator Instance] SetViewHidden:leaderboardView];
		[[RacePadCoordinator Instance] SetViewHidden:self];
		
		[[RacePadCoordinator Instance] ReleaseViewController:self];
		
		// re-enable the screen locking
		[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
	}
	
	driver_lap_list_controller_closing_ = false;
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
	// Get the device orientation and set things up accordingly
	int orientation = [[RacePadCoordinator Instance] deviceOrientation];
	
	int bg_inset = [backgroundView inset];
	CGRect bg_frame = [backgroundView frame];
	CGRect inset_frame = CGRectInset(bg_frame, bg_inset, bg_inset);
	
	int inset = [backgroundView inset] + 10;
	
	CGRect lb_frame = CGRectMake(inset_frame.origin.x + 5, inset_frame.origin.y + 45, 60, inset_frame.size.height - 45);
	[leaderboardView setFrame:lb_frame];
	
	CGRect photoRect = [driverContainer1 bounds];
	CGRect p1_frame = CGRectMake(inset_frame.origin.x + 80, 5, photoRect.size.width, photoRect.size.height);
	[driverContainer1 setFrame:p1_frame];
	CGRect p2_frame = CGRectMake(inset_frame.origin.x + 80, inset_frame.size.height - photoRect.size.height - 5, photoRect.size.width, photoRect.size.height);
	[driverContainer2 setFrame:p2_frame];
	
	[self addBackgroundFrames];
}

- (void)addBackgroundFrames
{
}


- (void)showOverlays
{
	[leaderboardView setHidden:false];
	[leaderboardView RequestRedraw];
}

- (void)hideOverlays
{
	[leaderboardView setHidden:true];
}

////////////////////////////////////////////////////////////////////////////

- (void)RequestRedraw
{
	HeadToHead * headToHead = [[RacePadDatabase Instance] headToHead];
	
	if(headToHead)
	{
		// Get image list for the driver images
		RacePadDatabase *database = [RacePadDatabase Instance];
		ImageListStore * image_store = [database imageListStore];
		
		ImageList *photoImageList = image_store ? [image_store findList:@"DriverPhotos"] : nil;

		NSString * driver0 = [headToHead driver0];
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
		
		NSString * driver1 = [headToHead driver1];
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
	else if([gestureView isKindOfClass:[leaderboardView class]])
	{
		NSString * name = [leaderboardView carNameAtX:x Y:y];
		
		if(name && [name length] > 0)
		{
			HeadToHead * headToHead = [[RacePadDatabase Instance] headToHead];
				
			if(headToHead)
			{
				if(![headToHead driver0])
				{
					[headToHead setDriver0:name];
				}
				else
				{
					[headToHead setDriver1:name];
				}
					
				[[RacePadCoordinator Instance] SetViewHidden:self];
				[[RacePadCoordinator Instance] SetViewHidden:headToHeadView];
				[[RacePadCoordinator Instance] SetViewDisplayed:self];
				[[RacePadCoordinator Instance] SetViewDisplayed:headToHeadView];
					
			}
						
			[leaderboardView setHighlightCar:nil];
			[leaderboardView RequestRedraw];

			return;
		}
	}
	
	// Reach here if either tap was outside leaderboard, or no car was found at tap point
	[self handleTimeControllerGestureInView:gestureView AtX:x Y:y];
}

- (void) OnPinchGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y Scale:(float)scale Speed:(float)speed
{
	if(!gestureView)
		return;
	
	if([gestureView isKindOfClass:[HeadToHeadView class]])
	{
		[(HeadToHeadView *)gestureView adjustScale:scale X:x Y:y];	
		[(HeadToHeadView *)gestureView RequestRedraw];
	}
}

- (void) OnDoubleTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
	if(!gestureView)
		return;
	
	if([gestureView isKindOfClass:[HeadToHeadView class]])
	{
		[(HeadToHeadView *)gestureView setUserOffset:0.0];
		[(HeadToHeadView *)gestureView setUserScale:1.0];
		[(HeadToHeadView *)gestureView RequestRedraw];
	}
}

- (void) OnPanGestureInView:(UIView *)gestureView ByX:(float)x Y:(float)y SpeedX:(float)speedx SpeedY:(float)speedy State:(int)state
{
	// Ignore lifting finger
	if(state == UIGestureRecognizerStateEnded)
		return;
	
	if([gestureView isKindOfClass:[HeadToHeadView class]])
	{
		[(HeadToHeadView *)gestureView adjustPanX:x Y:y];	
		[(HeadToHeadView *)gestureView RequestRedraw];
	}
}

- (void) OnDragGestureInView:(UIView *)gestureView ByX:(float)x Y:(float)y SpeedX:(float)speedx SpeedY:(float)speedy State:(int)state Recognizer:(UIDragDropGestureRecognizer *)recognizer
{
	// Can drag from leaderboard to either photo container, or between photo containers
	
	HeadToHead * headToHead = [[RacePadDatabase Instance] headToHead];
	
	// Behaviour depends on state	
	switch(state)
	{
		case UIGestureRecognizerStateBegan:
		{	
			if(draggedDriverName)
			{
				[draggedDriverName release];
				draggedDriverName = nil;
			}

			if(gestureView == leaderboardView)
			{
				CGPoint point = [recognizer locationInView:leaderboardView];
				NSString * name = [leaderboardView carNameAtX:point.x Y:point.y];
					
				if(name && [name length] > 0)
				{
					draggedDriverName = [name retain];
				}
			}
			else if(gestureView == driverContainer1)
			{
				if(headToHead && [headToHead driver0] && [[headToHead driver0] length] > 0)
				{
					draggedDriverName = [[headToHead driver0] retain];
				}
			}
			else if(gestureView == driverContainer2)
			{
				if(headToHead && [headToHead driver1] && [[headToHead driver1] length] > 0)
				{
					draggedDriverName = [[headToHead driver1] retain];
				}
			}
			
			[self.view addSubview:draggedDriverCell];
			[self addDropShadowToView:draggedDriverCell WithOffsetX:5 Y:5 Blur:3];
					
			CGRect cellRect = [draggedDriverCell bounds];
			CGPoint downPoint = [recognizer locationInView:[self view]];
			CGRect dragFrame = CGRectMake(downPoint.x - cellRect.size.width / 2, downPoint.y - cellRect.size.height / 2, cellRect.size.width, cellRect.size.height);
			[draggedDriverCell setFrame:dragFrame];
					
			[draggedDriverText setText:draggedDriverName];
								
			[leaderboardView setHighlightCar:draggedDriverName];
			[leaderboardView RequestRedraw];

			break;
		}
			
		case UIGestureRecognizerStateChanged:
		{
			// Only do anything if we started properly
			if(!draggedDriverName)
				break;
			
			// Move the dragged cell
			CGRect frame = [draggedDriverCell frame];
			CGRect newFrame = CGRectOffset(frame, x, y);
			[draggedDriverCell setFrame:newFrame];
			
			break;
		}
			
		case UIGestureRecognizerStateEnded:
		{
			if(draggedDriverName)
			{
				[draggedDriverCell removeFromSuperview];

				HeadToHead * headToHead = [[RacePadDatabase Instance] headToHead];
				
				if(headToHead)
				{
				
					// Check whether we are over a drop zone
					CGPoint point = [recognizer locationInView:driverContainer1];
					
					bool dropped = false;
					
					if([driverContainer1 pointInside:point withEvent:nil])
					{
						[headToHead setDriver0:draggedDriverName];
						dropped = true;
					}
					else
					{
						point = [recognizer locationInView:driverContainer2];
						if([driverContainer2 pointInside:point withEvent:nil])
						{
							[headToHead setDriver1:draggedDriverName];
							dropped = true;
						}
					}
					
					if(dropped)
					{
						[[RacePadCoordinator Instance] SetViewHidden:self];
						[[RacePadCoordinator Instance] SetViewHidden:headToHeadView];
						[[RacePadCoordinator Instance] SetViewDisplayed:self];
						[[RacePadCoordinator Instance] SetViewDisplayed:headToHeadView];
					}
					
					[draggedDriverName release];
					draggedDriverName = nil;
					
					[leaderboardView setHighlightCar:nil];
					[leaderboardView RequestRedraw];
				}
			}
			
			break;
		}
			
		default:
			break;
	}
}

- (IBAction) seeLapsPressed:(id)sender
{
	/*
	NSString * car = [trackMapView carToFollow];
	
	if(car && [car length] > 0)
		[self ShowDriverLapList:car];
	 */
}

- (void)ShowDriverLapList:(NSString *)driver
{
	if(driver_lap_list_controller_)
	{
		// Set the driver we want displayed
		[driver_lap_list_controller_ SetDriver:driver];
		
		// Set the style for its presentation
		[driver_lap_list_controller_ setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
		[driver_lap_list_controller_ setModalPresentationStyle:UIModalPresentationCurrentContext];
		
		// And present it
		[self presentModalViewController:driver_lap_list_controller_ animated:true];
		driver_lap_list_controller_displayed_ = true;
	}
}

- (void)HideDriverLapListAnimated:(bool)animated
{
	if(driver_lap_list_controller_displayed_)
	{
		// Set the style for its animation
		[self setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
		
		// And dismiss it
		[self dismissModalViewControllerAnimated:animated];
		driver_lap_list_controller_displayed_ = false;
	}
}

@end

