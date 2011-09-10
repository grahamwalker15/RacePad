//
//  DriverViewController.m
//  RacePad
//
//  Created by Gareth Griffith on 12/1/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "DriverViewController.h"

#import "DriverLapListController.h"

#import "RacePadCoordinator.h"
#import "BasePadTimeController.h"
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
#import "RacePadSponsor.h"

#import "AnimationTimer.h"

#import "UIConstants.h"

@implementation DriverViewControllerTimingView

- (int) ColumnUse:(int)col;
{
	// Local override to disable interval and arrow columns
	if(col == 8 || col == 16)
		return TD_USE_FOR_NONE;
	
	return [super ColumnUse:col];
}

@end

@implementation DriverViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
 	[leaderboardView SetTableDataClass:[[RacePadDatabase Instance] leaderBoardData]];
	[leaderboardView setAssociatedTrackMapView:trackMapView];
	
	[timingView SetTableDataClass:[[RacePadDatabase Instance] driverListData]];
	
	[timingView SetRowHeight:26];
	[timingView SetHeading:true];
	[timingView SetBackgroundAlpha:0.5];
	
	[seeLapsButton setTextColour:[UIColor colorWithRed:1.0 green:0.75 blue:0.05 alpha:1.0]];
	[seeLapsButton setButtonColour:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0]];
	[seeLapsButton setShine:0.1];

	[telemetryButton setTextColour:[UIColor colorWithRed:1.0 green:0.75 blue:0.05 alpha:1.0]];
	[telemetryButton setButtonColour:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0]];
	[telemetryButton setShine:0.1];
	
	[trackProfileView setDelaysContentTouches:false];
	
	// Add tap and long press recognizers to the leaderboard
	[self addTapRecognizerToView:leaderboardView];
	[self addLongPressRecognizerToView:leaderboardView];
	
	// Add double tap recognizer to timing view for lap list
	[self addDoubleTapRecognizerToView:timingView];
	
	// Add tap recognizers to buttons to prevent them bringing up ti;e controls
	[self addTapRecognizerToView:allButton];
	[self addTapRecognizerToView:seeLapsButton];
	[self addTapRecognizerToView:telemetryButton];
	
	[[RacePadCoordinator Instance] AddView:leaderboardView WithType:RPC_LEADER_BOARD_VIEW_];
	[[RacePadCoordinator Instance] AddView:timingView WithType:RPC_DRIVER_LIST_VIEW_];
	[[RacePadCoordinator Instance] AddView:self WithType:RPC_DRIVER_GAP_INFO_VIEW_];
	
	// Create a view controller for the driver lap times which may be displayed as an overlay
	driver_lap_list_controller_ = [[DriverLapListController alloc] initWithNibName:@"DriverLapListView" bundle:nil];
	driver_lap_list_controller_displayed_ = false;
	driver_lap_list_controller_closing_ = false;
	telemetry_controller_displayed_ = false;
	
	telemetry_controller_ = [[TelemetryCarViewController alloc] initWithNibName:@"CarView" bundle:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
	if(!driver_lap_list_controller_closing_)
	{
		
		// Register the views
		[[RacePadCoordinator Instance] RegisterViewController:self WithTypeMask:( RPC_LEADER_BOARD_VIEW_ | RPC_COMMENTARY_VIEW_ | RPC_TRACK_MAP_VIEW_ | RPC_LAP_COUNT_VIEW_ | RPC_DRIVER_LIST_VIEW_ | RPC_DRIVER_GAP_INFO_VIEW_)];
		
		[[RacePadCoordinator Instance] SetViewDisplayed:leaderboardView];
		[[RacePadCoordinator Instance] SetViewDisplayed:timingView];

		[super viewWillAppear:animated];

		NSString *carToFollow = [[BasePadCoordinator Instance] nameToFollow];
		
		[trackMapView followCar:carToFollow];
		if ( ![[trackProfileView carToFollow] isEqualToString:carToFollow] )
		{
			[trackProfileView setUserOffset:0.0];
			[trackProfileView setUserScale:5.0];
			[trackProfileView RequestRedraw];
		}
		[trackProfileView followCar:carToFollow];
		[[[RacePadDatabase Instance] commentary] setCommentaryFor:carToFollow];

		DriverGapInfo * driverGapInfo = [[RacePadDatabase Instance] driverGapInfo];
		if(driverGapInfo)
		{
			if(carToFollow)
			{
				[[[RacePadDatabase Instance] driverGapInfo] setRequestedDriver:carToFollow];
				[self showDriverInfo:false];
				[self setAllSelected:false];	
			}
			else
			{
				[self hideDriverInfo:false];
				[self setAllSelected:true];	
			}
		}
		else
		{
			[self hideDriverInfo:false];
			[self setAllSelected:true];	
		}
		
		[[RacePadCoordinator Instance] SetViewDisplayed:self];

		animating = false;
		showPending = false;
		hidePending = false;
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
	
	if(telemetry_controller_displayed_)
	{
		driver_lap_list_controller_closing_ = true; // This prevents the resultant viewWillAppear from registering everything
		[self HideTelemetryAnimated:false];
	}
	
	if(!driver_lap_list_controller_closing_)
	{
		[super viewWillDisappear:animated];
		
		[[RacePadCoordinator Instance] SetViewHidden:leaderboardView];
		[[RacePadCoordinator Instance] SetViewHidden:timingView];
		[[RacePadCoordinator Instance] SetViewHidden:self];
	}
	
	driver_lap_list_controller_closing_ = false;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	if ( telemetry_controller_displayed_ )
		[telemetry_controller_ willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	if ( telemetry_controller_displayed_ )
		[telemetry_controller_ didRotateFromInterfaceOrientation:fromInterfaceOrientation];

	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)prePositionOverlays
{
	[leaderboardView setAlpha:0.0];
	[leaderboardView setHidden:false];
	
	if([trackMapView carToFollow])
	{
		[trackMapContainer setAlpha:0.0];
		[trackMapContainer setHidden:false];
	}
}

- (void) postPositionOverlays
{
	if([trackMapView carToFollow])
	{
		[trackMapContainer setAlpha:1.0];
	}

	[leaderboardView setAlpha:1.0];
}

- (void)positionOverlays
{
	// Get the device orientation and set things up accordingly
	int orientation = [[RacePadCoordinator Instance] deviceOrientation];
	
	int bg_inset = [backgroundView inset];
	CGRect bg_frame = [backgroundView frame];
	CGRect inset_frame = CGRectInset(bg_frame, bg_inset, bg_inset);

	int inset = [backgroundView inset] + 10;
	
	[allButton setFrame:CGRectMake(inset_frame.origin.x + 5, inset, 60, 40)];
	
	CGRect lb_frame = CGRectMake(inset_frame.origin.x + 5, inset_frame.origin.y + 45, 60, inset_frame.size.height - 45);
	[leaderboardView setFrame:lb_frame];
	
	int commentaryBase = 280 + inset;
	int timingHeight = 280 - inset;
	int pitWindowHeight = 200;
	
	int x0 = lb_frame.origin.x + lb_frame.size.width + inset;
		
	[timingView setFrame:CGRectMake(x0, inset, bg_frame.size.width - x0 - inset, timingHeight)];
	
	[trackProfileView setFrame:CGRectMake(x0, bg_frame.size.height - pitWindowHeight - inset, bg_frame.size.width - x0 - inset, pitWindowHeight)];

	if(commentaryExpanded)
		[commentaryView setFrame:CGRectMake(x0, commentaryBase, bg_frame.size.width - x0 - inset, bg_frame.size.height - inset - commentaryBase)];
	else
		[commentaryView setFrame:CGRectMake(x0, commentaryBase, bg_frame.size.width - x0 - inset, bg_frame.size.height - pitWindowHeight - inset * 2 - commentaryBase)];

	CGRect mapRect;
	CGRect normalMapRect;
	float mapWidth;
	float mapHeight;
	
	if(trackMapExpanded)
	{
		mapWidth = (orientation == UI_ORIENTATION_PORTRAIT_) ? 600 : 500;
		mapHeight = mapWidth / 2;
		mapRect = CGRectMake(bg_frame.size.width - inset - mapWidth, 20, mapWidth, mapHeight);
		float normalMapWidth = (orientation == UI_ORIENTATION_PORTRAIT_) ? 240 : 220;
		normalMapRect = CGRectMake(bg_frame.size.width - normalMapWidth, 20, normalMapWidth, normalMapWidth);
	}
	else
	{
		mapWidth = (orientation == UI_ORIENTATION_PORTRAIT_) ? 240 : 220;
		mapHeight = mapWidth;
		mapRect = CGRectMake(bg_frame.size.width - inset - mapWidth, 20, mapWidth, mapHeight);
		normalMapRect = mapRect;
	}
	
	[trackMapContainer setFrame:mapRect];
	
	[trackMapView setFrame:CGRectMake(0,0, mapWidth, mapHeight)];
	[trackMapSizeButton setFrame:CGRectMake(4, mapHeight - 24, 20, 20)];
		
	[self addBackgroundFrames];
}

- (void)addBackgroundFrames
{
	[super addBackgroundFrames];
	
	[backgroundView addFrame:[timingView frame]];
}


- (void)showOverlays
{
	[super showOverlays];
	[leaderboardView setHidden:false];
	[leaderboardView RequestRedraw];
	
	if([trackMapView carToFollow])
	{
		[trackMapContainer setHidden:false];
		[trackMapView RequestRedraw];
	}
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
		animationRectEnd = CGRectMake(bg_frame.size.width - inset - mapWidth, 20, mapWidth, mapWidth/2);
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
				int laps = [driverGapInfo laps];
				bool inPit = [driverGapInfo inPit];
				bool stopped = [driverGapInfo stopped];
				
				float gapAhead = [driverGapInfo gapAhead];
				float gapBehind = [driverGapInfo gapBehind];
				
				[driverFirstNameLabel setText:firstName];
				[driverSurnameLabel setText:surname];
				[driverTeamLabel setText:teamName];
				
				if(position > 0)
				{
					[positionLabel setText:[NSString stringWithFormat:@"P%d", position]];

					if(inPit)
					{
						[carAheadLabel setText:@"IN PIT"];			
						[carBehindLabel setText:@""];
						[carAheadLabel setText:@""];
						[gapAheadLabel setText:@""];
					}
					else if(stopped)
					{
						[carAheadLabel setText:@"OUT"];			
						[carBehindLabel setText:@""];
						[carAheadLabel setText:@""];
						[gapAheadLabel setText:@""];
					}
					else
					{
						if(position == 1)
						{
							[carAheadLabel setText:@"LAPS"];			
							[gapAheadLabel setText:[NSString stringWithFormat:@"%d", laps]];
						}
						else if(gapAhead > 0.0)
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
					}
				}
				else
				{
					[positionLabel setText:@""];
					[carAheadLabel setText:@""];
					[gapAheadLabel setText:@""];
					[carBehindLabel setText:@""];
					[gapBehindLabel setText:@""];
				}
			}
		}
	}
}

////////////////////////////////////////////////////////////////////////////

- (void) showDriverInfo:(bool) animated
{
	if(animating)
	{
		showPending = true;
		return;
	}
	
	if(animated && [pitBoardContainer isHidden])
	{
		animating = true;
		
		[pitBoardContainer setAlpha:0.0];
		[trackMapContainer setAlpha:0.0];
		[driverPhoto setAlpha:0.0];
		[driverTextBG setAlpha:0.0];
		[driverFirstNameLabel setAlpha:0.0];
		[driverSurnameLabel setAlpha:0.0];
		[driverTeamLabel setAlpha:0.0];
		[seeLapsButton setAlpha:0.0];
		[telemetryButton setAlpha:0.0];
		
		[pitBoardContainer setHidden:false];
		[trackMapContainer setHidden:false];
		[driverPhoto setHidden:false];
		[driverTextBG setHidden:false];
		[driverFirstNameLabel setHidden:false];
		[driverSurnameLabel setHidden:false];
		[driverTeamLabel setHidden:false];
		[seeLapsButton setHidden:false];
		[telemetryButton setHidden:!([[RacePadSponsor Instance]supportsTab:RPS_TELEMETRY_VIEW_] && [telemetry_controller_ supportsCar:[[RacePadCoordinator Instance] nameToFollow]])];
				
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:1.0];
		[timingView setAlpha:0.0];
		[pitBoardContainer setAlpha:1.0];
		[trackMapContainer setAlpha:1.0];
		[driverPhoto setAlpha:1.0];
		[driverTextBG setAlpha:1.0];
		[driverFirstNameLabel setAlpha:1.0];
		[driverSurnameLabel setAlpha:1.0];
		[driverTeamLabel setAlpha:1.0];
		[seeLapsButton setAlpha:1.0];
		[telemetryButton setAlpha:1.0];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(showDriverInfoAnimationDidStop:finished:context:)];
		[UIView commitAnimations];
	}
	else
	{
		[timingView setHidden:true];
		[pitBoardContainer setHidden:false];
		[trackMapContainer setHidden:false];
		[driverPhoto setHidden:false];
		[driverTextBG setHidden:false];
		[driverFirstNameLabel setHidden:false];
		[driverSurnameLabel setHidden:false];
		[driverTeamLabel setHidden:false];
		[pitBoardContainer setAlpha:1.0];
		[trackMapContainer setAlpha:1.0];
		[driverPhoto setAlpha:1.0];
		[driverTextBG setAlpha:1.0];
		[driverFirstNameLabel setAlpha:1.0];
		[driverSurnameLabel setAlpha:1.0];
		[driverTeamLabel setAlpha:1.0];
		[seeLapsButton setAlpha:1.0];
		[telemetryButton setAlpha:1.0];
	}
}

- (void) hideDriverInfo:(bool) animated
{
	if(animating)
	{
		hidePending = true;
		return;
	}
	if(animated && ![pitBoardContainer isHidden])
	{
		animating = true;
		
		[timingView setAlpha:0.0];
		[timingView setHidden:false];
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:1.0];
		[timingView setAlpha:1.0];
		[pitBoardContainer setAlpha:0.0];
		[trackMapContainer setAlpha:0.0];
		[driverPhoto setAlpha:0.0];
		[driverTextBG setAlpha:0.0];
		[driverFirstNameLabel setAlpha:0.0];
		[driverSurnameLabel setAlpha:0.0];
		[driverTeamLabel setAlpha:0.0];
		[seeLapsButton setAlpha:0.0];
		[telemetryButton setAlpha:0.0];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(hideDriverInfoAnimationDidStop:finished:context:)];
		[UIView commitAnimations];
	}
	else
	{
		[timingView setHidden:false];
		
		[pitBoardContainer setHidden:true];		
		[trackMapContainer setHidden:true];		
		[driverPhoto setHidden:true];		
		[driverTextBG setHidden:true];
		[driverFirstNameLabel setHidden:true];
		[driverSurnameLabel setHidden:true];
		[driverTeamLabel setHidden:true];
		[seeLapsButton setHidden:true];
		[telemetryButton setHidden:true];
	}
}

- (void) showDriverInfoAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void*)context
{
	if([finished intValue] == 1)
	{
		[timingView setHidden:true];		
		[timingView setAlpha:1.0];
		
		animating = false;
				
		if(hidePending)
			[self hideDriverInfo:false];
		
		showPending = false;
		hidePending = false;
	}
}

- (void) hideDriverInfoAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void*)context
{
	if([finished intValue] == 1)
	{
		animating = false;
		
		[pitBoardContainer setHidden:true];		
		[trackMapContainer setHidden:true];		
		[driverPhoto setHidden:true];		
		[driverTextBG setHidden:true];		
		[driverFirstNameLabel setHidden:true];
		[driverSurnameLabel setHidden:true];
		[driverTeamLabel setHidden:true];
		[seeLapsButton setHidden:true];
		[telemetryButton setHidden:true];
		
		[pitBoardContainer setAlpha:1.0];
		[trackMapContainer setAlpha:1.0];
		[driverPhoto setAlpha:1.0];
		[driverTextBG setAlpha:1.0];
		[driverFirstNameLabel setAlpha:1.0];
		[driverSurnameLabel setAlpha:1.0];
		[driverTeamLabel setAlpha:1.0];
		[seeLapsButton setAlpha:1.0];
		[telemetryButton setAlpha:1.0];
		
		// Set the driver info interest to nobody
		[[[RacePadDatabase Instance] driverGapInfo] setRequestedDriver:nil];
		
		if(showPending)
			[self showDriverInfo:false];
		
		showPending = false;
		hidePending = false;
	}
}


////////////////////////////////////////////////////////////////////////////

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
			NSString * oldCar = [trackMapView carToFollow];

			[[RacePadCoordinator Instance] setNameToFollow:name];
			[[[RacePadDatabase Instance] commentary] setCommentaryFor:name];
			[trackMapView followCar:name];
			[trackProfileView setUserOffset:0.0];
			[trackProfileView setUserScale:5.0];
			[trackProfileView followCar:name];
			[trackProfileView RequestRedraw];
			[[[RacePadDatabase Instance] driverGapInfo] setRequestedDriver:name];
			
			// Force reload of data
			[[RacePadCoordinator Instance] SetViewHidden:self];
			[[RacePadCoordinator Instance] SetViewDisplayed:self];

			if(!oldCar)
			{
				[self showDriverInfo:true];
			}
			else
			{
				[telemetryButton setHidden:!([[RacePadSponsor Instance]supportsTab:RPS_TELEMETRY_VIEW_] && [telemetry_controller_ supportsCar:[[RacePadCoordinator Instance] nameToFollow]])];
			}
						
			[trackMapView RequestRedraw];
			
			[trackProfileView setUserOffset:0.0];
			[trackProfileView RequestRedraw];			
			
			[self setAllSelected:false];	
			
			[leaderboardView RequestRedraw];

			// [commentaryView ResetScroll];
			// [[RacePadCoordinator Instance] restartCommentary];

			return;
		}
		
	}
	
	// Reach here if either tap was outside leaderboard, or no car was found at tap point
	[self handleTimeControllerGestureInView:gestureView AtX:x Y:y];
}

- (void) OnDoubleTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
	// This class just handles double taps in the timingView.
	// All others are passed to the parent.
	if(gestureView && [gestureView isKindOfClass:[DriverViewControllerTimingView class]])
	{
		int row = -1;
		int col = -1;
		
		if([(SimpleListView *)gestureView FindCellAtX:x Y:y RowReturn:&row ColReturn:&col])
		{
			bool if_heading = [(SimpleListView *)gestureView IfHeading];
			
			if(!if_heading || row != 0)
			{
				if(if_heading)
					row --;
				
				TableData * driverListData = [[RacePadDatabase Instance] driverListData];
				TableCell *cell = [driverListData cell:row Col:0];
				NSString *driver = [cell string];
				[self ShowDriverLapList:driver];
			}
		}	
	}
	else
	{
		[super OnDoubleTapGestureInView:gestureView AtX:x Y:y];
	}
}

- (IBAction) allButtonPressed:(id)sender
{
	[trackMapView followCar:nil];
	[trackProfileView setUserOffset:0.0];
	[trackProfileView setUserScale:5.0];
	[trackProfileView followCar:nil];
	[trackProfileView RequestRedraw];
	[leaderboardView RequestRedraw];	
	[[RacePadCoordinator Instance] setNameToFollow:nil];
	[[[RacePadDatabase Instance] commentary] setCommentaryFor:nil];
	[self hideDriverInfo:true];

	[commentaryView ResetScroll];
	[[RacePadCoordinator Instance] restartCommentary];
	
	[self setAllSelected:true];	
}

- (void) setAllSelected:(bool)selected
{
	if(selected)
	{
		[allButton setButtonColour:[UIColor colorWithRed:0.6 green:0.08 blue:0.4 alpha:1.0]];
		[allButton setTextColour:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
		[allButton setNeedsDisplay];
	}
	else
	{
		[allButton setButtonColour:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
		[allButton setTextColour:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]];	
		[allButton setNeedsDisplay];
	}	
}

- (IBAction) seeLapsPressed:(id)sender
{
	NSString * car = [trackMapView carToFollow];
	
	if(car && [car length] > 0)
		[self ShowDriverLapList:car];
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


- (IBAction) telemetryPressed:(id)sender
{
	NSString * car = [trackMapView carToFollow];
	
	if(car && [car length] > 0)

	if(telemetry_controller_)
	{
		// Set the driver we want displayed
		[telemetry_controller_ chooseCar:[[RacePadCoordinator Instance]nameToFollow]];
		
		// Set the style for its presentation
		[telemetry_controller_ setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
		[telemetry_controller_ setModalPresentationStyle:UIModalPresentationCurrentContext];
		
		// And present it
		[self presentModalViewController:telemetry_controller_ animated:true];
		telemetry_controller_displayed_ = true;
	}
}

- (void)HideTelemetryAnimated:(bool)animated
{
	if(telemetry_controller_displayed_)
	{
		// Set the style for its animation
		[self setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
		
		// And dismiss it
		[self dismissModalViewControllerAnimated:animated];
		telemetry_controller_displayed_ = false;
	}
}

@end


