    //
//  MidasAlertsViewController.m
//  MidasDemo
//
//  Created by Gareth Griffith on 1/9/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import "MidasAlertsViewController.h"
#import "MidasPopupManager.h"
#import "AlertData.h"
#import "RacePadCoordinator.h"
#import "BasePadTimeController.h"
#import "MidasVideoViewController.h"
#import "MovieView.h"
#import "RacePadDatabase.h"


@implementation MidasAlertsViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[alertView SetHeading:false];
	[alertView setStandardRowHeight:35];
	[alertView setCellYMargin:10];
	[alertView SetFont:DW_CONTROL_FONT_];
	[alertView setDefaultTextColour:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
	[alertView setDefaultBackgroundColour:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.5]];
	[alertView SetSelectedColour:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8]];
	[alertView SetBackgroundAlpha:0.75];
	[alertView setRowDivider:true];
	[alertView setExpansionRowHeight:CGRectGetHeight(expansionView.bounds)];
	[alertView setExpansionAllowed:true];
	[alertView setAdaptableRowHeight:true];
	
	[expansionView setHidden:true];
	[alertView addSubview:expansionView];

	// Add gesture recognizers
 	[self addTapRecognizerToView:alertView];
	[self addDoubleTapRecognizerToView:alertView];
	
 	[self addTapRecognizerToView:movieSelectorView];
	
}

- (void)viewWillAppear:(BOOL)animated
{
	[alertView SelectRow:-1];
	[self UpdateList];
	[super viewWillAppear:animated];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Overriden to allow any orientation.
    return NO;
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
    [super dealloc];
}

//////////////////////////////////////////////////////////////////////
//  Methods for this class

- (bool) HandleSelectRow:(int)row DoubleClick:(bool)double_click LongPress:(bool)long_press
{
	int dataRow = [ alertView filteredRowToDataRow:row];
	
	bool wasExpanded = [alertView RowExpanded:row];
	
	[alertView UnexpandAllRows];
	[alertView setExpandedDataRow:-1];
	[expansionView setHidden:true];
	
	//UIImage * renderedView = [self renderViewToImage:container];
	//[viewAnimationImage setImage:renderedView];
	//[viewAnimationImage setFrame:[standingsView frame]];
	//[viewAnimationImage setHidden:false]; 
	
	if(!wasExpanded)
	{
		[alertView SetRow:row Expanded:true];
		[alertView setExpandedDataRow:dataRow];
		[self placeExpansionViewAtRow:row];
	}
	
	[alertView SelectRow:row];
	[alertView RequestRedraw];

	return true;
}

- (void) dismissTimerExpired:(NSTimer *)theTimer
{
	[[MidasAlertsManager Instance] hideAnimated:true Notify:true];
}

- (void) UpdateList
{
	int v = typeChooser.selectedSegmentIndex;
	[alertView setFilter:v Driver:[[BasePadCoordinator Instance]nameToFollow]];
	[alertView ResetScroll];
	[alertView RequestRedraw];
}

- (IBAction) typeChosen:(id)sender
{
	[self UpdateList];
}

// Action callbacks

- (void) OnTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
	int row = -1;
	int col = -1;
	
	if(gestureView == alertView)
	{
		if([(SimpleListView *)gestureView FindCellAtX:x Y:y RowReturn:&row ColReturn:&col])
		{
			bool if_heading = [(SimpleListView *)gestureView IfHeading];
			
			if(!if_heading || row > 0)
			{
				if(if_heading)
					row --;
				
				[self HandleSelectRow:row DoubleClick:false LongPress:false];
			}
		}
	}
	else if(gestureView == movieSelectorView)
	{
		int row, col;
		
		if([(SimpleListView *)gestureView FindCellAtX:x Y:y RowReturn:&row ColReturn:&col])
		{
			BasePadVideoSource * videoSource = [movieSelectorView GetMovieSourceAtCol:col];
			
			if(videoSource)
			{
				BasePadViewController * parentViewController = [[MidasAlertsManager Instance] parentViewController];
				
				if(parentViewController && [parentViewController isKindOfClass:[MidasVideoViewController class]])
				{
					MidasVideoViewController * videoViewController = (MidasVideoViewController *) parentViewController;
					
					MovieView * movieView = [videoViewController findFreeMovieView];
					if(movieView)
					{
						int dataRow = [alertView expandedDataRow];
						if(dataRow >= 0)
						{
							AlertData * alertData = [[RacePadDatabase Instance] alertData];
							float time = [[alertData itemAtIndex:dataRow] timeStamp];
							[[RacePadCoordinator Instance] jumpToTime:time];
							[[BasePadTimeController Instance] updateClock:time];
							 
							[NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(dismissTimerExpired:) userInfo:nil repeats:NO];
							 
							[[RacePadCoordinator Instance] setPlaybackRate:1.0];
							[[RacePadCoordinator Instance] prepareToPlay];
							[[RacePadCoordinator Instance] startPlay];
							[[BasePadTimeController Instance] updatePlayButtons];

							if(![videoSource movieDisplayed])
							{
								[videoViewController prepareToAnimateMovieViews:movieView From:MV_MOVIE_FROM_BOTTOM];
								[movieView setMovieViewDelegate:self];
								[movieView displayMovieSource:videoSource]; // Will get notification below when finished
							}
							
						}
						
					}
				}
			}
		}
	}
	else 
	{
		[super OnTapGestureInView:gestureView AtX:x Y:y];
	}	
}

- (void)notifyMovieAttachedToView:(MovieView *)movieView	// MovieViewDelegate method
{
	BasePadViewController * parentViewController = [[MidasAlertsManager Instance] parentViewController];
	
	if(parentViewController && [parentViewController isKindOfClass:[MidasVideoViewController class]])
		[(MidasVideoViewController *) parentViewController animateMovieViews:movieView From:MV_MOVIE_FROM_BOTTOM];
}

- (void)notifyMovieReadyToPlayInView:(MovieView *)movieView	// MovieViewDelegate method
{
}


- (void) OnDoubleTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
	int row = -1;
	int col = -1;
	
	if(gestureView && [gestureView isKindOfClass:[SimpleListView class]])
	{
		if([(SimpleListView *)gestureView FindCellAtX:x Y:y RowReturn:&row ColReturn:&col])
		{
			bool if_heading = [(SimpleListView *)gestureView IfHeading];
			
			if(!if_heading || row > 0)
			{
				if(if_heading)
					row --;
				
				[self HandleSelectRow:row DoubleClick:true LongPress:false];
			}
		}
	}
	else 
	{
		[super OnDoubleTapGestureInView:gestureView AtX:x Y:y];
	}
}

- (void) OnLongPressGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
	int row = -1;
	int col = -1;
	
	if(gestureView && [gestureView isKindOfClass:[SimpleListView class]])
	{
		if([(SimpleListView *)gestureView FindCellAtX:x Y:y RowReturn:&row ColReturn:&col])
		{
			bool if_heading = [(SimpleListView *)gestureView IfHeading];
			
			if(!if_heading || row > 0)
			{
				if(if_heading)
					row --;
				
				[self HandleSelectRow:row DoubleClick:false LongPress:true];
			}
		}
	}
	else 
	{
		[super OnLongPressGestureInView:gestureView AtX:x Y:y];
	}
}

- (void) placeExpansionViewAtRow:(int)row
{
	float y = [alertView TableHeightToRow:row - 1] + [alertView MaxContentRowHeight:row];
	[expansionView setFrame:CGRectMake(0, y, CGRectGetWidth(expansionView.bounds), CGRectGetHeight(expansionView.bounds))];
	[expansionView setHidden:false];
}

@end

@implementation MidasAlertsView

@synthesize parentController;
@synthesize expansionView;
@synthesize expandedDataRow;

- (int) ColumnWidth:(int)col;
{
	switch (col)
	{
		case 0:
			return 35;
		case 1:
			return 25;
		case 2:
			return 240;
		case 3:
			return 0;
		case 4:
			return 0;
		default:
			return 0;
	}
}


@end

@implementation MidasAlertsExpansionView
@end


