    //
//  DriverLapListController.m
//  RacePad
//
//  Created by Gareth Griffith on 10/24/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "DriverLapListController.h"
#import "DriverListController.h"

#import "TableDataView.h"
#import "RacePadCoordinator.h"
#import "RacePadDatabase.h"
#import "TableData.h"

@implementation DriverLapListController

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
 {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
	{
		// This view is always displayed as a subview
		// Set the style for its presentation
		[self setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
		[self setModalPresentationStyle:UIModalPresentationCurrentContext];
		
		driver_ = nil;
 }
    return self;
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
 	// Set up the table data for SimpleListView
	[lap_list_view_ SetTableDataClass:[[RacePadDatabase Instance] driverData]];
	
	[lap_list_view_ SetRowHeight:26];
	[lap_list_view_ SetHeading:true];
	[lap_list_view_ SetBackgroundAlpha:0.5];

	[lap_list_view_ SetSwipingEnabled:true];
		
	// Add gesture recognizers
 	[self addTapRecognizerToView:lap_list_view_];
	[self addDoubleTapRecognizerToView:lap_list_view_];

	[self addRightSwipeRecognizerToView:swipe_catcher_view_];
	[self addLeftSwipeRecognizerToView:swipe_catcher_view_];
	
	[super viewDidLoad];
	
	// Tell the RacePadCoordinator that we will be interested in data for this view
	[[RacePadCoordinator Instance] AddView:lap_list_view_ WithType:RPC_LAP_LIST_VIEW_];
}

- (void)viewWillAppear:(BOOL)animated;    // Called when the view is about to made visible. Default does nothing
{
	[[RacePadCoordinator Instance] RegisterViewController:self WithTypeMask:RPC_LAP_LIST_VIEW_];
	[[RacePadCoordinator Instance] SetParameter:driver_ ForView:lap_list_view_];
	[[RacePadCoordinator Instance] SetViewDisplayed:lap_list_view_];
}

- (void)viewWillDisappear:(BOOL)animated; // Called when the view is dismissed, covered or otherwise hidden. Default does nothing
{
	[[RacePadCoordinator Instance] SetViewHidden:lap_list_view_];
	[[RacePadCoordinator Instance] ReleaseViewController:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Overriden to allow any orientation.
    return YES;
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
	[driver_ release];
    [super dealloc];
}


////////////////////////////////////////////////////////////////////////////////

- (void)SetDriver:(NSString *)driver
{
	if(driver_ && driver_ != driver)
		[driver_ release];
	
	driver_ = [driver retain];
}

- (IBAction)BackButton:(id)sender
{
	[(DriverListController *)[self parentViewController] HideDriverLapListAnimated:true];
}

- (IBAction)PreviousButton:(id)sender
{	
	NSString * new_driver = [[lap_list_view_ TableData] titleField:@"Prev"];
	if(new_driver && [new_driver length] > 0)
	{
		[self SetDriver:new_driver];
		[[RacePadCoordinator Instance] SetViewHidden:lap_list_view_];
		[[RacePadCoordinator Instance] SetParameter:driver_ ForView:lap_list_view_];
		[[RacePadCoordinator Instance] SetViewDisplayed:lap_list_view_];
	}
}

- (IBAction)NextButton:(id)sender
{
	NSString * new_driver = [[lap_list_view_ TableData] titleField:@"Next"];
	if(new_driver && [new_driver length] > 0)
	{
		[self SetDriver:new_driver];
		[[RacePadCoordinator Instance] SetViewHidden:lap_list_view_];
		[[RacePadCoordinator Instance] SetParameter:driver_ ForView:lap_list_view_];
		[[RacePadCoordinator Instance] SetViewDisplayed:lap_list_view_];
	}
}

- (void) RequestRedrawForType:(int)type
{
	[title_ setTitle:[[lap_list_view_ TableData] titleField:@"Title"]];
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
