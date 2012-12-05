    //
//  MatchPadReplaysViewController.m
//  MatchPad
//
//  Created by Gareth Griffith on 11/27/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import "MatchPadReplaysViewController.h"
#import "MatchPadVideoViewController.h"

#import "BasePadPopupManager.h"

#import "MatchPadCoordinator.h"
#import "BasePadMedia.h"

#import "AlertData.h"
#import "BasePadTimeController.h"
#import "MatchPadDatabase.h"

@implementation MatchPadReplaysViewController

- (void)viewDidLoad
{
	// Set parameters for display
	[alertView SetHeading:false];
	[alertView setStandardRowHeight:35];
	[alertView setCellYMargin:5];
	[alertView SetFont:DW_CONTROL_FONT_];
	[alertView setRowDivider:true];
	[alertView setAdaptableRowHeight:true];
	
	[alertView SetBackgroundAlpha:0.5];
	
	[alertView setDefaultTextColour:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]];
	[alertView setDefaultBackgroundColour:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
	[alertView SetSelectedColour:[UIColor colorWithRed:0.8 green:0.8 blue:1.0 alpha:0.8]];
	
	// Set ourselves as the delegate to respond to gestures in alertView
	[alertView setGestureDelegate:self];
	
	// Add gesture recognizers to alert view - these will be sent to view itself and we will be notified as delegate
 	[alertView addTapRecognizer];
	[alertView addLongPressRecognizer];

	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
	[alertView SelectRow:-1];
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
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

-(IBAction)replaySelected:(id)sender
{
}

- (IBAction) typeChosen:(id)sender
{
	int v = typeChooser.selectedSegmentIndex;
	[alertView setFilter:v Player:[[BasePadCoordinator Instance]nameToFollow]];
	[alertView ResetScroll];
	[alertView RequestRedraw];
}

- (void) dismissTimerExpired:(NSTimer *)theTimer
{
	[associatedManager hideAnimated:true Notify:true];
}

- (void)notifyMovieAttachedToView:(MovieView *)movieView	// MovieViewDelegate method
{
}

- (void)notifyMovieReadyToPlayInView:(MovieView *)movieView	// MovieViewDelegate method
{
}

//////////////////////////////////////////////////////////////////////
//  SimpleListViewDelegate methods

- (bool) SLVHandleSelectHeadingInView:(SimpleListView *)view
{
	return false;
}

- (bool) SLVHandleSelectRowInView:(SimpleListView *)view Row:(int)row DoubleClick:(bool)double_click LongPress:(bool)long_press
{
	if(view != alertView)
		return false;
	
	if(!parentViewController)	// Shouldn't ever happen
		return false;
	
	// Make sure parent has the right video screen displayed
	BasePadVideoSource * videoSource = [[BasePadMedia Instance] movieSource:1];
	
	if(videoSource && ![videoSource movieDisplayed])
	{
		if([parentViewController isKindOfClass:[MatchPadVideoViewController class]])
		{
			MatchPadVideoViewController * videoViewController = (MatchPadVideoViewController *) parentViewController;
			
			MovieView * movieView = [videoViewController findFreeMovieView];
			if(movieView)
			{
				[videoViewController prepareToAnimateMovieViews:movieView From:MV_MOVIE_FROM_RIGHT];
				[movieView setMovieViewDelegate:self];
				[movieView displayMovieSource:videoSource]; // Will get notification below when finished
				[videoViewController animateMovieViews:movieView From:MV_MOVIE_FROM_RIGHT];
			}
		}
	}

	// Then jump to the replay
	int dataRow = [ alertView filteredRowToDataRow:row];
	AlertData * alertData = [[MatchPadDatabase Instance] alertData];
	float time = [[alertData itemAtIndex:dataRow] timeStamp];
	[[MatchPadCoordinator Instance] jumpToTime:time];
	[[BasePadTimeController Instance] updateClock:time];
	
	[alertView SelectRow:row];
	[alertView RequestRedraw];
	
	[NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(dismissTimerExpired:) userInfo:nil repeats:NO];
	
	[[MatchPadCoordinator Instance] setPlaybackRate:1.0];
	[[MatchPadCoordinator Instance] prepareToPlay];
	[[MatchPadCoordinator Instance] startPlay];
	[[BasePadTimeController Instance] updatePlayButtons];
	
	return true;
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

@end
