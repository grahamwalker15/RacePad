//
//  MatchPadCodingViewController.m
//  MatchPad
//
//  Created by Simon Cuff on 14/04/2014.
//
//
#import "MatchPadCodingViewController.h"
#import "MatchPadVideoViewController.h"

#import "BasePadPopupManager.h"

#import "MatchPadCoordinator.h"
#import "BasePadMedia.h"

#import "AlertData.h"
#import "BasePadTimeController.h"
#import "MatchPadDatabase.h"

@implementation MatchPadCodingViewController

- (void)viewDidLoad
{
	// Set parameters for display
	[codingView SetHeading:false];
	[codingView setStandardRowHeight:35];
	[codingView setCellYMargin:5];
	[codingView SetFont:DW_CONTROL_FONT_];
	[codingView setRowDivider:true];
	[codingView setAdaptableRowHeight:true];
	
	[codingView SetBackgroundAlpha:0.5];
	
	[codingView setDefaultTextColour:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]];
	[codingView setDefaultBackgroundColour:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
	[codingView SetSelectedColour:[UIColor colorWithRed:0.8 green:0.8 blue:1.0 alpha:0.8]];
	
	// Set ourselves as the delegate to respond to gestures in codingView
	[codingView setGestureDelegate:self];
	
	// Add gesture recognizers to alert view - these will be sent to view itself and we will be notified as delegate
 	[codingView addTapRecognizer];
	[codingView addLongPressRecognizer];
    
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
	[codingView SelectRow:-1];
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
	[codingView setFilter:v Player:[[BasePadCoordinator Instance]nameToFollow]];
	[codingView ResetScroll];
	[codingView RequestRedraw];
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
	if(view != codingView)
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
	int dataRow = [ codingView filteredRowToDataRow:row];
	AlertData * codingData = [[MatchPadDatabase Instance] codingData];
	float time = [[codingData itemAtIndex:dataRow] timeStamp];
	[[MatchPadCoordinator Instance] jumpToTime:time - 5.0];
	[[BasePadTimeController Instance] updateClock:time - 5.0];
	
	[codingView SelectRow:row];
	[codingView RequestRedraw];
	
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
