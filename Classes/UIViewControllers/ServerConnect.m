    //
//  ServerConnect.m
//  RacePad
//
//  Created by Mark Riches on 04/11/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ServerConnect.h"
#import "RacePadCoordinator.h"
#import "RacePadPrefs.h"
#import "RacePadAppDelegate.h"

@implementation ServerConnect

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		[self setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
		[self setModalPresentationStyle:UIModalPresentationFormSheet];
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[whirl setHidesWhenStopped:YES];
    [super viewDidLoad];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


- (void)dealloc {
	[label release];
	[whirl release];
	[retry release];
	[settings release];

    [super dealloc];
}

- (void) timeout: (NSTimer *)theTimer
{
	timer = nil;
	if ( shouldBePoppedDown )
	{
		[self dismissModalViewControllerAnimated:YES];
	}
	else
	{
		[self connectionTimeout];
	}
}

- (void) connectionTimeout
{
	[[RacePadCoordinator Instance] connectionTimeout];
	[label setText:@"Connection not available"];
	[whirl stopAnimating];
	[retry setEnabled:YES];
	[settings setEnabled:YES];
}

- (void) viewDidAppear:(BOOL)animated
{
	if ( shouldBePoppedDown )
	{
		[self dismissModalViewControllerAnimated:YES];
	}
	else
	{
		// on first try, just give it 3 secs
		timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(timeout:) userInfo:nil repeats:NO];
	}
}

- (void)viewWillAppear:(BOOL)animated;    // Called when the view is about to made visible. Default does nothing
{
	[label setText:@"Connecting"];
	[whirl startAnimating];
	[retry setEnabled:NO];
	[settings setEnabled:NO];
	
	shouldBePoppedDown = false;
}

- (void) popDown
{
	// There's some wierd race condition where if we try to popdown, while we're popping up, then we end up appearing
	[self dismissModalViewControllerAnimated:YES];
	shouldBePoppedDown = true;
}

- (void) badVersion
{
	[timer invalidate];
	timer = nil;
	[[RacePadCoordinator Instance] connectionTimeout];
	[label setText:@"Server version does not match this client"];
	[whirl stopAnimating];
	[retry setEnabled:YES];
	[settings setEnabled:YES];
}

-(void) retryPressed:(id)sender
{
	[label setText:@"Connecting"];
	[whirl startAnimating];
	[retry setEnabled:NO];
	[settings setEnabled:NO];
	
	// on re-try, give it 15 secs
	timer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(timeout:) userInfo:nil repeats:NO];
	[[RacePadCoordinator Instance] SetServerAddress:[[RacePadPrefs Instance] getPref:@"preferredServerAddress"] ShowWindow:NO];
}

-(void) settingsPressed:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
	RacePadAppDelegate *app = (RacePadAppDelegate *)[[UIApplication sharedApplication] delegate];
	UITabBarController *tabControl = [app tabBarController];
	if ( tabControl )
	{
		NSArray *tabs = [tabControl viewControllers];
		// Assume Settings is the final one
		if ( [tabs count] )
			[tabControl setSelectedViewController:[tabs objectAtIndex:[tabs count]-1]];
	}
}

@end
