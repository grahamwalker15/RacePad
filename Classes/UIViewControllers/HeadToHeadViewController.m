//
//  HeadToHeadViewController.m
//  RacePad
//
//  Created by Gareth Griffith on 12/1/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "HeadToHeadViewController.h"

#import "RacePadCoordinator.h"
#import "BasePadTimeController.h"
#import "RacePadTitleBarController.h"

#import "RacePadDatabase.h"
#import "Telemetry.h"

#import "TrackMapView.h"
#import "TelemetryView.h"
#import "CommentaryView.h"
#import "TrackProfileView.h"
#import "BackgroundView.h"
#import "ShinyButton.h"
#import "CommentaryBubble.h"
#import "DriverViewController.h"

#import "AnimationTimer.h"
#import "HeadToHeadView.h"

#import "UIConstants.h"

@implementation HeadToHeadViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// Set parameters for views
	[backgroundView setStyle:BG_STYLE_FULL_SCREEN_GREY_];
 	[leaderboard0View SetTableDataClass:[[RacePadDatabase Instance] leaderBoardData]];
 	[leaderboard1View SetTableDataClass:[[RacePadDatabase Instance] leaderBoardData]];
		
	//  Add extra gesture recognizers
	
	//	Tap recognizer for background,pit window and telemetry views
	[self addTapRecognizerToView:leaderboard0View];
	[self addTapRecognizerToView:leaderboard1View];
	[self addTapRecognizerToView:backgroundView];
	[self addTapRecognizerToView:headToHeadView];
	
	[[RacePadCoordinator Instance] AddView:headToHeadView WithType:RPC_HEAD_TO_HEAD_VIEW_];	
	[[RacePadCoordinator Instance] AddView:leaderboard0View WithType:RPC_LEADER_BOARD_VIEW_];
	[[RacePadCoordinator Instance] AddView:leaderboard1View WithType:RPC_LEADER_BOARD_VIEW_];
	[[RacePadCoordinator Instance] AddView:self WithType:RPC_HEAD_TO_HEAD_VIEW_];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Overriden to allow any orientation.
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
	// Grab the title bar
	[[RacePadTitleBarController Instance] displayInViewController:self SupportCommentary: false];
	
	// Resize overlay views to match background
	[self showOverlays];
	[self positionOverlays];
	
	// Force background refresh
	[backgroundView RequestRedraw];
		
	[[RacePadCoordinator Instance] RegisterViewController:self WithTypeMask:( RPC_LEADER_BOARD_VIEW_ | RPC_HEAD_TO_HEAD_VIEW_ )];
	
	[[RacePadCoordinator Instance] SetViewDisplayed:leaderboard0View];
	[[RacePadCoordinator Instance] SetViewDisplayed:leaderboard1View];
	[[RacePadCoordinator Instance] SetViewDisplayed:headToHeadView];
	[[RacePadCoordinator Instance] SetViewDisplayed:self];

	// [[CommentaryBubble Instance] allowBubbles:backgroundView];
	[[CommentaryBubble Instance] noBubbles];
	
	// We disable the screen locking - because that seems to close the socket
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewWillDisappear:(BOOL)animated
{
	[[RacePadCoordinator Instance] SetViewHidden:headToHeadView];
	[[RacePadCoordinator Instance] SetViewHidden:leaderboard0View];
	[[RacePadCoordinator Instance] SetViewHidden:leaderboard1View];
	[[RacePadCoordinator Instance] SetViewHidden:self];
	[[RacePadCoordinator Instance] ReleaseViewController:self];
	
	// re-enable the screen locking
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[self hideOverlays];
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[backgroundView RequestRedraw];
	
	[self prePositionOverlays];	
	[self positionOverlays];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.75];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(viewAnimationDidStop:finished:context:)];
	[self postPositionOverlays];
	[UIView commitAnimations];
	
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc
{
    [super dealloc];
}

- (HelpViewController *) helpController
{
	/*
	if(!helpController)
		helpController = [[TelemetryHelpController alloc] initWithNibName:@"TelemetryHelp" bundle:nil];
	
	return (HelpViewController *)helpController;
	*/
	
	return nil;
}

- (void) prePositionOverlays
{
	[headToHeadView setAlpha:0.0];
	[headToHeadView setHidden:false];
	[leaderboard0View setAlpha:0.0];
	[leaderboard0View setHidden:false];
	[leaderboard1View setAlpha:0.0];
	[leaderboard1View setHidden:false];
}

- (void) postPositionOverlays
{
	[headToHeadView setAlpha:1.0];
	[leaderboard0View setAlpha:1.0];
	[leaderboard1View setAlpha:1.0];
}

- (void)positionOverlays
{
	// Get the device orientation and set things up accordingly
	int orientation = [[RacePadCoordinator Instance] deviceOrientation];
	
	int bg_inset = [backgroundView inset];
	CGRect bg_frame = [backgroundView frame];
	CGRect inset_frame = CGRectInset(bg_frame, bg_inset, bg_inset);
	
	int inset = [backgroundView inset] + 10;
	
	CGRect lb_frame;
	lb_frame = CGRectMake(inset_frame.origin.x + 5, inset_frame.origin.y + 45, 60, inset_frame.size.height - 45);
	[leaderboard0View setFrame:lb_frame];
	
	int x0 = lb_frame.origin.x + lb_frame.size.width + inset;

	lb_frame = CGRectMake(inset_frame.origin.x + inset_frame.size.width - 60 - 5, inset_frame.origin.y + 45, 60, inset_frame.size.height - 45);
	[leaderboard1View setFrame:lb_frame];

	int x1 = lb_frame.origin.x - inset;
	
	[headToHeadView setFrame:CGRectMake(x0, 300, x1 - x0, 300)];
		
	[self addBackgroundFrames];
}

- (void)addBackgroundFrames
{
	[backgroundView clearFrames];
	[backgroundView addFrame:[headToHeadView frame]];
}

- (void)showOverlays
{
	[headToHeadView setHidden:false];
	[headToHeadView setAlpha:1.0];
	[leaderboard0View setHidden:false];
	[leaderboard0View RequestRedraw];
	[leaderboard1View setHidden:false];
	[leaderboard1View RequestRedraw];
}

- (void)hideOverlays
{
	[headToHeadView setHidden:true];
	[leaderboard0View setHidden:true];
	[leaderboard1View setHidden:true];
}

- (void)RequestRedraw
{
	bool driverFound = false;
	
	HeadToHead *headToHead = [[RacePadDatabase Instance] headToHead];
	
	if(headToHead)
	{
		NSString * abbr = [headToHead abbr0];
		
		if(abbr && [abbr length] > 0)
		{
			driverFound = true;
			
			// Get image list for the driver images
			RacePadDatabase *database = [RacePadDatabase Instance];
			ImageListStore * image_store = [database imageListStore];
			
			ImageList *photoImageList = image_store ? [image_store findList:@"DriverPhotos"] : nil;
			
			if(photoImageList)
			{
				UIImage * image = [photoImageList findItem:abbr];
				if(image)
					[driver0Photo setImage:image];
				else
					[driver0Photo setImage:[UIImage imageNamed:@"NoPhoto.png"]];
			}
			else
			{
				[driver0Photo setImage:[UIImage imageNamed:@"NoPhoto.png"]];
			}
			
			NSString * firstName = [headToHead firstName0];
			NSString * surname = [headToHead surname0];
			NSString * teamName = [headToHead teamName0];
			
			[driver0FirstNameLabel setText:firstName];
			[driver0SurnameLabel setText:surname];
			[driver0TeamLabel setText:teamName];
		}
		
		abbr = [headToHead abbr1];
		
		if(abbr && [abbr length] > 0)
		{
			driverFound = true;
			
			// Get image list for the driver images
			RacePadDatabase *database = [RacePadDatabase Instance];
			ImageListStore * image_store = [database imageListStore];
			
			ImageList *photoImageList = image_store ? [image_store findList:@"DriverPhotos"] : nil;
			
			if(photoImageList)
			{
				UIImage * image = [photoImageList findItem:abbr];
				if(image)
					[driver1Photo setImage:image];
				else
					[driver1Photo setImage:[UIImage imageNamed:@"NoPhoto.png"]];
			}
			else
			{
				[driver1Photo setImage:[UIImage imageNamed:@"NoPhoto.png"]];
			}
			
			NSString * firstName = [headToHead firstName1];
			NSString * surname = [headToHead surname1];
			NSString * teamName = [headToHead teamName1];
			
			[driver1FirstNameLabel setText:firstName];
			[driver1SurnameLabel setText:surname];
			[driver1TeamLabel setText:teamName];
		}
	}
}

- (void) OnTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
	if([gestureView isKindOfClass:[leaderboard0View class]])
	{
		if ( gestureView == leaderboard0View )
		{
			NSString *car = [leaderboard0View carNameAtX:x Y:y];
			[[[RacePadDatabase Instance] headToHead] setDriver0: car];
			leaderboard0View.highlightCar = car;
		}
		else
		{
			NSString *car = [leaderboard1View carNameAtX:x Y:y];
			[[[RacePadDatabase Instance] headToHead] setDriver1: car];
			leaderboard1View.highlightCar = car;
		}
		
		[leaderboard0View RequestRedraw];
		[leaderboard1View RequestRedraw];
		
		// Force reload of data
		[[RacePadCoordinator Instance] SetViewHidden:headToHeadView];
		[[RacePadCoordinator Instance] SetViewHidden:self];
		[[RacePadCoordinator Instance] SetViewDisplayed:self];
		[[RacePadCoordinator Instance] SetViewDisplayed:headToHeadView];
		return;
	}
		
	[self handleTimeControllerGestureInView:gestureView AtX:x Y:y];
}

@end


