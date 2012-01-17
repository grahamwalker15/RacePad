    //
//  MidasChatViewController.m
//  MidasDemo
//
//  Created by Gareth Griffith on 1/9/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import "MidasChatViewController.h"
#import "MidasView.h"


@implementation MidasChatViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	MidasView * midasView = [[MidasView alloc] initWithFrame:CGRectMake(0, 0, 300, 372)];
	midasView.delegate = self;
    [self.view addSubview:midasView];
	[midasView setFrame:CGRectMake(0, 0, 300, 372)];
	[midasView __checkForNewMessages:70000];
	[midasView release];
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
