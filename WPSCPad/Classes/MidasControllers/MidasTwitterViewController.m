    //
//  MidasTwitterViewController.m
//  MidasDemo
//
//  Created by Gareth Griffith on 1/9/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import "MidasTwitterViewController.h"

@implementation MidasTwitterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	TwitterView * twitterView = [[TwitterView alloc] initWithFrame:CGRectMake(0, 0, 300, 432)];
   // twitterView.delegate = self;
    [self.view addSubview:twitterView];
	[twitterView release];
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
