//
//  PhysicalStatsController.m
//  MatchPad
//
//  Created by Simon Cuff on 15/04/2014.
//
//

#import "PhysicalStatsController.h"

#import "MatchPadCoordinator.h"
#import "BasePadTimeController.h"
#import "MatchPadTitleBarController.h"
#import "MatchPadDatabase.h"
#import "TableData.h"
#import "PlayerGraphViewController.h"


@implementation PhysicalStatsController

@synthesize home;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[backgroundView setStyle:BG_STYLE_FULL_SCREEN_GREY_];
    
	// Set up the table data for SimpleListView
	[physical_stats_view_ SetTableDataClass:[[MatchPadDatabase Instance] physicalStatsData]];
	
	[physical_stats_view_ setStandardRowHeight:26];
	[physical_stats_view_ SetHeading:true];
	[physical_stats_view_ SetBackgroundAlpha:0.5];
	[physical_stats_view_ setSmallHeadings:true];
	
	// Set ourselves as the delegate to respond to gestures in player_stats_view_
	[physical_stats_view_ setGestureDelegate:self];
	
	// Add gesture recognizers to player_stats_view_ - these will be sent to view itself and we will be notified as delegate
 	[physical_stats_view_ addTapRecognizer];
	[physical_stats_view_ addDoubleTapRecognizer];
	[physical_stats_view_ addLongPressRecognizer];
	
	home = true;
	[homeButton setButtonColour:[UIColor redColor]];
    
	// Tell the RacePadCoordinator that we're interested in data for this view
	[[MatchPadCoordinator Instance] AddView:physical_stats_view_ WithType:MPC_PHYSICAL_STATS_VIEW_];
	[[MatchPadCoordinator Instance] setPhysicalStatsController: self];
    
	// Create a view controller for the player graph which may be displayed as an overlay
	playerGraphViewController = [[PlayerGraphViewController alloc] initWithNibName:@"PlayerGraphView" bundle:nil];
	playerGraphViewControllerDisplayed = false;
	playerGraphViewControllerClosing = false;
}

- (void)viewWillAppear:(BOOL)animated;    // Called when the view is about to made visible. Default does nothing
{
	if ( !playerGraphViewControllerClosing )
	{
		// Grab the title bar and mark it as displayed
		//[[MatchPadTitleBarController Instance] displayInViewController:self];
		
		// Register view
		[[MatchPadCoordinator Instance] RegisterViewController:self WithTypeMask:(MPC_PHYSICAL_STATS_VIEW_)];
		[[MatchPadCoordinator Instance] SetViewDisplayed:physical_stats_view_];
		
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
		[[MatchPadCoordinator Instance] SetViewHidden:physical_stats_view_];
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

- (IBAction) homePressed:(id)sender
{
	[homeButton setButtonColour:[UIColor redColor]];
	[homeButton requestRedraw];
	[awayButton setButtonColour:[UIColor whiteColor]];
	[awayButton requestRedraw];
	
	home = true;
	
	[[MatchPadCoordinator Instance] SetViewHidden:physical_stats_view_];
	[[MatchPadCoordinator Instance] SetViewDisplayed:physical_stats_view_];
}

- (IBAction) awayPressed:(id)sender
{
	[awayButton setButtonColour:[UIColor redColor]];
	[awayButton requestRedraw];
	[homeButton setButtonColour:[UIColor whiteColor]];
	[homeButton requestRedraw];
	
	home = false;
	
	[[MatchPadCoordinator Instance] SetViewHidden:physical_stats_view_];
	[[MatchPadCoordinator Instance] SetViewDisplayed:physical_stats_view_];
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

//////////////////////////////////////////////////////////////////////
//  SimpleListViewDelegate methods

- (bool) SLVHandleSelectHeadingInView:(SimpleListView *)view
{
	return false;
}

- (bool) SLVHandleSelectRowInView:(SimpleListView *)view Row:(int)row DoubleClick:(bool)double_click LongPress:(bool)long_press
{
	if(view != physical_stats_view_)
		return false;
	
	if(!parentViewController)	// Shouldn't ever happen
		return false;
	
	// On double tap in lap column, show lap list
	if(double_click)
	{
		TableData * playerStatsData = [[MatchPadDatabase Instance] physicalStatsData];
		TableCell *cell = [playerStatsData cell:row Col:0];
		int player = [[cell string] intValue];
		[self ShowPlayerGraph:player];
		return true;
	}
	
	return false;
}

- (bool) SLVHandleSelectColInView:(SimpleListView *)view Col:(int)col{
	return false;
}

- (bool) SLVHandleSelectCellInView:(SimpleListView *)view Row:(int)row Col:(int)col DoubleClick:(bool)double_click LongPress:(bool)long_press
{
	return false;
}

- (bool) SLVHandleSelectBackgroundInView:(SimpleListView *)view DoubleClick:(bool)double_click LongPress:(bool)long_press
{
	return false;
}

- (void) SLVHandleTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
}

////////////////////////////////////////////////////
// Popup methods

- (void) willDisplay
{
	[[MatchPadCoordinator Instance] SetViewDisplayed:physical_stats_view_];
	
	[homeButton setTitle:[[MatchPadDatabase Instance]homeTeam] forState:UIControlStateNormal];
	[awayButton setTitle:[[MatchPadDatabase Instance]awayTeam] forState:UIControlStateNormal];
}

- (void) willHide
{
}

- (void) didDisplay
{
}

- (void) didHide
{
	[[MatchPadCoordinator Instance] SetViewHidden:physical_stats_view_];
}

@end

