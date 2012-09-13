//
//  MidasCircuitViewController.m
//  MidasDemo
//
//  Created by Gareth Griffith on 1/7/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import "MidasCircuitViewController.h"
#import "MidasVideoViewController.h"
#import "MidasPopupManager.h"
#import "TestFlight.h"
#import "RacePadCoordinator.h"

@interface MidasCircuitViewController ()
@property (nonatomic, unsafe_unretained) IBOutlet UIImageView *titleImageView;
@property (nonatomic, unsafe_unretained) IBOutlet UILabel *titleLabel;
@end

@implementation MidasCircuitViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[trackMapView setIsZoomView:false];
	[trackMapView setIsOverlayView:true];
	[trackMapView setSmallSized:true];
	[trackMapView setMidasStyle:true];
	
	[self addTapRecognizerToView:movieSelectorView];
	
	[[RacePadCoordinator Instance] AddView:trackMapView WithType:RPC_TRACK_MAP_VIEW_];

	UIImage *image = [self.titleImageView.image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 13.0f, 0.0f, 13.0f)];
	self.titleImageView.image = image;
	self.titleLabel.text = NSLocalizedString(@"midas.circuit.title", @"Circuit popup title");

	[TestFlight passCheckpoint:@"Circuit Views"];
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

- (void) OnTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{	
	if(gestureView == heading)
	{
		[[MidasCircuitViewManager Instance] hideAnimated:true Notify:true];
	}
	else if(gestureView == movieSelectorView)
	{
		int row, col;
		if([(SimpleListView *)gestureView FindCellAtX:x Y:y RowReturn:&row ColReturn:&col])
		{
			BasePadVideoSource * videoSource = [movieSelectorView GetMovieSourceAtIndex:col];
			
			if(videoSource && ![videoSource movieDisplayed])
			{
				BasePadViewController * parentViewController = [[MidasCircuitViewManager Instance] parentViewController];
			
				if(parentViewController && [parentViewController isKindOfClass:[MidasVideoViewController class]])
				{
					MidasVideoViewController * videoViewController = (MidasVideoViewController *) parentViewController;
				
					MovieView * movieView = [videoViewController findFreeMovieView];
					if(movieView)
					{
						[videoViewController prepareToAnimateMovieViews:movieView From:MV_MOVIE_FROM_BOTTOM];
						[movieView setMovieViewDelegate:self];
						[movieView displayMovieSource:videoSource]; // Will get notification below when finished

						BasePadViewController * parentViewController = [[MidasCircuitViewManager Instance] parentViewController];						
						if(parentViewController && [parentViewController isKindOfClass:[MidasVideoViewController class]])
							[(MidasVideoViewController *) parentViewController animateMovieViews:movieView From:MV_MOVIE_FROM_BOTTOM];
					}
				}
			}
		}
	}
}

- (void)notifyMovieAttachedToView:(MovieView *)movieView	// MovieViewDelegate method
{
}

- (void)notifyMovieReadyToPlayInView:(MovieView *)movieView	// MovieViewDelegate method
{
}

- (void) onDisplay
{
	[[RacePadCoordinator Instance] SetViewDisplayed:trackMapView];
}

- (void) onHide
{
	[[RacePadCoordinator Instance] SetViewHidden:trackMapView];
}

-(IBAction)addToViewButtonPressed:(id)sender
{
	BasePadViewController * parentViewController = [[MidasCircuitViewManager Instance] parentViewController];
		
	if(parentViewController && [parentViewController isKindOfClass:[MidasVideoViewController class]])
	{
		MidasVideoViewController * videoViewController = (MidasVideoViewController *) parentViewController;
			
		if(videoViewController)
		{
			if([videoViewController displayMap])
			{
				[videoViewController setMapDisplayed:false];
				[sender setSelected:false];
			}
			else
			{
				[videoViewController setMapDisplayed:true];
				[sender setSelected:true];
			}
		}
	}
}
@end
