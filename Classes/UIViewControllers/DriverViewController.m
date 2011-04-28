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
	[super viewDidLoad];
	
 	[leaderboardView SetTableDataClass:[[RacePadDatabase Instance] leaderBoardData]];
	
	// Add tap and long press recognizers to the leaderboard
	[self addTapRecognizerToView:leaderboardView];
	[self addLongPressRecognizerToView:leaderboardView];
	
	[[RacePadCoordinator Instance] AddView:leaderboardView WithType:RPC_LEADER_BOARD_VIEW_];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	// Register the views
	[[RacePadCoordinator Instance] RegisterViewController:self WithTypeMask:( RPC_LEADER_BOARD_VIEW_ | RPC_PIT_WINDOW_VIEW_ | RPC_COMMENTARY_VIEW_ | RPC_TRACK_MAP_VIEW_ | RPC_LAP_COUNT_VIEW_)];

	[[RacePadCoordinator Instance] SetViewDisplayed:leaderboardView];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[[RacePadCoordinator Instance] SetViewHidden:leaderboardView];
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
	
	int commentaryHeight = (orientation == UI_ORIENTATION_PORTRAIT_) ? 200 : 120;
	int x0 = lb_frame.origin.x + lb_frame.size.width + inset;
		
	if(commentaryExpanded)
		[commentaryView setFrame:CGRectMake(x0, bg_frame.size.height / 2 - 20, bg_frame.size.width - x0 - inset, bg_frame.size.height / 2 + 20 - inset)];
	else
		[commentaryView setFrame:CGRectMake(x0, bg_frame.size.height / 2 - 20, bg_frame.size.width - x0 - inset, commentaryHeight)];

	[pitWindowView setFrame:CGRectMake(x0, bg_frame.size.height / 2 + commentaryHeight - 20 + inset * 2, bg_frame.size.width - x0 - inset, bg_frame.size.height / 2  - (commentaryHeight - 20) - inset * 3)];
	
	CGRect telemetry_frame = CGRectMake(x0, inset, bg_frame.size.width - x0 - inset, bg_frame.size.height / 2 - 20 - inset * 3);
	
	CGRect mapRect;
	CGRect normalMapRect;
	float mapWidth;
	
	if(trackMapExpanded)
	{
		mapWidth = (orientation == UI_ORIENTATION_PORTRAIT_) ? 600 : 500;
		mapRect = CGRectMake(telemetry_frame.origin.x + telemetry_frame.size.width - mapWidth - 10, telemetry_frame.origin.y + 10, mapWidth, mapWidth);
		float normalMapWidth = (orientation == UI_ORIENTATION_PORTRAIT_) ? 240 : 220;
		normalMapRect = CGRectMake(telemetry_frame.origin.x + telemetry_frame.size.width - normalMapWidth -10, telemetry_frame.origin.y + (telemetry_frame.size.height - normalMapWidth) / 2, normalMapWidth, normalMapWidth);
	}
	else
	{
		mapWidth = (orientation == UI_ORIENTATION_PORTRAIT_) ? 240 : 220;
		mapRect = CGRectMake(telemetry_frame.origin.x + telemetry_frame.size.width - mapWidth -10, telemetry_frame.origin.y + (telemetry_frame.size.height - mapWidth) / 2, mapWidth, mapWidth);
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
	
	int inset = [backgroundView inset] + 10;
	CGRect bg_frame = [backgroundView frame];
		
	CGRect telemetry_frame = CGRectMake(inset, inset, bg_frame.size.width - inset * 2, bg_frame.size.height / 2 - 20 - inset * 3);
	
	trackMapExpanded = !trackMapExpanded;
	
	animationRectStart = [trackMapContainer frame];
	
	if(trackMapExpanded)
	{
		float mapWidth = (orientation == UI_ORIENTATION_PORTRAIT_) ? 600 : 500;
		animationRectEnd = CGRectMake(telemetry_frame.origin.x + telemetry_frame.size.width - mapWidth - 10, telemetry_frame.origin.y + 10, mapWidth, mapWidth);
	}
	else
	{
		float mapWidth = (orientation == UI_ORIENTATION_PORTRAIT_) ? 240 : 220;
		animationRectEnd = CGRectMake(telemetry_frame.origin.x + telemetry_frame.size.width - mapWidth -10, telemetry_frame.origin.y + (telemetry_frame.size.height - mapWidth) / 2, mapWidth, mapWidth);
	}
	
	[trackMapSizeButton setHidden:true];
	[[RacePadCoordinator Instance] DisableViewRefresh:trackMapView];
	
	[trackMapView setAnimationAlpha:0.0];
	[trackMapView setIsAnimating:true];
	[trackMapView setIsZoomView:true];
	[trackMapView setAnimationScaleTarget:backupUserScale];
	
	animationTimer = [[AnimationTimer alloc] initWithDuration:0.5 Target:self LoopSelector:@selector(trackMapSizeAnimationDidFire:) FinishSelector:@selector(trackMapSizeAnimationDidStop)];
}

@end


