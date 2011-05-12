//
//  DriverViewController.m
//  RacePad
//
//  Created by Gareth Griffith on 12/1/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "DriverViewController.h"

#import "RacePadCoordinator.h"
#import "RacePadTimeController.h"
#import "RacePadTitleBarController.h"

#import "TelemetryHelpController.h"

#import "RacePadDatabase.h"
#import "Telemetry.h"
#import "PitWindow.h"
#import "DriverGapInfo.h"

#import "TrackMapView.h"
#import "LeaderBoardView.h"
#import "CommentaryView.h"
#import "PitWindowView.h"
#import "BackgroundView.h"
#import "ShinyButton.h"

#import "AnimationTimer.h"

#import "UIConstants.h"

@implementation DriverViewController

- (void)viewDidLoad
{
	[self setCar:-1];
	[super viewDidLoad];
	
 	[leaderboardView SetTableDataClass:[[RacePadDatabase Instance] leaderBoardData]];
	[leaderboardView setAssociatedTrackMapView:trackMapView];
	
	// Add tap and long press recognizers to the leaderboard
	[self addTapRecognizerToView:leaderboardView];
	[self addLongPressRecognizerToView:leaderboardView];
	
	[[RacePadCoordinator Instance] AddView:leaderboardView WithType:RPC_LEADER_BOARD_VIEW_];
	[[RacePadCoordinator Instance] AddView:commentaryView WithType:RPC_COMMENTARY_VIEW_];
	[[RacePadCoordinator Instance] AddView:self WithType:RPC_DRIVER_GAP_INFO_VIEW_];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	// Register the views
	[[RacePadCoordinator Instance] RegisterViewController:self WithTypeMask:( RPC_LEADER_BOARD_VIEW_ | RPC_PIT_WINDOW_VIEW_ | RPC_COMMENTARY_VIEW_ | RPC_TRACK_MAP_VIEW_ | RPC_LAP_COUNT_VIEW_ | RPC_DRIVER_GAP_INFO_VIEW_)];

	
	[[RacePadCoordinator Instance] SetViewDisplayed:leaderboardView];
	[[RacePadCoordinator Instance] SetViewDisplayed:self];

	DriverGapInfo * driverGapInfo = [[RacePadDatabase Instance] driverGapInfo];
	if(driverGapInfo)
	{
		NSString * requestedDriver = [driverGapInfo requestedDriver];
		
		if(requestedDriver && [requestedDriver length] > 0)
			[self showDriverInfo:false];
		else
			[self hideDriverInfo:false];
	}
	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[[RacePadCoordinator Instance] SetViewHidden:leaderboardView];
	[[RacePadCoordinator Instance] SetViewHidden:self];
}

- (void)prePositionOverlays
{
	[leaderboardView setAlpha:0.0];
	[leaderboardView setHidden:false];
}

- (void) postPositionOverlays
{
	[leaderboardView setAlpha:1.0];
}

- (void)positionOverlays
{
	// Get the device orientation and set things up accordingly
	int orientation = [[RacePadCoordinator Instance] deviceOrientation];
	
	int bg_inset = [backgroundView inset];
	CGRect bg_frame = [backgroundView frame];
	CGRect inset_frame = CGRectInset(bg_frame, bg_inset, bg_inset);

	CGRect lb_frame = CGRectMake(inset_frame.origin.x + 5, inset_frame.origin.y, 60, inset_frame.size.height);
	[leaderboardView setFrame:lb_frame];
	
	int inset = [backgroundView inset] + 10;
	
	int commentaryBase = 280 + inset;
	int pitWindowHeight = 200;
	
	int x0 = lb_frame.origin.x + lb_frame.size.width + inset;
		
	[trackProfileView setFrame:CGRectMake(x0, bg_frame.size.height - pitWindowHeight - inset, bg_frame.size.width - x0 - inset, pitWindowHeight)];

	if(commentaryExpanded)
		[commentaryView setFrame:CGRectMake(x0, commentaryBase, bg_frame.size.width - x0 - inset, bg_frame.size.height - inset - commentaryBase)];
	else
		[commentaryView setFrame:CGRectMake(x0, commentaryBase, bg_frame.size.width - x0 - inset, bg_frame.size.height - pitWindowHeight - inset * 2 - commentaryBase)];

	CGRect mapRect;
	CGRect normalMapRect;
	float mapWidth;
	
	if(trackMapExpanded)
	{
		mapWidth = (orientation == UI_ORIENTATION_PORTRAIT_) ? 600 : 500;
		mapRect = CGRectMake(bg_frame.size.width - inset - mapWidth, 20, mapWidth, mapWidth);
		float normalMapWidth = (orientation == UI_ORIENTATION_PORTRAIT_) ? 240 : 220;
		normalMapRect = CGRectMake(bg_frame.size.width - normalMapWidth, 20, normalMapWidth, normalMapWidth);
	}
	else
	{
		mapWidth = (orientation == UI_ORIENTATION_PORTRAIT_) ? 240 : 220;
		mapRect = CGRectMake(bg_frame.size.width - inset - mapWidth, 20, mapWidth, mapWidth);
		normalMapRect = mapRect;
	}
	
	[trackMapContainer setFrame:mapRect];
	
	[trackMapView setFrame:CGRectMake(0,0, mapWidth, mapWidth)];
	[trackMapSizeButton setFrame:CGRectMake(4, mapWidth - 24, 20, 20)];
		
	[self addBackgroundFrames];
}

- (void)addBackgroundFrames
{
	[super addBackgroundFrames];
}

- (void)showOverlays
{
	[super showOverlays];
	[leaderboardView setHidden:false];
	[leaderboardView RequestRedraw];
}

- (void)hideOverlays
{
	[super hideOverlays];
	[leaderboardView setHidden:true];
}

- (IBAction) trackMapSizeChanged
{
	// Make sure we don't animate twice
	if([trackMapView isAnimating])
		return;
	
	// Get the device orientation and set things up accordingly
	int orientation = [[RacePadCoordinator Instance] deviceOrientation];
	
	CGRect bg_frame = [backgroundView frame];
	int inset = [backgroundView inset] + 10;

	trackMapExpanded = !trackMapExpanded;
	
	animationRectStart = [trackMapContainer frame];
	
	if(trackMapExpanded)
	{
		float mapWidth = (orientation == UI_ORIENTATION_PORTRAIT_) ? 600 : 500;
		animationRectEnd = CGRectMake(bg_frame.size.width - inset - mapWidth, 20, mapWidth, mapWidth);
	}
	else
	{
		float mapWidth = (orientation == UI_ORIENTATION_PORTRAIT_) ? 240 : 220;
		animationRectEnd = CGRectMake(bg_frame.size.width - inset - mapWidth, 20, mapWidth, mapWidth);
	}
	
	[trackMapSizeButton setHidden:true];
	[[RacePadCoordinator Instance] DisableViewRefresh:trackMapView];
	
	[trackMapView setAnimationAlpha:0.0];
	[trackMapView setIsAnimating:true];
	[trackMapView setIsZoomView:true];
	[trackMapView setAnimationScaleTarget:backupUserScale];
	
	animationTimer = [[AnimationTimer alloc] initWithDuration:0.5 Target:self LoopSelector:@selector(trackMapSizeAnimationDidFire:) FinishSelector:@selector(trackMapSizeAnimationDidStop)];
}

////////////////////////////////////////////////////////////////////////////

- (void)RequestRedraw
{
	bool driverFound = false;
	
	DriverGapInfo * driverGapInfo = [[RacePadDatabase Instance] driverGapInfo];
	
	if(driverGapInfo)
	{
		NSString * requestedDriver = [driverGapInfo requestedDriver];
		
		if(requestedDriver && [requestedDriver length] > 0)
		{
			NSString * abbr = [driverGapInfo abbr];
			
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
						[driverPhoto setImage:image];
					else
						[driverPhoto setImage:[UIImage imageNamed:@"NoPhoto.png"]];
				}
				else
				{
					[driverPhoto setImage:[UIImage imageNamed:@"NoPhoto.png"]];
				}
				
				ImageList *helmetImageList = image_store ? [image_store findList:@"DriverHelmets"] : nil;
				
				if(helmetImageList)
				{
					UIImage * image = [helmetImageList findItem:abbr];
					if(image)
						[driverHelmet setImage:image];
					else
						[driverHelmet setImage:[UIImage imageNamed:@"NoHelmet.png"]];
				}
				else
				{
					[driverHelmet setImage:[UIImage imageNamed:@"NoHelmet.png"]];
				}
				
				NSString * firstName = [driverGapInfo firstName];
				NSString * surname = [driverGapInfo surname];
				NSString * teamName = [driverGapInfo teamName];
				
				NSString * carAhead = [driverGapInfo carAhead];
				NSString * carBehind = [driverGapInfo carBehind];
				
				int position = [driverGapInfo position];
				
				float gapAhead = [driverGapInfo gapAhead];
				float gapBehind = [driverGapInfo gapBehind];
				
				[driverFirstNameLabel setText:firstName];
				[driverSurnameLabel setText:surname];
				[driverTeamLabel setText:teamName];
				
				[positionLabel setText:[NSString stringWithFormat:@"P%d", position]];
				
				if(gapAhead > 0.0)
				{
					[carAheadLabel setText:carAhead];			
					[gapAheadLabel setText:[NSString stringWithFormat:@"+%.1f", gapAhead]];
				}
				else
				{
					[carAheadLabel setText:@""];
					[gapAheadLabel setText:@""];
				}

				if(gapBehind > 0.0)
				{
					[carBehindLabel setText:carBehind];
					[gapBehindLabel setText:[NSString stringWithFormat:@"-%.1f", gapBehind]];
				}
				else
				{
					[carBehindLabel setText:@""];
					[gapBehindLabel setText:@""];
				}
				
				[pitBoardContainer setHidden:false];
				[trackMapContainer setHidden:false];
				
				[driverPhoto setHidden:false];
				[driverTextBG setHidden:false];
				
				[driverFirstNameLabel setHidden:false];
				[driverSurnameLabel setHidden:false];
				[driverTeamLabel setHidden:false];
			}
		}
	}
	
	if(!driverFound)
	{
		[pitBoardContainer setHidden:true];
		[trackMapContainer setHidden:true];
		
		[driverPhoto setHidden:true];
		[driverTextBG setHidden:true];
		
		[driverFirstNameLabel setHidden:true];
		[driverSurnameLabel setHidden:true];
		[driverTeamLabel setHidden:true];
	}
}

////////////////////////////////////////////////////////////////////////////

- (void) showDriverInfo:(bool) animated
{
	if(![pitBoardContainer isHidden])
		return;

	if(animated)
	{
		[pitBoardContainer setAlpha:0.0];
		[trackMapContainer setAlpha:0.0];
		[driverPhoto setAlpha:0.0];
		[driverTextBG setAlpha:0.0];
		[driverFirstNameLabel setAlpha:0.0];
		[driverSurnameLabel setAlpha:0.0];
		[driverTeamLabel setAlpha:0.0];
		
		[pitBoardContainer setHidden:false];
		[trackMapContainer setHidden:false];
		[driverPhoto setHidden:false];
		[driverTextBG setHidden:false];
		[driverFirstNameLabel setHidden:false];
		[driverSurnameLabel setHidden:false];
		[driverTeamLabel setHidden:false];
				
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:1.0];
		[pitBoardContainer setAlpha:1.0];
		[trackMapContainer setAlpha:1.0];
		[driverPhoto setAlpha:1.0];
		[driverTextBG setAlpha:1.0];
		[driverFirstNameLabel setAlpha:1.0];
		[driverSurnameLabel setAlpha:1.0];
		[driverTeamLabel setAlpha:1.0];
		[UIView commitAnimations];
	}
	else
	{
		[pitBoardContainer setHidden:false];
		[trackMapContainer setHidden:false];
		[driverPhoto setHidden:false];
		[driverTextBG setHidden:false];
		[driverFirstNameLabel setHidden:false];
		[driverSurnameLabel setHidden:false];
		[driverTeamLabel setHidden:false];
	}
}

- (void) hideDriverInfo:(bool) animated
{
	if([pitBoardContainer isHidden])
		return;
	
	if(animated)
	{
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:1.0];
		[pitBoardContainer setAlpha:0.0];
		[trackMapContainer setAlpha:0.0];
		[driverPhoto setAlpha:0.0];
		[driverTextBG setAlpha:0.0];
		[driverFirstNameLabel setAlpha:0.0];
		[driverSurnameLabel setAlpha:0.0];
		[driverTeamLabel setAlpha:0.0];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(hideZoomMapAnimationDidStop:finished:context:)];
		[UIView commitAnimations];
	}
	else
	{
		[pitBoardContainer setHidden:true];		
		[trackMapContainer setHidden:true];		
		[driverPhoto setHidden:true];		
		[driverTextBG setHidden:true];
		[driverFirstNameLabel setHidden:true];
		[driverSurnameLabel setHidden:true];
		[driverTeamLabel setHidden:true];
	}
}

- (void) hideDriverInfoAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void*)context
{
	if([finished intValue] == 1)
	{
		[pitBoardContainer setHidden:true];		
		[trackMapContainer setHidden:true];		
		[driverPhoto setHidden:true];		
		[driverTextBG setHidden:true];		
		[driverFirstNameLabel setHidden:true];
		[driverSurnameLabel setHidden:true];
		[driverTeamLabel setHidden:true];

		[pitBoardContainer setAlpha:1.0];
		[driverPhoto setAlpha:1.0];
		[driverTextBG setAlpha:1.0];
		[driverFirstNameLabel setAlpha:1.0];
		[driverSurnameLabel setAlpha:1.0];
		[driverTeamLabel setAlpha:1.0];
	}
}


////////////////////////////////////////////////////////////////////////////

- (void) OnTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
	if([gestureView isKindOfClass:[leaderboardView class]])
	{
		NSString * name = [leaderboardView carNameAtX:x Y:y];
		
		if(name && [name length] > 0)
		{
			if([[trackMapView carToFollow] isEqualToString:name])
			{
				[trackMapView followCar:nil];
				[trackProfileView followCar:nil];
				[leaderboardView RequestRedraw];
				
				[[[RacePadDatabase Instance] driverGapInfo] setRequestedDriver:nil];
				[self hideDriverInfo:true];
				
				[[RacePadCoordinator Instance] SetParameter:@"RACE" ForView:commentaryView];
			}
			else
			{
				[trackMapView followCar:name];
				[trackProfileView followCar:name];
				[[[RacePadDatabase Instance] driverGapInfo] setRequestedDriver:name];
				[self showDriverInfo:true];

				[[RacePadCoordinator Instance] SetParameter:trackMapView.carToFollow ForView:commentaryView];
							
				[trackMapView setUserScale:10.0];
				[trackMapView RequestRedraw];
			}
			
			// Force redraw by setting view to hidden then displayed
			[[RacePadCoordinator Instance] SetViewHidden:self];
			[[RacePadCoordinator Instance] SetViewDisplayed:self];

			[leaderboardView RequestRedraw];

			[[RacePadCoordinator Instance] restartCommentary];
			[commentaryView RequestRedraw];

			return;
		}
		
	}
	
	// Reach here if either tap was outside leaderboard, or no car was found at tap point
	RacePadTimeController * time_controller = [RacePadTimeController Instance];
	
	if(![time_controller displayed])
	{
		[time_controller displayInViewController:self Animated:true];
	}
	else
	{
		[time_controller hide];
	}
}

@end


