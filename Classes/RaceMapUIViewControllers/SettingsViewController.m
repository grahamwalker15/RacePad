    //
//  SettingsViewController.m
//  RacePad
//
//  Created by Gareth Griffith on 10/11/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "SettingsViewController.h"
#import "RaceMapCoordinator.h"
#import "BasePadMedia.h"
#import	"BasePadPrefs.h"
#import "RaceMapSponsor.h"

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	[[RaceMapCoordinator Instance] setSettingsViewController:self];
	[[RaceMapCoordinator Instance] AddView:[self view] WithType:RPC_SETTINGS_VIEW_];
	[ip_address_edit_ setText:[[BasePadPrefs Instance] getPref:@"preferredServerAddress"]];
	[mc_ip_address_edit_ setText:[[BasePadPrefs Instance] getPref:@"preferredMCServerAddress"]];
}


- (BOOL) wantTimeControls
{
	return NO;
}

- (void)viewWillAppear:(BOOL)animated;    // Called when the view is about to made visible.
{
	[[RaceMapCoordinator Instance] RegisterViewController:self WithTypeMask:RPC_SETTINGS_VIEW_];
	[[RaceMapCoordinator Instance] SetViewDisplayed:[self view]];
	[self updateServerState];
	[self updateConnectionType];
	[self updateSponsor];
}

- (void)viewWillDisappear:(BOOL)animated; // Called when the view is dismissed, covered or otherwise hidden. Default does nothing
{
	[[RaceMapCoordinator Instance] SetViewHidden:[self view]];
	[[RaceMapCoordinator Instance] ReleaseViewController:self];
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

- (void) updateServerState
{
	if ( [[RaceMapCoordinator Instance] connectionType] == BPC_SOCKET_CONNECTION_ )
	{
		[connect setTitle:@"Disconnect" forState:UIControlStateNormal];
		[status setText:@"Connected to server"];
	}
	else
	{
		[connect setTitle:@"Connect" forState:UIControlStateNormal];
		[status setText:@"Working offline"];
	}
		
	[serverTwirl setHidden:true];
    
    // Do the MC State here

}

- (void) updateConnectionType
{
	[self updateServerState];
}

- (void) updateSponsor
{
}

/////////////////////////////////////////////////////////////////////
// Class specific methods

-(IBAction)IPAddressChanged:(id)sender
{
	NSString *text = [sender text];
	[[RaceMapCoordinator Instance] SetServerAddress:text ShowWindow:YES LightRestart:false];
}

-(IBAction)connectPressed:(id)sender
{
	if ( [[RaceMapCoordinator Instance] serverConnected] )
	{
		[[RaceMapCoordinator Instance] disconnect];
		[self updateConnectionType];
	}
	else
	{
		NSString *text = [ip_address_edit_ text];
		[[RaceMapCoordinator Instance] SetServerAddress:text ShowWindow:YES LightRestart:false];
		[serverTwirl setHidden:false];
	}
}

-(IBAction)mcIPAddressChanged:(id)sender
{
	NSString *text = [sender text];
    [[BasePadPrefs Instance] setPref:@"preferredMCServerAddress" Value:text];
    [[BasePadPrefs Instance] save];
}

-(IBAction)exitPressed:(id)sender
{
	[[RaceMapCoordinator Instance] userExit];
}

-(IBAction)restartPressed:(id)sender
{
	[[RaceMapCoordinator Instance] userRestart];
}

@end
