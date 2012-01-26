//
//  MidasFollowDriverViewController.m
//  MidasDemo
//
//  Created by Gareth Griffith on 1/7/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import "MidasFollowDriverViewController.h"
#import "MidasPopupManager.h"

#import "RacePadDatabase.h"
#import "RacePadCoordinator.h"

#import "TrackMapView.h"
#import "LeaderboardView.h"
#import "BackgroundView.h"

#import "BasePadMedia.h"
#import "MidasVideoViewController.h"

@implementation MidasFollowDriverViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	driverToFollow = nil;
	
	// Set up the table data for SimpleListView
	[lapTimesView SetTableDataClass:[[RacePadDatabase Instance] driverData]];
	
	expanded = false;
	[extensionContainer setHidden:true];
	
	[lapTimesView SetFont:DW_LIGHT_LARGER_CONTROL_FONT_];
	[lapTimesView setStandardRowHeight:26];
	[lapTimesView SetHeading:true];
	[lapTimesView SetBackgroundAlpha:0.25];
	[lapTimesView setRowDivider:true];
	[lapTimesView setCellYMargin:3];
	
 	[leaderboardView SetTableDataClass:[[RacePadDatabase Instance] leaderBoardData]];
	[leaderboardView setAssociatedTrackMapView:trackMapView];
	[leaderboardView setSmallDisplay:true];
	
	// Set parameters for views
	[trackMapView setIsZoomView:true];
	[trackMapView setSmallSized:true];
	
	[trackMapView setUserScale:10.0];
	[trackMapContainer setStyle:BG_STYLE_TRANSPARENT_];
		
	//  Add extra gesture recognizers
		
    //	Tap, pinch, and double tap recognizers for map
	[self addTapRecognizerToView:trackMapView];
	[self addPinchRecognizerToView:trackMapView];
	[self addDoubleTapRecognizerToView:trackMapView];
	
	// Add tap and long press recognizers to the leaderboard
	[self addTapRecognizerToView:leaderboardView];
	[self addLongPressRecognizerToView:leaderboardView];
	
	// Set paramters for views
	[trackMapContainer setBackgroundColor:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.3]];
	
	// Tell the RacePadCoordinator that we will be interested in data for views
	[[RacePadCoordinator Instance] AddView:lapTimesView WithType:RPC_LAP_LIST_VIEW_];
	[[RacePadCoordinator Instance] AddView:trackMapView WithType:RPC_TRACK_MAP_VIEW_];
	[[RacePadCoordinator Instance] AddView:leaderboardView WithType:RPC_LEADER_BOARD_VIEW_];
	[[RacePadCoordinator Instance] AddView:self WithType:RPC_DRIVER_GAP_INFO_VIEW_];			
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

- (void) expandView
{
	if(expanded)
		return;
	
	id parentViewController = [[MidasFollowDriverManager Instance] parentViewController];

	[extensionContainer setHidden:false];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	
	[[MidasFollowDriverManager Instance] setPreferredWidth:(590+382-10)];

	if(parentViewController && [parentViewController respondsToSelector:@selector(notifyResizingPopup:)])
		[parentViewController notifyResizingPopup:MIDAS_FOLLOW_DRIVER_POPUP_];

	[UIView commitAnimations];
		
	[expandButton setSelected:true];
	expanded = true;
}

- (void) reduceViewAnimated:(bool)animated
{
	if(!expanded)
		return;
	
	id parentViewController = [[MidasFollowDriverManager Instance] parentViewController];
	
	if(animated)
	{
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.5];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	}
	
	[[MidasFollowDriverManager Instance] setPreferredWidth:(382)];
	
	if(parentViewController && [parentViewController respondsToSelector:@selector(notifyResizingPopup:)])
		[parentViewController notifyResizingPopup:MIDAS_FOLLOW_DRIVER_POPUP_];
	
	if(animated)
	{
		[UIView commitAnimations];
	}
	else
	{
		[extensionContainer setHidden:true];
	}

	[expandButton setSelected:false];
	expanded = false;
}

- (void) animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void*)context
{
	if([finished intValue] == 1)
	{
		if(!expanded)
			[extensionContainer setHidden:true];
	}
}

- (void)RequestRedraw
{
	bool driverFound = false;
	
	DriverGapInfo * driverGapInfo = [[RacePadDatabase Instance] driverGapInfo];
	
	if(driverGapInfo)
	{
		NSString * requestedDriver = [driverGapInfo requestedDriver];
		
		if(requestedDriver && [requestedDriver length] > 0)
		{
			NSString * abbr = [driverGapInfo abbr];
			
			if(abbr && [abbr length] > 0)
			{
				driverFound = true;
				
				// Get image list for the driver images
				RacePadDatabase *database = [RacePadDatabase Instance];
				ImageListStore * image_store = [database imageListStore];
				
				ImageList *photoImageList = image_store ? [image_store findList:@"DriverPhotos"] : nil;
				
				if(photoImageList)
				{
					UIImage * image = [photoImageList findItem:abbr];
					if(image)
						[driverPhoto setImage:image];
					else
						[driverPhoto setImage:[UIImage imageNamed:@"NoPhoto.png"]];
				}
				else
				{
					[driverPhoto setImage:[UIImage imageNamed:@"NoPhoto.png"]];
				}
				
				ImageList *helmetImageList = image_store ? [image_store findList:@"DriverHelmets"] : nil;
				
				if(helmetImageList)
				{
					UIImage * image = [helmetImageList findItem:abbr];
					if(image)
						[driverHelmet setImage:image];
					else
						[driverHelmet setImage:[UIImage imageNamed:@"NoHelmet.png"]];
				}
				else
				{
					[driverHelmet setImage:[UIImage imageNamed:@"NoHelmet.png"]];
				}
				
				ImageList *carImageList = image_store ? [image_store findList:@"MiniCars"] : nil;
				
				if(carImageList)
				{
					UIImage * image = [carImageList findItem:abbr];
					if(image)
						[driverCar setImage:image];
					else
						[driverCar setImage:nil];
				}
				else
				{
					[driverCar setImage:nil];
				}
				
				NSString * firstName = [driverGapInfo firstName];
				NSString * surname = [driverGapInfo surname];
				NSString * teamName = [driverGapInfo teamName];
				
				NSString * fullName = [NSString stringWithString:firstName];
				fullName = [fullName stringByAppendingString:@" "];
				fullName = [fullName stringByAppendingString:surname];
				
				NSString * carAhead = [driverGapInfo carAhead];
				NSString * carBehind = [driverGapInfo carBehind];
				
				int position = [driverGapInfo position];
				int laps = [driverGapInfo laps];
				bool inPit = [driverGapInfo inPit];
				bool stopped = [driverGapInfo stopped];
				
				float gapAhead = [driverGapInfo gapAhead];
				float gapBehind = [driverGapInfo gapBehind];
				
				[driverNameLabel setText:fullName];
				[driverTeamLabel setText:teamName];
				
				if(position > 0)
				{
					[positionLabel setText:[NSString stringWithFormat:@"P%d", position]];
					
					if(inPit)
					{
						[carAheadLabel setText:@"IN PIT"];			
						[carBehindLabel setText:@""];
						[carAheadLabel setText:@""];
						[gapAheadLabel setText:@""];
					}
					else if(stopped)
					{
						[carAheadLabel setText:@"OUT"];			
						[carBehindLabel setText:@""];
						[carAheadLabel setText:@""];
						[gapAheadLabel setText:@""];
					}
					else
					{
						if(position == 1)
						{
							[carAheadLabel setText:@"LAPS"];			
							[gapAheadLabel setText:[NSString stringWithFormat:@"%d", laps]];
						}
						else if(gapAhead > 0.0)
						{
							[carAheadLabel setText:carAhead];			
							[gapAheadLabel setText:[NSString stringWithFormat:@"+%.1f", gapAhead]];
						}
						else
						{
							[carAheadLabel setText:@""];
							[gapAheadLabel setText:@""];
						}
						
						if(gapBehind > 0.0)
						{
							[carBehindLabel setText:carBehind];
							[gapBehindLabel setText:[NSString stringWithFormat:@"-%.1f", gapBehind]];
						}
						else
						{
							[carBehindLabel setText:@""];
							[gapBehindLabel setText:@""];
						}
					}
					
				}
				else
				{
					[positionLabel setText:@""];
					[carAheadLabel setText:@""];
					[gapAheadLabel setText:@""];
					[carBehindLabel setText:@""];
					[gapBehindLabel setText:@""];
				}
				
				BasePadVideoSource * videoSource = [[BasePadMedia Instance] findMovieSourceByTag:abbr];
				if(videoSource && [videoSource movieThumbnail])
				{
					[onboardVideoButton setBackgroundImage:[videoSource movieThumbnail] forState:UIControlStateNormal];
				}
				else
				{
					[onboardVideoButton setBackgroundImage:[UIImage imageNamed:@"preview-video-layer.png"] forState:UIControlStateNormal];
				}
				
				
			}
		}
	}
}

-(IBAction)movieSelected:(id)sender
{
	BasePadViewController * parentViewController = [[MidasFollowDriverManager Instance] parentViewController];
	
	if(parentViewController && [parentViewController isKindOfClass:[MidasVideoViewController class]])
	{
		MidasVideoViewController * videoViewController = (MidasVideoViewController *) parentViewController;
		
		DriverGapInfo * driverGapInfo = [[RacePadDatabase Instance] driverGapInfo];
		
		if(driverGapInfo)
		{
			NSString * requestedDriver = [driverGapInfo requestedDriver];
			
			if(requestedDriver && [requestedDriver length] > 0)
			{
				NSString * abbr = [driverGapInfo abbr];
				
				if(abbr && [abbr length] > 0)
				{
					BasePadVideoSource * videoSource = [[BasePadMedia Instance] findMovieSourceByTag:abbr];
		
					if(videoSource)
					{
						MovieView * movieView = [videoViewController findFreeMovieView];
						if(movieView)
						{
							if([videoViewController displayMovieSource:videoSource InView:movieView])
								[videoViewController animateMovieViews:movieView From:MV_MOVIE_FROM_RIGHT];
						}
					}
				}
			}
		}
	}
}


////////////////////////////////////////////////////////////////////////////

- (void) OnTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{	
	if(gestureView == heading)
	{
		[[MidasFollowDriverManager Instance] hideAnimated:true Notify:true];
	}
	else if([gestureView isKindOfClass:[leaderboardView class]])
	{
		NSString * name = [leaderboardView carNameAtX:x Y:y];
		
		if(name && [name length] > 0)
		{
			if(driverToFollow)
				[driverToFollow release];
			
			driverToFollow = [name retain];
			
			[driverInfoPanel setHidden:(driverToFollow == nil)];
			[selectDriverPanel setHidden:(driverToFollow != nil)];
			
			[[[RacePadDatabase Instance] driverGapInfo] setRequestedDriver:driverToFollow];
						
			[[RacePadCoordinator Instance] SetParameter:driverToFollow ForView:lapTimesView];
			
			[trackMapView followCar:driverToFollow];
			
			// Force reload of data
			[[RacePadCoordinator Instance] SetViewHidden:self];
			[[RacePadCoordinator Instance] SetViewHidden:lapTimesView];
			[[RacePadCoordinator Instance] SetViewDisplayed:self];
			[[RacePadCoordinator Instance] SetViewDisplayed:lapTimesView];

			[leaderboardView RequestRedraw];
			[trackMapView RequestRedraw];
						
			return;
		}
	}
	
}

- (void) onDisplay
{
	[driverInfoPanel setHidden:(driverToFollow == nil)];
	[selectDriverPanel setHidden:(driverToFollow != nil)];
	
	[[RacePadCoordinator Instance] SetViewDisplayed:leaderboardView];

	[trackMapView followCar:driverToFollow];
	
	DriverGapInfo * driverGapInfo = [[RacePadDatabase Instance] driverGapInfo];
	if(driverGapInfo)
	{
		[[[RacePadDatabase Instance] driverGapInfo] setRequestedDriver:driverToFollow];
	}
	
	[[RacePadCoordinator Instance] SetParameter:driverToFollow ForView:lapTimesView];
	[[RacePadCoordinator Instance] SetViewDisplayed:lapTimesView];
	
	[[RacePadCoordinator Instance] SetViewDisplayed:trackMapView];
	[[RacePadCoordinator Instance] SetViewDisplayed:self];
}

- (void) onHide
{
	if(expanded)
	{
		[self reduceViewAnimated:false];		
	}

	[[RacePadCoordinator Instance] SetViewHidden:lapTimesView];
	[[RacePadCoordinator Instance] SetViewHidden:trackMapView];
	[[RacePadCoordinator Instance] SetViewHidden:leaderboardView];
	[[RacePadCoordinator Instance] SetViewHidden:self];
}


////////////////////////////////////////////////////////////////////////////

- (IBAction) expandPressed
{
	id parentViewController = [[MidasFollowDriverManager Instance] parentViewController];
	
	if(expanded)
	{
		[self reduceViewAnimated:true];		
	}
	else
	{
		if(parentViewController && [parentViewController respondsToSelector:@selector(notifyExclusiveUse:InZone:)])
			[parentViewController notifyExclusiveUse:MIDAS_FOLLOW_DRIVER_POPUP_ InZone:MIDAS_ZONE_ALL_];
	
		[self expandView];
	}
}


@end

@implementation MidasFollowDriverLapListView

// Override column widths received from server : table width 580
- (int) ColumnWidth:(int)col;
{
	switch (col)
	{
		case 0:
			return 25;

		case 1:
			return 25;
			
		case 2:
			return 55;
			
		case 3:
			return 75;
			
		case 4:
			return 35;
			
		case 5:
			return 35;
			
		case 6:
			return 65;
			
		case 7:
			return 30;
			
		case 8:
			return 65;
			
		case 9:
			return 30;
			
		case 10:
			return 65;
			
		case 11:
			return 30;
			
		case 12:
			return 40;
	}
	
	return 30;
}


@end

