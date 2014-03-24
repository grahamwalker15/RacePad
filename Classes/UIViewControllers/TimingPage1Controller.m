//
//  TimingPage1Controller.m
//  RacePad
//
//  Created by Mark Riches
//	December 2012
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "TimingPage1Controller.h"
#import "DriverLapListController.h"

#import "TimingHelpController.h"

#import "RacePadCoordinator.h"
#import "BasePadTimeController.h"
#import "RacePadTitleBarController.h"
#import "RacePadDatabase.h"
#import "TableData.h"
#import "CommentaryBubble.h"


@implementation TimingPage1Controller

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{	
	[super viewDidLoad];
	
	// Set up the table data for SimpleListView
	[timing_page_view_ SetTableDataClass:[[RacePadDatabase Instance] timingPage1]];
	
	[timing_page_view_ setStandardRowHeight:26];
	[timing_page_view_ SetHeading:false];
	[timing_page_view_ SetBackgroundAlpha:0.5];
	
	// Add gesture recognizers
 	[self addTapRecognizerToView:timing_page_view_];
	[self addDoubleTapRecognizerToView:timing_page_view_];
	[self addLongPressRecognizerToView:timing_page_view_];
	
	// Tell the RacePadCoordinator that we're interested in data for this view
	[[RacePadCoordinator Instance] AddView:timing_page_view_ WithType:RPC_TIMING_PAGE_1_];
	
	// Create a view controller for the driver lap times which may be displayed as an overlay
	driver_lap_list_controller_ = [[DriverLapListController alloc] initWithNibName:@"DriverLapListView" bundle:nil];
	driver_lap_list_controller_displayed_ = false;
	driver_lap_list_controller_closing_ = false;
	
}

- (void)viewWillAppear:(BOOL)animated;    // Called when the view is about to made visible. Default does nothing
{
	if(!driver_lap_list_controller_closing_)
	{
		// Grab the title bar and mark it as displayed
		[[RacePadTitleBarController Instance] displayInViewController:self SupportCommentary:true];
		
		// Register view
		[[RacePadCoordinator Instance] RegisterViewController:self WithTypeMask:(RPC_TIMING_PAGE_1_ | RPC_LAP_COUNT_VIEW_)];
		[[RacePadCoordinator Instance] SetViewDisplayed:timing_page_view_];
		
		[[CommentaryBubble Instance] allowBubbles:[self view] BottomRight:true];
		
	}
}

- (void)viewWillDisappear:(BOOL)animated; // Called when the view is dismissed, covered or otherwise hidden. Default does nothing
{
	if(driver_lap_list_controller_displayed_)
	{
		driver_lap_list_controller_closing_ = true; // This prevents the resultant viewWillAppear from registering everything
		[self HideDriverLapListAnimated:false];
	}
	
	if(!driver_lap_list_controller_closing_)
	{
		[[RacePadCoordinator Instance] SetViewHidden:timing_page_view_];
		[[RacePadCoordinator Instance] ReleaseViewController:self];
		
	}
	
	driver_lap_list_controller_closing_ = false;
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
	[driver_lap_list_controller_ release];
	
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
	// On double tap in lap column, show lap list
	if(double_click)
	{
		TableData * timingPage1 = [[RacePadDatabase Instance] timingPage1];
		TableCell *cell = [timingPage1 cell:row Col:2];
		NSString *driver = [cell string];
		[self ShowDriverLapList:driver];
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

- (void)ShowDriverLapList:(NSString *)driver
{
	if(driver_lap_list_controller_)
	{
		// Set the driver we want displayed
		[driver_lap_list_controller_ SetDriver:driver];
		
		// Set the style for its presentation
		[self setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
		[self setModalPresentationStyle:UIModalPresentationCurrentContext];
		
		// And present it
		[self presentViewController:driver_lap_list_controller_ animated:true completion:nil];
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
		[self dismissViewControllerAnimated:animated completion:nil];
		driver_lap_list_controller_displayed_ = false;
	}
}

@end

