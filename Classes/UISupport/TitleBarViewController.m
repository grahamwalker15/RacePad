//
//  TitleBarController.m
//  RacePad
//
//  Created by Gareth Griffith on 11/4/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "TitleBarViewController.h"

@implementation TitleBarViewController

@synthesize toolbar;
@synthesize allItems;
@synthesize sponsorButton;
@synthesize alertButton;
@synthesize commentaryButton;
@synthesize helpBarButton;
@synthesize helpButton;
@synthesize eventName;
@synthesize clock;
@synthesize timeCounter;
@synthesize trackStateButton;
@synthesize playStateBarItem;
@synthesize playStateButton;

 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad
 {
	 [super viewDidLoad];
     alertButton.tintColor = [UIColor whiteColor];
     commentaryButton.tintColor = [UIColor whiteColor];
     helpButton.tintColor = [UIColor whiteColor];
     [timeCounter setShine:1.0];
	 
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
