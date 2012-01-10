//
//  MidasBaseViewController.m
//  MidasDemo
//
//  Created by Gareth Griffith on 1/6/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import "MidasBaseViewController.h"
#import "MidasPopupManager.h"

@implementation MidasBaseViewController

@synthesize associatedManager;
@synthesize container;
@synthesize heading;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self)
	{
		associatedManager = nil;
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[self addTapRecognizerToView:container];
	[self addTapRecognizerToView:heading];
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
}

////////////////////////////////////////////////////////////////////////////

- (void) OnTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{	
	if(gestureView == heading && associatedManager)
	{
		[associatedManager hideAnimated:true Notify:true];
	}
}

- (void) onDisplay
{
}

- (void) onHide
{
}

@end