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
	
	FacebookView * facebookView = [[FacebookView alloc] initWithFrame:CGRectMake(0, 0, 300, 432)];
	facebookView.delegate = self;
    [self.view addSubview:facebookView];
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

#pragma mark BaseSocialmediaViewDelegate methods

- (void)baseSocialMediaAboutToShow:(BaseSocialmediaView *)controller
{
}


- (void)baseSocialMediaShown:(BaseSocialmediaView *)controller
{
}


- (void)baseSocialMediaAboutToHide:(BaseSocialmediaView *)controller
{
}


- (void)baseSocialMediaHidden:(BaseSocialmediaView *)controller
{
}


@end
