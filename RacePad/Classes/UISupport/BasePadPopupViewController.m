//
//  BasePadPopupViewController.m
//
//  Created by Gareth Griffith on 1/6/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import "BasePadPopupViewController.h"
#import "BasePadPopupManager.h"

@implementation BasePadPopupViewController

@synthesize associatedManager;
@synthesize container;
@synthesize heading;
@synthesize parentViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self)
	{
		associatedManager = nil;
		parentViewController = nil;
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	if(container)
		[self addTapRecognizerToView:container];
	
	if(heading)
	{
		[self addTapRecognizerToView:heading];
		[self addUpSwipeRecognizerToView:heading];
		[self addDownSwipeRecognizerToView:heading];
	}
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
	
	[associatedManager release];
	[parentViewController release];
}

////////////////////////////////////////////////////////////////////////////

- (void) OnTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{	
	if(gestureView == heading && associatedManager)
	{
		[associatedManager hideAnimated:true Notify:true];
	}
}

- (void) OnUpSwipeGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{	
	if(gestureView == heading && associatedManager)
	{
		[associatedManager hideAnimated:true Notify:true];
	}
}

- (void) OnDownSwipeGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{	
	if(gestureView == heading && associatedManager)
	{
		[associatedManager hideAnimated:true Notify:true];
	}
}

- (void) willDisplay
{
}

- (void) willHide
{
}

- (void) didDisplay
{
}

- (void) didHide
{
}

@end