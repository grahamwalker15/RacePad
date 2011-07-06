//
//  PlayerGraphViewController.m
//  MatchPad
//
//  Created by Gareth Griffith on 10/1/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "PlayerGraphViewController.h"

#import "MatchPadCoordinator.h"
#import "BasePadTimeController.h"
#import "MatchPadTitleBarController.h"
#import "MatchPadDatabase.h"
#import "PlayerGraphView.h"
#import "PlayerStatsController.h"

@implementation PlayerGraphViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
	{
		// This view is always displayed as a subview
		// Set the style for its presentation
		[self setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
		[self setModalPresentationStyle:UIModalPresentationCurrentContext];
	}
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	// Add gesture recognizers
 	[self addTapRecognizerToView:graphView];
	[self addDoubleTapRecognizerToView:graphView];
	[self addLongPressRecognizerToView:graphView];
	
	[super viewDidLoad];
	
	[self addRightSwipeRecognizerToView:swipe_catcher_view_];
	[self addLeftSwipeRecognizerToView:swipe_catcher_view_];

	[[MatchPadCoordinator Instance] AddView:graphView WithType:MPC_PLAYER_GRAPH_VIEW_];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewWillAppear:(BOOL)animated
{
	UIViewController *parent = [self parentViewController];
	// Grab the title bar
	// [[MatchPadTitleBarController Instance] displayInViewController:self];
	
	// Register the views
	[[MatchPadCoordinator Instance] RegisterViewController:self WithTypeMask:(MPC_PLAYER_GRAPH_VIEW_)];
	
	[[MatchPadCoordinator Instance] SetViewDisplayed:graphView];

	// We disable the screen locking - because that seems to close the socket
	// [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[[MatchPadCoordinator Instance] SetViewHidden:graphView];
	[[MatchPadCoordinator Instance] ReleaseViewController:self];
	
	// re-enable the screen locking
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    //[super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{	
    [super viewDidUnload];
}

////////////////////////////////////////////////////////////////////////////

- (HelpViewController *) helpController
{
	/*
	if(!helpController)
		helpController = [[MapHelpController alloc] initWithNibName:@"MapHelp" bundle:nil];
	*/
	
	return (HelpViewController *)helpController;
}

///////////////////////////////////////////////////////////////////////////

- (IBAction)BackButton:(id)sender
{
	PlayerStatsController *parent = (PlayerStatsController *)[self parentViewController];
	[parent HidePlayerGraph:true];
}

- (IBAction)PreviousButton:(id)sender
{	
	int prev = [[[MatchPadDatabase Instance] playerGraph] prevPlayer];
	if ( prev )
	{
		[[MatchPadCoordinator Instance] SetViewHidden:graphView];
		[[[MatchPadDatabase Instance] playerGraph] setRequestedPlayer:prev];
		[[MatchPadCoordinator Instance] SetViewDisplayed:graphView];
	}
}

- (IBAction)NextButton:(id)sender
{
	int next = [[[MatchPadDatabase Instance] playerGraph] nextPlayer];
	if ( next )
	{
		[[MatchPadCoordinator Instance] SetViewHidden:graphView];
		[[[MatchPadDatabase Instance] playerGraph] setRequestedPlayer:next];
		[[MatchPadCoordinator Instance] SetViewDisplayed:graphView];
	}
}

- (void) RequestRedrawForType:(int)type
{
	[title_ setTitle:[[[MatchPadDatabase Instance] playerGraph] playerName]];
}

- (void) OnDoubleTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
	[self BackButton:nil];
}

- (void) OnRightSwipeGestureInView:(UIView *)gestureView
{
	[self PreviousButton:nil];
}

- (void) OnLeftSwipeGestureInView:(UIView *)gestureView
{
	[self NextButton:nil];
}


@end
