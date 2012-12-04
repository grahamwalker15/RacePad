    //
//  TeamStatsViewController.m
//  MatchPad
//
//  Created by Gareth Griffith on 12/3/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import "TeamStatsViewController.h"
#import "MatchPadCoordinator.h"

@implementation TeamStatsViewController

- (void)viewDidLoad
{
	// Set parameters for display
	[[MatchPadCoordinator Instance] AddView:team_stats_view_ WithType:MPC_TEAM_STATS_VIEW_];	
	[[MatchPadCoordinator Instance] AddView:self WithType:MPC_TEAM_STATS_VIEW_];

	[super viewDidLoad];
}

- (void)willDisplay
{
	[super willDisplay];
	
	[[MatchPadCoordinator Instance] SetViewDisplayed:team_stats_view_];
	[[MatchPadCoordinator Instance] SetViewDisplayed:self];
	
}

- (void)willHide
{
	[[MatchPadCoordinator Instance] SetViewHidden:team_stats_view_];
	[[MatchPadCoordinator Instance] SetViewHidden:self];
	
	[[MatchPadCoordinator Instance] ReleaseViewController:self];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
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

////////////////////////////////////////////////////////////////////////////

@end
