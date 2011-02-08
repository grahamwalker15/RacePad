//
//  HTMLViewController.m
//  RacePad
//
//  Created by Gareth Griffith on 10/14/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "HTMLViewController.h"

#import "InfoViewController.h"

@implementation HTMLViewController

@synthesize htmlFile;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
	{
		// This view is always displayed as a subview
		// Set the style for its presentation
		[self setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
		[self setModalPresentationStyle:UIModalPresentationCurrentContext];
		
		htmlFile = nil;		 
	}
    return self;
}

- (void)viewDidLoad
{
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


- (void)viewWillAppear:(BOOL)animated
{
	if(htmlFile)
	{
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *docsFolder = [paths objectAtIndex:0];
		NSString *folder = [docsFolder stringByAppendingPathComponent:@"LocalHTML"];
		NSString *fileName = [folder stringByAppendingPathComponent:htmlFile];
		NSURL *url = [NSURL fileURLWithPath:fileName];
		
		NSURLRequest * request = [[NSURLRequest alloc] initWithURL:url];
		[webView loadRequest:request];
		
		[request release];
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
}

- (void)dealloc
{
    [super dealloc];
}

- (IBAction)backPressed:(id)sender
{
	[(InfoViewController *)[self parentViewController] hideChildController:true];
}

- (IBAction)previousPressed:(id)sender
{	
}

- (IBAction)nextPressed:(id)sender
{
}

@end
