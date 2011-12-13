//
//  PlayerStatsController.m
//  RacePad
//
//  Created by Gareth Griffith on 10/11/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "PlayerStatsController.h"

#import "MatchPadCoordinator.h"
#import "BasePadTimeController.h"
#import "MatchPadTitleBarController.h"
#import "MatchPadDatabase.h"
#import "TableData.h"
#import "PlayerGraphViewController.h"


@implementation PlayerStatsController

@synthesize home;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{	
	[super viewDidLoad];
	
	[backgroundView setStyle:BG_STYLE_FULL_SCREEN_GREY_];

	// Set up the table data for SimpleListView
	[player_stats_view_ SetTableDataClass:[[MatchPadDatabase Instance] playerStatsData]];
	
	[player_stats_view_ SetRowHeight:26];
	[player_stats_view_ SetHeading:true];
	[player_stats_view_ SetBackgroundAlpha:0.5];
	[player_stats_view_ setSmallHeadings:true];
	
	home = true;
	[homeButton setButtonColour:[UIColor redColor]];
	
	// Add gesture recognizers
 	[self addTapRecognizerToView:player_stats_view_];
	[self addDoubleTapRecognizerToView:player_stats_view_];
	[self addLongPressRecognizerToView:player_stats_view_];
	
	// Tell the RacePadCoordinator that we're interested in data for this view
	[[MatchPadCoordinator Instance] AddView:player_stats_view_ WithType:MPC_PLAYER_STATS_VIEW_];
	[[MatchPadCoordinator Instance] setPlayerStatsController: self];

	// Create a view controller for the driver lap times which may be displayed as an overlay
	playerGraphViewController = [[PlayerGraphViewController alloc] initWithNibName:@"PlayerGraphView" bundle:nil];
	playerGraphViewControllerDisplayed = false;
	playerGraphViewControllerClosing = false;
}

- (void)viewWillAppear:(BOOL)animated;    // Called when the view is about to made visible. Default does nothing
{
	if ( !playerGraphViewControllerClosing )
	{
		// Grab the title bar and mark it as displayed
		[[MatchPadTitleBarController Instance] displayInViewController:self];
		
		// Register view
		[[MatchPadCoordinator Instance] RegisterViewController:self WithTypeMask:(MPC_PLAYER_STATS_VIEW_)];
		[[MatchPadCoordinator Instance] SetViewDisplayed:player_stats_view_];
		
		[homeButton setTitle:[[MatchPadDatabase Instance]homeTeam] forState:UIControlStateNormal];
		[awayButton setTitle:[[MatchPadDatabase Instance]awayTeam] forState:UIControlStateNormal];
		
		// We disable the screen locking - because that seems to close the socket
		[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	}
}

- (void)viewWillDisappear:(BOOL)animated; // Called when the view is dismissed, covered or otherwise hidden. Default does nothing
{
	if(playerGraphViewControllerDisplayed)
	{
		playerGraphViewControllerClosing = true; // This prevents the resultant viewWillAppear from registering everything
		[self HidePlayerGraph:false];
	}
	
	if(!playerGraphViewControllerClosing)
	{
		[[MatchPadCoordinator Instance] SetViewHidden:player_stats_view_];
		[[MatchPadCoordinator Instance] ReleaseViewController:self];
	
		// re-enable the screen locking
		[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Overriden to allow any orientation.
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
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

	[[MatchPadCoordinator Instance] RemoveView:self];
}

- (void)dealloc
{
    [super dealloc];
}

////////////////////////////////////////////////////////////////////////////////

- (bool) HandleSelectCellRow:(int)row Col:(int)col DoubleClick:(bool)double_click LongPress:(bool)long_press
{
	// On double tap in lap column, show lap list
	if(double_click)
	{
		TableData * playerStatsData = [[MatchPadDatabase Instance] playerStatsData];
		TableCell *cell = [playerStatsData cell:row Col:0];
		int player = [[cell string] intValue];
		[self ShowPlayerGraph:player];
		return true;
	}
	
	return false;
}

- (bool) HandleSelectHeading
{
	return false;
}

- (void) HandleTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
	[self handleTimeControllerGestureInView:gestureView AtX:x Y:y];
}
	 
- (IBAction) homePressed:(id)sender
{
	[homeButton setButtonColour:[UIColor redColor]];
	[homeButton requestRedraw];
	[awayButton setButtonColour:[UIColor whiteColor]];
	[awayButton requestRedraw];
	
	home = true;
	
	[[MatchPadCoordinator Instance] SetViewHidden:player_stats_view_];
	[[MatchPadCoordinator Instance] SetViewDisplayed:player_stats_view_];
}
	 
 - (IBAction) awayPressed:(id)sender
{
	[awayButton setButtonColour:[UIColor redColor]];
	[awayButton requestRedraw];
	[homeButton setButtonColour:[UIColor whiteColor]];
	[homeButton requestRedraw];
	
	home = false;
	
	[[MatchPadCoordinator Instance] SetViewHidden:player_stats_view_];
	[[MatchPadCoordinator Instance] SetViewDisplayed:player_stats_view_];
}

- (void)ShowPlayerGraph:(int)player
{
	if(playerGraphViewController)
	{
		// Set the driver we want displayed
		[[[MatchPadDatabase Instance]playerGraph] setRequestedPlayer:player];
		
		// Set the style for its presentation
		[self setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
		[self setModalPresentationStyle:UIModalPresentationCurrentContext];
		
		// And present it
		[self presentModalViewController:playerGraphViewController animated:true];
		playerGraphViewControllerDisplayed = true;
	}
}

- (void)HidePlayerGraph:(bool)animated
{
	if(playerGraphViewControllerDisplayed)
	{
		// Set the style for its animation
		[self setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
		
		// And dismiss it
		[self dismissModalViewControllerAnimated:animated];
		playerGraphViewControllerDisplayed = false;
	}
}

@end

