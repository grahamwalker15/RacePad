//
//  HTMLViewController.m
//  RacePad
//
//  Created by Gareth Griffith on 10/14/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "HTMLViewController.h"


@implementation HTMLViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	NSString * url_string = @"http://www.autosport.com";
	NSURL * url = [[NSURL alloc] initWithString:url_string];
	NSURLRequest * request = [[NSURLRequest alloc] initWithURL:url];
	[(UIWebView *)self.view loadRequest:request];
		 
	[url release];
	[request release];
	[super viewDidLoad];
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc
{
    [super dealloc];
}


@end
