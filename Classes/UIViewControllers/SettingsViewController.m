    //
//  SettingsViewController.m
//  RacePad
//
//  Created by Gareth Griffith on 10/11/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "SettingsViewController.h"
#import "RacePadCoordinator.h"
#import	"RacePadPrefs.h"

@implementation SettingsViewController

/*
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    }
    return self;
}
*/
 
/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

- (void)viewDidLoad
{
    [super viewDidLoad];
	[[RacePadCoordinator Instance] setSettingsViewController:self];
	[[RacePadCoordinator Instance] AddView:[self view] WithType:RPC_SETTINGS_VIEW_];
	connectedImage = [[UIImage imageNamed:@"GPSGreen.png"] retain];
	disconnectedImage = [[UIImage imageNamed:@"GPSRed.png"] retain];
	[ip_address_edit_ setText:[[RacePadPrefs Instance] getPref:@"preferredServerAddress"]];
	changingMode = false;
}


- (void)viewWillAppear:(BOOL)animated;    // Called when the view is about to made visible. Default does nothing
{
	[[RacePadCoordinator Instance] RegisterViewController:self WithTypeMask:RPC_SETTINGS_VIEW_];
	[[RacePadCoordinator Instance] SetViewDisplayed:[self view]];
	[self updateServerState];
	[self updateConnectionType];
}

- (void)viewWillDisappear:(BOOL)animated; // Called when the view is dismissed, covered or otherwise hidden. Default does nothing
{
	[[RacePadCoordinator Instance] SetViewHidden:[self view]];
	[[RacePadCoordinator Instance] ReleaseViewController:self];
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
	[connectedImage release];
	[disconnectedImage release];
    [super dealloc];
}

- (void) updateServerState
{
	changingMode = true;
	if ( [[RacePadCoordinator Instance] serverConnected] )
	{
		[serverStatus setImage:connectedImage forState:UIControlStateNormal];
		[modeControl setEnabled:YES forSegmentAtIndex:0];
	}
	else
	{
		[serverStatus setImage:disconnectedImage forState:UIControlStateNormal];
		[modeControl setEnabled:NO forSegmentAtIndex:0];
	}
	changingMode = false;
}

- (void) updateConnectionType
{
	changingMode = true;
	if ( [[RacePadCoordinator Instance] connectionType] == RPC_SOCKET_CONNECTION_ )
	{
		[modeControl setSelectedSegmentIndex:0];
		[event setEnabled:NO];
	}
	else
	{
		[modeControl setSelectedSegmentIndex:1];
		[event setEnabled:YES];
	}
	changingMode = false;
}

/////////////////////////////////////////////////////////////////////
// Class specific methods

-(IBAction)IPAddressChanged:(id)sender
{
	NSString *text = [sender text];
	[[RacePadCoordinator Instance] SetServerAddress:text ShowWindow:YES];
}

-(IBAction)serverStatusPressed:(id)sender
{
	if ( ![[RacePadCoordinator Instance] serverConnected] )
	{
		NSString *text = [ip_address_edit_ text];
		[[RacePadCoordinator Instance] SetServerAddress:text ShowWindow:YES];
	}
}

-(IBAction)modeChanged:(id)sender
{
	if ( !changingMode )
	{
		if ( [modeControl selectedSegmentIndex] == 0 )
		{
			NSString *text = [ip_address_edit_ text];
			[[RacePadCoordinator Instance] SetServerAddress:text ShowWindow:YES];
		}
		else
			[[RacePadCoordinator Instance] goOffline];
	}
}

-(IBAction)eventPressed:(id)sender
{
	[[RacePadCoordinator Instance] goOffline];
}


@end
