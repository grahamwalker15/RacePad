//
//  TimingPage2Controller.m
//  RacePad
//
//  Created by Mark Riches
//	December 2012
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "TimingPage2Controller.h"
#import "DriverLapListController.h"

#import "TimingHelpController.h"

#import "RacePadCoordinator.h"
#import "BasePadTimeController.h"
#import "RacePadTitleBarController.h"
#import "RacePadDatabase.h"
#import "TableData.h"
#import "CommentaryBubble.h"


@implementation TimingPage2Controller

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{	
	[super viewDidLoad];
	
	// Set up the table data for SimpleListView
	[timing_page_view_ SetTableDataClass:[[RacePadDatabase Instance] timingPage2]];
	
	[timing_page_view_ setStandardRowHeight:26];
	[timing_page_view_ SetHeading:false];
	[timing_page_view_ SetBackgroundAlpha:0.5];
	
	// Add gesture recognizers
 	[self addTapRecognizerToView:timing_page_view_];
	[self addDoubleTapRecognizerToView:timing_page_view_];
	[self addLongPressRecognizerToView:timing_page_view_];
	
	// Tell the RacePadCoordinator that we're interested in data for this view
	[[RacePadCoordinator Instance] AddView:timing_page_view_ WithType:RPC_TIMING_PAGE_2_];
	
}

- (void)viewWillAppear:(BOOL)animated;    // Called when the view is about to made visible. Default does nothing
{
	// Grab the title bar and mark it as displayed
	[[RacePadTitleBarController Instance] displayInViewController:self SupportCommentary:true];
	
	// Register view
	[[RacePadCoordinator Instance] RegisterViewController:self WithTypeMask:(RPC_TIMING_PAGE_2_ | RPC_LAP_COUNT_VIEW_)];
	[[RacePadCoordinator Instance] SetViewDisplayed:timing_page_view_];
	
	[[CommentaryBubble Instance] allowBubbles:[self view] BottomRight:true];
}

- (void)viewWillDisappear:(BOOL)animated; // Called when the view is dismissed, covered or otherwise hidden. Default does nothing
{
	[[RacePadCoordinator Instance] SetViewHidden:timing_page_view_];
	[[RacePadCoordinator Instance] ReleaseViewController:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Overriden to allow any orientation.
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[[CommentaryBubble Instance] willRotateInterface];
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[[CommentaryBubble Instance] didRotateInterface];
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
	
	[[RacePadCoordinator Instance] RemoveView:self];
}

- (void)dealloc
{
    [super dealloc];
}

////////////////////////////////////////////////////////////////////////////////

- (HelpViewController *) helpController
{
	if(!helpController)
		helpController = [[TimingHelpController alloc] initWithNibName:@"TimingHelp" bundle:nil];
	
	return (HelpViewController *)helpController;
}

- (bool) HandleSelectCellRow:(int)row Col:(int)col DoubleClick:(bool)double_click LongPress:(bool)long_press
{
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

@end

