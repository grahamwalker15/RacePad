    //
//  MidasFacebookViewController.m
//  MidasDemo
//
//  Created by Gareth Griffith on 1/9/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import "MidasFacebookViewController.h"


@implementation MidasFacebookViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	FacebookView * facebookView = [[FacebookView alloc] initWithFrame:CGRectMake(0, 0, 300, 325)];
	facebookView.delegate = self;
    [self.tableContainerView addSubview:facebookView];
	[facebookView setFrame:CGRectMake(0, 0, 300, 325)];
	[facebookView __checkForNewMessages:70000];
	[facebookView release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
