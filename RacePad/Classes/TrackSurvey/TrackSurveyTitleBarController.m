//
//  TrackSurveyTitleBar.m
//  TrackSurvey
//
//  Created by Mark Riches 2/5/2011.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import "TrackSurveyTitleBarController.h"

#import "UIConstants.h"
#import "SurveyViewController.h"

@implementation TitleBarViewController

@synthesize toolbar;
@synthesize surveyStateBarItem;
@synthesize surveyStateButton;
@synthesize allItems;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	allItems = [[toolbar items] retain];
	
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
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload
{
 	[allItems release];
	allItems = nil;
	
	[super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc
{
    [super dealloc];
}

- (void)RequestRedraw
{
	
}

- (void)RequestRedrawForUpdate
{
	
}

@end

@implementation TrackSurveyTitleBarController

static TrackSurveyTitleBarController * instance_ = nil;

+(TrackSurveyTitleBarController *)Instance
{
	if(!instance_)
		instance_ = [[TrackSurveyTitleBarController alloc] init];
	
	return instance_;
}

-(id)init
{
	if(self = [super init])
	{	
		titleBarController = [[TitleBarViewController alloc] initWithNibName:@"TitleBarView" bundle:nil];
	}
	
	return self;
}


- (void)dealloc
{
    [super dealloc];
}

- (void) displayInViewController:(UIViewController *)viewController
{	
	CGRect super_bounds = [viewController.view bounds];
	CGRect title_controller_bounds = [titleBarController.view bounds];
	
	[viewController.view addSubview:titleBarController.view];
	
	CGRect frame = CGRectMake(super_bounds.origin.x, super_bounds.origin.y, super_bounds.size.width, title_controller_bounds.size.height);
	[titleBarController.view setFrame:frame];

	[[titleBarController surveyStateButton] addTarget:self action:@selector(SurveyPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void) hide
{
	[titleBarController.view removeFromSuperview];
}

- (void) onStartUp
{
}

- (IBAction)SurveyPressed:(id)sender
{
	[[SurveyViewController Instance]toggleSurveying];
	if ( [[SurveyViewController Instance] surveying] )
	{
		[[titleBarController surveyStateButton] setImage:[UIImage imageNamed:@"SaveIndicator.png"] forState:UIControlStateNormal];
	}
	else
		[[titleBarController surveyStateButton] setImage:[UIImage imageNamed:@"RecordIndicator.png"] forState:UIControlStateNormal];
}

@end
