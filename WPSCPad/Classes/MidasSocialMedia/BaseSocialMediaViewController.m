//
//  ViewController.m
//  F1Test
//
//  Created by Andrew Greenshaw on 05/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@implementation ViewController

@synthesize twitview;
@synthesize faceview;
@synthesize midasview;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // create the "twitter" view "off-screen", so it's ready to show
    //
    // note: the x pos can be changed using the showViewAtPos:nnn method
    twitview = [[TwitterView alloc] initWithFrame:CGRectMake(30, -432, 300, 432)];
    twitview.delegate = self;
    [self.view addSubview:twitview];

    faceview = [[FacebookView alloc] initWithFrame:CGRectMake(360, -432, 300, 432)];
    faceview.delegate = self;
    [self.view addSubview:faceview];

    midasview = [[MidasView alloc] initWithFrame:CGRectMake(690, -432, 300, 432)];
    midasview.delegate = self;
    [self.view addSubview:midasview];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

-(IBAction)showTwitter:(id)sender {
    if ([twitview isVisible])
    {
        [twitview hideView:0.5];
    }
    else
    {
        [twitview showViewAtPos:0.5:30];
    }
}

-(IBAction)showFacebook:(id)sender {
    if ([faceview isVisible])
    {
        [faceview hideView:0.5];
    }
    else
    {
        [faceview showViewAtPos:0.5:360];
    }
}

-(IBAction)showMidas:(id)sender {
    if ([midasview isVisible])
    {
        [midasview hideView:0.5];
    }
    else
    {
        [midasview showViewAtPos:0.5:690];
    }
}

#pragma mark BaseSocialmediaViewDelegate methods

- (void)baseSocialmediaShown:(BaseSocialmediaView *)controller
{
    if ([controller isKindOfClass:[TwitterView class]])
    {
        NSLog(@"Twitter Shown");
    }
    else if ([controller isKindOfClass:[FacebookView class]])
    {
        NSLog(@"Facebook Shown");
    }
    else if ([controller isKindOfClass:[MidasView class]])
    {
        NSLog(@"Midas Shown");
    }
}
- (void)baseSocialmediaAboutToShow:(BaseSocialmediaView *)controller
{
    if ([controller isKindOfClass:[TwitterView class]])
    {
        NSLog(@"Twitter About to Show");
    }
    else if ([controller isKindOfClass:[FacebookView class]])
    {
        NSLog(@"Facebook About to Show");
    }
    else if ([controller isKindOfClass:[MidasView class]])
    {
        NSLog(@"Midas About to Show");
    }
}
- (void)baseSocialmediaHidden:(BaseSocialmediaView *)controller
{
    if ([controller isKindOfClass:[TwitterView class]])
    {
        NSLog(@"Twitter Hidden");
    }
    else if ([controller isKindOfClass:[FacebookView class]])
    {
        NSLog(@"Facebook Hidden");
    }
    else if ([controller isKindOfClass:[MidasView class]])
    {
        NSLog(@"Midas Hidden");
    }
}
- (void)baseSocialmediaAboutToHide:(BaseSocialmediaView *)controller
{
    if ([controller isKindOfClass:[TwitterView class]])
    {
        NSLog(@"Twitter About to Hide");
    }
    else if ([controller isKindOfClass:[FacebookView class]])
    {
        NSLog(@"Facebook About to Hide");
    }
    else if ([controller isKindOfClass:[MidasView class]])
    {
        NSLog(@"Midas About to Hide");
    }
}

#pragma mark Touches
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
    if ([twitview isVisible])
    {    
        [twitview hideView:0.5];
    }
    if ([faceview isVisible])
    {
        [faceview hideView:0.5];
    }
    if ([midasview isVisible])
    {
        [midasview hideView:0.5];
    }
}

@end
