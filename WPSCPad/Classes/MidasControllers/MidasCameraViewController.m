    //
//  MidasCameraViewController.m
//  MidasDemo
//
//  Created by Gareth Griffith on 8/29/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import "MidasCameraViewController.h"

#import "MidasVideoViewController.h"
#import "MidasPopupManager.h"

#import "RacePadCoordinator.h"

@implementation MidasCameraViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	[super viewDidLoad];
		
	[movieSelectorView SetBackgroundAlpha:0.0];
	[movieSelectorView setVertical:true];
	
	[self addTapRecognizerToView:movieSelectorView];
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
}
@end
