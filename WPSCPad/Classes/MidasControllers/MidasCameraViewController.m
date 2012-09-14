    //
//  MidasCameraViewController.m
//  MidasDemo
//
//  Created by Gareth Griffith on 8/29/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import "MidasCameraViewController.h"
#import "TestFlight.h"

#import "MidasVideoViewController.h"
#import "MidasPopupManager.h"

#import "RacePadCoordinator.h"

@interface MidasCameraViewController ()
@property (nonatomic, unsafe_unretained) IBOutlet UIImageView *titleImageView;
@property (nonatomic, unsafe_unretained) IBOutlet UILabel *titleLabel;
@end

@implementation MidasCameraViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	[super viewDidLoad];
		
	[movieSelectorView SetBackgroundAlpha:0.0];
	[movieSelectorView setVertical:true];
	[movieSelectorView setFilterString:nil];
	
	[self addTapRecognizerToView:movieSelectorView];
	
	UIImage *image = [self.titleImageView.image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 13.0f, 0.0f, 13.0f)];
	self.titleImageView.image = image;
	self.titleLabel.text = NSLocalizedString(@"midas.cameras.title", @"Cameras popup title");
    
    [allCamerasButton setSelected:true];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[TestFlight passCheckpoint:@"Cameras"];
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
		[[MidasCameraManager Instance] hideAnimated:true Notify:true];
	}
	else if(gestureView == movieSelectorView)
	{
		int row, col;
		if([(SimpleListView *)gestureView FindCellAtX:x Y:y RowReturn:&row ColReturn:&col])
		{
			BasePadVideoSource * videoSource = [movieSelectorView GetMovieSourceAtIndex:row];
			
			if(videoSource && ![videoSource movieDisplayed])
			{
				BasePadViewController * parentViewController = [[MidasCameraManager Instance] parentViewController];
				
				if(parentViewController && [parentViewController isKindOfClass:[MidasVideoViewController class]])
				{
					MidasVideoViewController * videoViewController = (MidasVideoViewController *) parentViewController;
					
					MovieView * movieView = [videoViewController findFreeMovieView];
					if(movieView)
					{
						[videoViewController prepareToAnimateMovieViews:movieView From:MV_MOVIE_FROM_BOTTOM];
						[movieView setMovieViewDelegate:self];
						[movieView displayMovieSource:videoSource]; // Will get notification below when finished
						
						BasePadViewController * parentViewController = [[MidasCameraManager Instance] parentViewController];						
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
}

- (void) onHide
{
}

-(IBAction)buttonPressed:(id)sender
{
    [allCamerasButton setSelected:false];
    [onboardButton setSelected:false];
    [trackCameraButton setSelected:false];

    if(sender == allCamerasButton)
        [movieSelectorView setFilterString:nil];
    else if(sender == onboardButton)
        [movieSelectorView setFilterString:@"ONBOARD"];
    else if(sender == trackCameraButton)
        [movieSelectorView setFilterString:@"TRACK"];
    
    [movieSelectorView ScrollToRow:-1]; // Forces it to top and requests redraw
    [(UIButton *)sender setSelected:true];
}
@end
