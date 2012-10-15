    //
//  SettingsViewController.m
//  MatchPad
//
//  Created by Gareth Griffith on 10/11/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "SettingsViewController.h"
#import "MatchPadCoordinator.h"
#import "BasePadMedia.h"
#import	"BasePadPrefs.h"
#import "MatchPadSponsor.h"

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	[[MatchPadCoordinator Instance] setSettingsViewController:self];
	[[MatchPadCoordinator Instance] AddView:[self view] WithType:MPC_SETTINGS_VIEW_];
	[ip_address_edit_ setText:[[BasePadPrefs Instance] getPref:@"preferredServerAddress"]];
	[video_ip_address_edit_ setText:[[BasePadPrefs Instance] getPref:@"preferredVideoServerAddress"]];
}


- (BOOL) wantTimeControls
{
	return NO;
}

- (void) updateSessions: (int) row
{
	[sessions removeAllObjects];
	
	if ( row < 0 || row >= [events count] )
		return;
	
	NSFileManager *fm =	[[NSFileManager alloc]init];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docsFolder = [paths objectAtIndex:0];
	
	NSArray *contents = [fm contentsOfDirectoryAtPath:docsFolder error:NULL];
	int count = [contents count];
	int preferredIndex = -1;
	NSString *preferredSession = [[BasePadPrefs Instance] getPref:@"preferredSession"];
	NSString *eventName = [events objectAtIndex:row];

	for ( int i = 0; i < count; i++ )
	{
		NSString *fileName = [contents objectAtIndex:i];
		NSArray *nameChunks = [fileName componentsSeparatedByString:@"-"];
		if ( [nameChunks count] == 3 )
		{
			NSString *name = [nameChunks objectAtIndex:0];
			NSString *session = [nameChunks objectAtIndex:1];
			NSString *file = [nameChunks objectAtIndex:2];
			
			if ( [file compare:@"match_pad.mpa"] == NSOrderedSame )
			{
				if ( [name compare:eventName] == NSOrderedSame )
				{
					if ( [session compare:preferredSession] == NSOrderedSame )
						preferredIndex = [sessions count];
					else if ( preferredIndex < 0 )
						preferredIndex = [sessions count];
					[sessions addObject:session];
				}
			}
		}
	}
	
	[fm release];
	[event reloadComponent:1];
	
	if ( count )
	{
		if ( preferredIndex >= 0 )
		{
			[event selectRow:preferredIndex inComponent:1 animated:YES];
		}
	}
	
	eventName = [events objectAtIndex:[event selectedRowInComponent:0]];
	NSString *sessionName = [sessions objectAtIndex:[event selectedRowInComponent:1]];
	
	if ( eventName != nil && [eventName length] > 0
	  && sessionName != nil && [sessionName length] > 0 )
		[loadArchive setEnabled:YES];
	else
		[loadArchive setEnabled:NO];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	if ( component == 0 )
		return [events count];
	if ( component == 1 )
		return [sessions count];
	return 0;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	return 40;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	if ( component == 0 )
		return [events objectAtIndex:row];
	return [sessions objectAtIndex:row];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	if ( component == 0 )
		return 150;
	return 115;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	if ( component == 0 )
	{
		[self updateSessions: row];
	}
	
}

- (void)updateEvents
{
	if ( !events )
	{
		events = [[NSMutableArray alloc] init];
		sessions = [[NSMutableArray alloc] init];
	}
	[events removeAllObjects];
	[sessions removeAllObjects];
	NSFileManager *fm =	[[NSFileManager alloc]init];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docsFolder = [paths objectAtIndex:0];
	
	NSArray *contents = [fm contentsOfDirectoryAtPath:docsFolder error:NULL];
	int count = [contents count];
	int preferredIndex = -1;
	NSString *preferredEvent = [[BasePadPrefs Instance] getPref:@"preferredEvent"];
	for ( int i = 0; i < count; i++ )
	{
		NSString *fileName = [contents objectAtIndex:i];
		NSArray *nameChunks = [fileName componentsSeparatedByString:@"-"];
		if ( [nameChunks count] == 3 )
		{
			NSString *name = [nameChunks objectAtIndex:0];
			NSString *file = [nameChunks objectAtIndex:2];
		
			if ( [file compare:@"match_pad.mpa"] == NSOrderedSame )
			{
				int eventsCount = [events count];
				bool matched = false;
				for ( int i = 0; i < eventsCount; i++ )
				{
					NSString *s = [events objectAtIndex:i];
					if ( [s compare:name] == NSOrderedSame )
					{
						matched = true;
						break;
					}
				}
				if ( !matched )
				{
					if ( [name compare:preferredEvent] == NSOrderedSame )
						preferredIndex = [events count];
					else if ( preferredIndex == -1 )
						preferredIndex = [events count];
					[events addObject:name];
				}
			}
		}
	}
	
	[fm release];	
	
	if ( count )
	{
		[event reloadComponent:0];
		if ( preferredIndex >= 0 )
		{
			[event selectRow:preferredIndex inComponent:0 animated:NO]; // If you animate this, then you'll get the wrong selectedValue below
		}
		[self updateSessions: preferredIndex];
	}
	else
		[loadArchive setEnabled:NO];
}

- (void)viewWillAppear:(BOOL)animated;    // Called when the view is about to made visible.
{
	[[MatchPadCoordinator Instance] RegisterViewController:self WithTypeMask:MPC_SETTINGS_VIEW_];
	[[MatchPadCoordinator Instance] SetViewDisplayed:[self view]];
	[self updateServerState];
	[self updateConnectionType];
	[self updateEvents];
	NSNumber *v = [[BasePadPrefs Instance]getPref:@"supportVideo"];
	if ( v )
		supportVideo.on = [v boolValue];
	v = [[BasePadPrefs Instance]getPref:@"playerTrails"];
	if ( v )
		playerTrails.on = [v boolValue];
	v = [[BasePadPrefs Instance]getPref:@"playerPos"];
	if ( v )
		playerPos.on = [v boolValue];
	v = [[BasePadPrefs Instance]getPref:@"passes"];
	if ( v )
		passes.on = [v boolValue];
	v = [[BasePadPrefs Instance]getPref:@"passNames"];
	if ( v )
		passNames.on = [v boolValue];
	v = [[BasePadPrefs Instance]getPref:@"ballTrail"];
	if ( v )
		ballTrail.on = [v boolValue];
	[self updateSponsor];
}

- (void)viewWillDisappear:(BOOL)animated; // Called when the view is dismissed, covered or otherwise hidden. Default does nothing
{
	[[MatchPadCoordinator Instance] SetViewHidden:[self view]];
	[[MatchPadCoordinator Instance] ReleaseViewController:self];
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
	[events release];
	[sessions release];
}

- (void) updateServerState
{
	if ( [[MatchPadCoordinator Instance] connectionType] == BPC_SOCKET_CONNECTION_ )
	{
		[connect setTitle:@"Disconnect" forState:UIControlStateNormal];
		[status setText:@"Connected to server"];
	}
	else
	{
		[connect setTitle:@"Connect" forState:UIControlStateNormal];
		[status setText:@"Working offline"];
	}
	
	if ( [[BasePadMedia Instance] currentStatus] == BPM_CONNECTED_ )
	{
		[video_connect setTitle:@"Disconnect" forState:UIControlStateNormal];
		[video_status setText:@"Connected to server"];
		[videoServerTwirl stopAnimating];
		[videoServerTwirl setHidden:true];
	}
	else
	{
		[video_connect setTitle:@"Connect" forState:UIControlStateNormal];
		
		if( [[BasePadMedia Instance] currentStatus] == BPM_CONNECTION_ERROR_ )
		{
			NSString * reportString = [NSString  stringWithString:@"Connection error :"];
			if([[BasePadMedia Instance] currentError])
				reportString = [reportString stringByAppendingString:[[BasePadMedia Instance] currentError]];
			else
				reportString = [reportString stringByAppendingString:@"Unknown error"];
			
			[video_status setText:reportString];
			[videoServerTwirl stopAnimating];
			[videoServerTwirl setHidden:true];
			
			[reportString release];
		}
		else if( [[BasePadMedia Instance] currentStatus] == BPM_CONNECTION_FAILED_ )
		{
			NSString * reportString = [NSString stringWithString:@"Connection failed :"];
			
			if([[BasePadMedia Instance] currentError])
				reportString = [reportString stringByAppendingString:[[BasePadMedia Instance] currentError]];
			else
				reportString = [reportString stringByAppendingString:@"Unknown error"];
			
			[video_status setText:reportString];
			[videoServerTwirl stopAnimating];
			[videoServerTwirl setHidden:true];
			
		}
		else if( [[BasePadMedia Instance] currentStatus] == BPM_TRYING_TO_CONNECT_ )
		{
			[video_status setText:@"Connecting...."];
			[videoServerTwirl setHidden:false];
			[videoServerTwirl startAnimating];
		}
		else
		{
			[video_status setText:@"Not connected"];
			[videoServerTwirl stopAnimating];
			[videoServerTwirl setHidden:true];
		}
	}
	
	[serverTwirl setHidden:true];

}

- (void) updateConnectionType
{
	[self updateServerState];
}

- (void) updateSponsor
{
	supportVideo.enabled = true;//[[MatchPadSponsor Instance]supportsTab:RPS_VIDEO_TAB_];
}

/////////////////////////////////////////////////////////////////////
// Class specific methods

-(IBAction)IPAddressChanged:(id)sender
{
	NSString *text = [sender text];
	[[MatchPadCoordinator Instance] SetServerAddress:text ShowWindow:YES LightRestart:false];
}

-(IBAction)connectPressed:(id)sender
{
	if ( [[MatchPadCoordinator Instance] serverConnected] )
	{
		[[MatchPadCoordinator Instance] disconnect];
		[self updateConnectionType];
	}
	else
	{
		NSString *text = [ip_address_edit_ text];
		[[MatchPadCoordinator Instance] SetServerAddress:text ShowWindow:YES LightRestart:false];
		[serverTwirl setHidden:false];

	}
}

-(IBAction)videoIPAddressChanged:(id)sender
{
	NSString *text = [sender text];
	[[MatchPadCoordinator Instance] SetVideoServerAddress:text];
}

-(IBAction)videoConnectPressed:(id)sender
{
	if ( [[MatchPadCoordinator Instance] videoConnectionStatus] == BPC_CONNECTION_SUCCEEDED_ )
	{
		[[BasePadMedia Instance] disconnectVideoServer];
	}
	else if ( [[MatchPadCoordinator Instance] videoConnectionStatus] != BPC_CONNECTION_CONNECTING_ )
	{
		[videoServerTwirl setHidden:false];
		[videoServerTwirl startAnimating];
		[[BasePadMedia Instance] connectToVideoServer];
	}
}

- (IBAction)loadPressed:(id)sender
{
	NSString *eventName = [events objectAtIndex:[event selectedRowInComponent:0]];
	NSString *sessionName = [sessions objectAtIndex:[event selectedRowInComponent:1]];
	
	if ( eventName != nil && [eventName length] > 0
	  && sessionName != nil && [sessionName length] > 0 )
	{
		[[MatchPadCoordinator Instance] loadSession:eventName Session:sessionName];
	}
}

-(IBAction)exitPressed:(id)sender
{
	[[MatchPadCoordinator Instance] userExit];
}

-(IBAction)restartPressed:(id)sender
{
	[[MatchPadCoordinator Instance] userRestart];
}

- (IBAction)supportVideoChanged:(id)sender
{
	NSNumber *v = [NSNumber numberWithBool:supportVideo.on ];
	[[BasePadPrefs Instance] setPref:@"supportVideo" Value:v];
	[[BasePadPrefs Instance] save];
	[[MatchPadCoordinator Instance] updateTabs];
}

- (IBAction)playerTrailsChanged:(id)sender
{
	NSNumber *v = [NSNumber numberWithBool:playerTrails.on ];
	[[BasePadPrefs Instance] setPref:@"playerTrails" Value:v];
	[[BasePadPrefs Instance] save];
}

- (IBAction)playerPosChanged:(id)sender
{
	NSNumber *v = [NSNumber numberWithBool:playerPos.on ];
	[[BasePadPrefs Instance] setPref:@"playerPos" Value:v];
	[[BasePadPrefs Instance] save];
}

- (IBAction)passesChanged:(id)sender
{
	NSNumber *v = [NSNumber numberWithBool:passes.on ];
	[[BasePadPrefs Instance] setPref:@"passes" Value:v];
	[[BasePadPrefs Instance] save];
}

- (IBAction)passNamesChanged:(id)sender
{
	NSNumber *v = [NSNumber numberWithBool:passNames.on ];
	[[BasePadPrefs Instance] setPref:@"passNames" Value:v];
	[[BasePadPrefs Instance] save];
}

- (IBAction)ballTrailChanged:(id)sender
{
	NSNumber *v = [NSNumber numberWithBool:ballTrail.on ];
	[[BasePadPrefs Instance] setPref:@"ballTrail" Value:v];
	[[BasePadPrefs Instance] save];	[[MatchPadCoordinator Instance] updateTabs];
}


@end
