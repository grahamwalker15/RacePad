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
#import "HeadToHeadView.h"

#import "BasePadMedia.h"
#import "MidasVideoViewController.h"

@interface MidasFollowDriverViewController ()
@property (nonatomic, unsafe_unretained) IBOutlet UIImageView *titleImageView;
@property (nonatomic, unsafe_unretained) IBOutlet UILabel *titleLabel;
@end

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
	[leaderboardView setSmallDisplay:false];
	[leaderboardView setUseBoldFont:false];
	[leaderboardView setAddOutlines:false];
	
	// Set parameters for views
	[trackMapView setIsZoomView:true];
	[trackMapView setSmallSized:true];
	[trackMapView setMidasStyle:true];

	
	[trackMapView setUserScale:10.0];
	[trackMapContainer setStyle:BG_STYLE_MIDAS_TRANSPARENT_];
	
	[headToHeadView setMiniDisplay:true];
		
	//  Add extra gesture recognizers
		
    //	Tap, pinch, and double tap recognizers for map
	[self addTapRecognizerToView:trackMapView];
	[self addPinchRecognizerToView:trackMapView];
	[self addDoubleTapRecognizerToView:trackMapView];
	
	// Add tap and long press recognizers to the leaderboard
	[self addTapRecognizerToView:leaderboardView];
	[self addLongPressRecognizerToView:leaderboardView];
	
	// Add tap, double tap, pan and pinch for graph
	[self addTapRecognizerToView:headToHeadView];
	[self addDoubleTapRecognizerToView:headToHeadView];
	[self addPanRecognizerToView:headToHeadView];
	[self addPinchRecognizerToView:headToHeadView];
	
	// Set paramters for views
	[trackMapContainer setBackgroundColor:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.3]];
	
	// Tell the RacePadCoordinator that we will be interested in data for views
	[[RacePadCoordinator Instance] AddView:lapTimesView WithType:RPC_LAP_LIST_VIEW_];
	[[RacePadCoordinator Instance] AddView:trackMapView WithType:RPC_TRACK_MAP_VIEW_];
	[[RacePadCoordinator Instance] AddView:leaderboardView WithType:RPC_LEADER_BOARD_VIEW_];
	[[RacePadCoordinator Instance] AddView:headToHeadView WithType:RPC_HEAD_TO_HEAD_VIEW_];
	[[RacePadCoordinator Instance] AddView:self WithType:RPC_DRIVER_GAP_INFO_VIEW_];

	UIImage *image = [self.titleImageView.image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 13.0f, 0.0f, 13.0f)];
	self.titleImageView.image = image;
	self.titleLabel.text = NSLocalizedString(@"midas.driver.title", @"Follow driver popup title");
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
	if(!expanded)
		[extensionContainer setHidden:true];
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
				
				// Get the driver age
				int driverAge = [self getDriverAge:abbr];
				[driverAgeLabel setText:[NSString stringWithFormat:@"AGE : %d", driverAge]];
				
				// Get the driver nationality
				NSString * nationalityLabel = @"NATIONALITY : ";
				NSString * driverNationality = [nationalityLabel stringByAppendingString:[self getDriverNationality:abbr]];
				[driverNationalityLabel setText:driverNationality];
				
				[driverFlag setImage:[self getNationalFlag:abbr]];

				
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
				
				[driverNameLabel setText:[fullName uppercaseString]];

				NSString * teamLabel = @"TEAM : ";
				NSString * driverTeam = [teamLabel stringByAppendingString:[teamName uppercaseString]];
				[driverTeamLabel setText:driverTeam];
				
				if(position > 0)
				{
					if(stopped)
					{
						[positionLabel setText:@"OUT"];
						[placeLabel setHidden:true];
						
						[carAheadLabel setText:@""];			
						[carBehindLabel setText:@""];
						[carAheadLabel setText:@""];
						[gapAheadLabel setText:@""];
					}
					else
					{
						if((position % 10) == 1 && position != 11)
							[positionLabel setText:[NSString stringWithFormat:@"%dst", position]];
						else if((position % 10) == 2 && position != 12)
							[positionLabel setText:[NSString stringWithFormat:@"%dnd", position]];
						else if((position % 10) == 3 && position != 13)
							[positionLabel setText:[NSString stringWithFormat:@"%drd", position]];
						else
							[positionLabel setText:[NSString stringWithFormat:@"%dth", position]];

						[placeLabel setHidden:false];
						
						if(inPit)
						{
							[carAheadLabel setText:@"IN PIT"];			
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
					
				}
				else
				{
					[positionLabel setText:@""];
					[carAheadLabel setText:@""];
					[gapAheadLabel setText:@""];
					[carBehindLabel setText:@""];
					[gapBehindLabel setText:@""];
				}
			}
		}
	}
}

- (int) getDriverNumber:(NSString *)tag
{
	if(!tag)
		return 1;
	
	if([tag compare:@"VET"] == NSOrderedSame)
		return 1;
	if([tag compare:@"WEB"] == NSOrderedSame)
		return 2;
	if([tag compare:@"HAM"] == NSOrderedSame)
		return 3;
	if([tag compare:@"BUT"] == NSOrderedSame)
		return 4;
	if([tag compare:@"ALO"] == NSOrderedSame)
		return 5;
	if([tag compare:@"MAS"] == NSOrderedSame)
		return 6;
	if([tag compare:@"MSC"] == NSOrderedSame)
		return 7;
	if([tag compare:@"ROS"] == NSOrderedSame)
		return 8;
	if([tag compare:@"SEN"] == NSOrderedSame)
		return 9;
	if([tag compare:@"PET"] == NSOrderedSame)
		return 10;
	if([tag compare:@"SUT"] == NSOrderedSame)
		return 11;
	if([tag compare:@"DIR"] == NSOrderedSame)
		return 12;
	if([tag compare:@"BAR"] == NSOrderedSame)
		return 14;
	if([tag compare:@"MAL"] == NSOrderedSame)
		return 15;
	if([tag compare:@"PER"] == NSOrderedSame)
		return 16;
	if([tag compare:@"KOB"] == NSOrderedSame)
		return 17;
	if([tag compare:@"BUE"] == NSOrderedSame)
		return 18;
	if([tag compare:@"ALG"] == NSOrderedSame)
		return 19;
	if([tag compare:@"KOV"] == NSOrderedSame)
		return 20;
	if([tag compare:@"TRU"] == NSOrderedSame)
		return 21;
	if([tag compare:@"RIC"] == NSOrderedSame)
		return 22;
	if([tag compare:@"LIU"] == NSOrderedSame)
		return 23;
	if([tag compare:@"GLO"] == NSOrderedSame)
		return 24;
	if([tag compare:@"DAM"] == NSOrderedSame)
		return 25;
	
	return 1;
}

- (NSString *) getDriverNationality:(NSString *)tag
{
	if(!tag)
		return @" ";
	
	if([tag compare:@"VET"] == NSOrderedSame)
		return @"GERMAN";
	if([tag compare:@"WEB"] == NSOrderedSame)
		return @"AUSTRALIAN";
	if([tag compare:@"HAM"] == NSOrderedSame)
		return @"BRITISH";
	if([tag compare:@"BUT"] == NSOrderedSame)
		return @"BRITISH";
	if([tag compare:@"ALO"] == NSOrderedSame)
		return @"SPANISH";
	if([tag compare:@"MAS"] == NSOrderedSame)
		return @"BRAZILIAN";
	if([tag compare:@"MSC"] == NSOrderedSame)
		return @"GERMAN";
	if([tag compare:@"ROS"] == NSOrderedSame)
		return @"GERMAN";
	if([tag compare:@"SEN"] == NSOrderedSame)
		return @"BRAZILIAN";
	if([tag compare:@"PET"] == NSOrderedSame)
		return @"RUSSIAN";
	if([tag compare:@"SUT"] == NSOrderedSame)
		return @"GERMAN";
	if([tag compare:@"DIR"] == NSOrderedSame)
		return @"BRITISH";
	if([tag compare:@"BAR"] == NSOrderedSame)
		return @"BRAZILIAN";
	if([tag compare:@"MAL"] == NSOrderedSame)
		return @"VENEZUELAN";
	if([tag compare:@"PER"] == NSOrderedSame)
		return @"MEXICAN";
	if([tag compare:@"KOB"] == NSOrderedSame)
		return @"JAPANESE";
	if([tag compare:@"BUE"] == NSOrderedSame)
		return @"SWISS";
	if([tag compare:@"ALG"] == NSOrderedSame)
		return @"SPANISH";
	if([tag compare:@"KOV"] == NSOrderedSame)
		return @"FINNISH";
	if([tag compare:@"TRU"] == NSOrderedSame)
		return @"ITALIAN";
	if([tag compare:@"RIC"] == NSOrderedSame)
		return @"AUSTRALIAN";
	if([tag compare:@"LIU"] == NSOrderedSame)
		return @"ITALIAN";
	if([tag compare:@"GLO"] == NSOrderedSame)
		return @"GERMAN";
	if([tag compare:@"DAM"] == NSOrderedSame)
		return @"BELGIAN";
	if([tag compare:@"PIC"] == NSOrderedSame)
		return @"FRENCH";
	if([tag compare:@"GRO"] == NSOrderedSame)
		return @"FRENCH";
	if([tag compare:@"RAI"] == NSOrderedSame)
		return @"FINNISH";
	if([tag compare:@"VER"] == NSOrderedSame)
		return @"FRENCH";
	if([tag compare:@"HUL"] == NSOrderedSame)
		return @"GERMAN";
	if([tag compare:@"DLR"] == NSOrderedSame)
		return @"SPANISH";
	if([tag compare:@"KAR"] == NSOrderedSame)
		return @"INDIAN";
	
	return @" ";
}

- (int) getDriverAge:(NSString *)tag
{
	if(!tag)
		return 0;
	
	if([tag compare:@"VET"] == NSOrderedSame)
		return 24;
	if([tag compare:@"WEB"] == NSOrderedSame)
		return 32;
	if([tag compare:@"HAM"] == NSOrderedSame)
		return 27;
	if([tag compare:@"BUT"] == NSOrderedSame)
		return 32;
	if([tag compare:@"ALO"] == NSOrderedSame)
		return 33;
	if([tag compare:@"MAS"] == NSOrderedSame)
		return 33;
	if([tag compare:@"MSC"] == NSOrderedSame)
		return 43;
	if([tag compare:@"ROS"] == NSOrderedSame)
		return 26;
	if([tag compare:@"SEN"] == NSOrderedSame)
		return 25;
	if([tag compare:@"PET"] == NSOrderedSame)
		return 29;
	if([tag compare:@"SUT"] == NSOrderedSame)
		return 32;
	if([tag compare:@"DIR"] == NSOrderedSame)
		return 25;
	if([tag compare:@"BAR"] == NSOrderedSame)
		return 41;
	if([tag compare:@"MAL"] == NSOrderedSame)
		return 29;
	if([tag compare:@"PER"] == NSOrderedSame)
		return 24;
	if([tag compare:@"KOB"] == NSOrderedSame)
		return 26;
	if([tag compare:@"BUE"] == NSOrderedSame)
		return 27;
	if([tag compare:@"ALG"] == NSOrderedSame)
		return 22;
	if([tag compare:@"KOV"] == NSOrderedSame)
		return 30;
	if([tag compare:@"TRU"] == NSOrderedSame)
		return 37;
	if([tag compare:@"RIC"] == NSOrderedSame)
		return 23;
	if([tag compare:@"LIU"] == NSOrderedSame)
		return 32;
	if([tag compare:@"GLO"] == NSOrderedSame)
		return 32;
	if([tag compare:@"DAM"] == NSOrderedSame)
		return 25;
	if([tag compare:@"PIC"] == NSOrderedSame)
		return 23;
	if([tag compare:@"GRO"] == NSOrderedSame)
		return 27;
	if([tag compare:@"RAI"] == NSOrderedSame)
		return 31;
	if([tag compare:@"VER"] == NSOrderedSame)
		return 25;
	if([tag compare:@"HUL"] == NSOrderedSame)
		return 25;
	if([tag compare:@"DLR"] == NSOrderedSame)
		return 38;
	if([tag compare:@"KAR"] == NSOrderedSame)
		return 31;
	
	return 0;
}



- (UIImage *) getNationalFlag:(NSString *)tag
{
	if(!tag)
		return nil;
	
	if([tag compare:@"VET"] == NSOrderedSame)
		return [UIImage imageNamed:@"Germany.png"];
	if([tag compare:@"WEB"] == NSOrderedSame)
		return [UIImage imageNamed:@"Australia.png"];
	if([tag compare:@"HAM"] == NSOrderedSame)
		return [UIImage imageNamed:@"UK.png"];
	if([tag compare:@"BUT"] == NSOrderedSame)
		return [UIImage imageNamed:@"UK.png"];
	if([tag compare:@"ALO"] == NSOrderedSame)
		return [UIImage imageNamed:@"Spain.png"];
	if([tag compare:@"MAS"] == NSOrderedSame)
		return [UIImage imageNamed:@"Brazil.png"];
	if([tag compare:@"MSC"] == NSOrderedSame)
		return [UIImage imageNamed:@"Germany.png"];
	if([tag compare:@"ROS"] == NSOrderedSame)
		return [UIImage imageNamed:@"Germany.png"];
	if([tag compare:@"SEN"] == NSOrderedSame)
		return [UIImage imageNamed:@"Brazil.png"];
	if([tag compare:@"PET"] == NSOrderedSame)
		return [UIImage imageNamed:@"Russia.png"];
	if([tag compare:@"SUT"] == NSOrderedSame)
		return [UIImage imageNamed:@"Germany.png"];
	if([tag compare:@"DIR"] == NSOrderedSame)
		return [UIImage imageNamed:@"UK.png"];
	if([tag compare:@"BAR"] == NSOrderedSame)
		return [UIImage imageNamed:@"Brazil.png"];
	if([tag compare:@"MAL"] == NSOrderedSame)
		return [UIImage imageNamed:@"Venezuela.png"];
	if([tag compare:@"PER"] == NSOrderedSame)
		return [UIImage imageNamed:@"Mexico.png"];
	if([tag compare:@"KOB"] == NSOrderedSame)
		return [UIImage imageNamed:@"Japan.png"];
	if([tag compare:@"BUE"] == NSOrderedSame)
		return [UIImage imageNamed:@"Switzerland.png"];
	if([tag compare:@"ALG"] == NSOrderedSame)
		return [UIImage imageNamed:@"Spain.png"];
	if([tag compare:@"KOV"] == NSOrderedSame)
		return [UIImage imageNamed:@"Finland.png"];
	if([tag compare:@"TRU"] == NSOrderedSame)
		return [UIImage imageNamed:@"Italy.png"];
	if([tag compare:@"RIC"] == NSOrderedSame)
		return [UIImage imageNamed:@"Australia.png"];
	if([tag compare:@"LIU"] == NSOrderedSame)
		return [UIImage imageNamed:@"Italy.png"];
	if([tag compare:@"GLO"] == NSOrderedSame)
		return [UIImage imageNamed:@"Germany.png"];
	if([tag compare:@"DAM"] == NSOrderedSame)
		return [UIImage imageNamed:@"Belgium.png"];
	if([tag compare:@"PIC"] == NSOrderedSame)
		return [UIImage imageNamed:@"France.png"];
	if([tag compare:@"GRO"] == NSOrderedSame)
		return [UIImage imageNamed:@"France.png"];
	if([tag compare:@"RAI"] == NSOrderedSame)
		return [UIImage imageNamed:@"Finland.png"];
	if([tag compare:@"VER"] == NSOrderedSame)
		return [UIImage imageNamed:@"France.png"];
	if([tag compare:@"HUL"] == NSOrderedSame)
		return [UIImage imageNamed:@"Germany.png"];
	if([tag compare:@"DLR"] == NSOrderedSame)
		return [UIImage imageNamed:@"Spain.png"];
	if([tag compare:@"KAR"] == NSOrderedSame)
		return [UIImage imageNamed:@"India.png"];
	
	return nil;
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
			
			// Head to head
			HeadToHead * headToHead = [[RacePadDatabase Instance] headToHead];
			if(headToHead)
			{
				[headToHead setDriver0:driverToFollow];
				[headToHead setDriver1:nil];
			}
			
			// Force reload of data
			[[RacePadCoordinator Instance] SetViewHidden:self];
			[[RacePadCoordinator Instance] SetViewHidden:lapTimesView];
			[[RacePadCoordinator Instance] SetViewHidden:headToHeadView];
			[[RacePadCoordinator Instance] SetViewHidden:lapTimesView];
			[[RacePadCoordinator Instance] SetViewDisplayed:self];
			[[RacePadCoordinator Instance] SetViewDisplayed:lapTimesView];
			[[RacePadCoordinator Instance] SetViewDisplayed:headToHeadView];

			[leaderboardView RequestRedraw];
			[trackMapView RequestRedraw];
			[headToHeadView RequestRedraw];
						
			return;
		}
	}
	
}

- (void) OnPinchGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y Scale:(float)scale Speed:(float)speed
{
	if(!gestureView)
		return;
	
	if([gestureView isKindOfClass:[HeadToHeadView class]])
	{
		if(gestureStartPoint.x > [gestureView bounds].size.width - 50)
			[(HeadToHeadView *)gestureView adjustScaleY:scale X:x Y:y];	
		else
			[(HeadToHeadView *)gestureView adjustScaleX:scale X:x Y:y];	
		
		[(HeadToHeadView *)gestureView RequestRedraw];
	}
}

- (void) OnDoubleTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
	if(!gestureView)
		return;
	
	if([gestureView isKindOfClass:[HeadToHeadView class]])
	{
		HeadToHeadView * hToHView = (HeadToHeadView *)gestureView;
		[hToHView resetUserScale];
		[hToHView RequestRedraw];
	}
}

- (void) OnPanGestureInView:(UIView *)gestureView ByX:(float)x Y:(float)y SpeedX:(float)speedx SpeedY:(float)speedy State:(int)state
{
	// Ignore lifting finger
	if(state == UIGestureRecognizerStateEnded)
		return;
	
	if([gestureView isKindOfClass:[HeadToHeadView class]])
	{
		if(gestureStartPoint.x > [gestureView bounds].size.width - 50)
			[(HeadToHeadView *)gestureView adjustPanY:y];
		else
			[(HeadToHeadView *)gestureView adjustPanX:x];
		
		[(HeadToHeadView *)gestureView RequestRedraw];
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
	// Reduce view if it was expanded on closing
	if(expanded)
	{
		[self reduceViewAnimated:false];
		
		if(associatedManager)
			[associatedManager moveToPositionX:self.view.frame.origin.x Animated:false];
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

-(IBAction)votePressed:(id)sender
{
}

@end

@implementation MidasFollowDriverLapListView

// Override column widths received from server : table width 580
- (int) ColumnWidth:(int)col
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
			
		default:
			return 30;
	}
	
	return 30;
}


@end

