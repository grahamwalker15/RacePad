    //
//  SettingsViewController.m
//  RacePad
//
//  Created by Gareth Griffith on 10/11/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "SettingsViewController.h"
#import "RacePadCoordinator.h"
#import "BasePadMedia.h"
#import	"BasePadPrefs.h"
#import "RacePadSponsor.h"
#import "CommentaryBubble.h"
#import "AccidentBubble.h"

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	[[RacePadCoordinator Instance] setSettingsViewController:self];
	[[RacePadCoordinator Instance] AddView:[self view] WithType:RPC_SETTINGS_VIEW_];
	
	[self updateServerAddresses];
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
			
			if ( [file compare:@"race_pad.rpa"] == NSOrderedSame )
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
		
			if ( [file compare:@"race_pad.rpa"] == NSOrderedSame )
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
	[[RacePadCoordinator Instance] RegisterViewController:self WithTypeMask:RPC_SETTINGS_VIEW_];
	[[RacePadCoordinator Instance] SetViewDisplayed:[self view]];
	[self updateServerState];
	[self updateConnectionType];
	[self updateEvents];
	NSNumber *v = [[BasePadPrefs Instance]getPref:@"supportVideo"];
	if ( v )
		supportVideo.on = [v boolValue];
	if ( [[CommentaryBubble Instance] bubblePref] )
	{
		if ( [[CommentaryBubble Instance] bubbleCommentaryPref] )
		{
			bubbleType.selectedSegmentIndex = 0;
		}
		else
		{
			bubbleType.selectedSegmentIndex = 1;
		}
	}
	else
	{
		bubbleType.selectedSegmentIndex = 2;
	}

	diagnosticsSwitch.on = [[BasePadCoordinator Instance] diagnostics];
	[self updateSponsor];

	[[CommentaryBubble Instance] noBubbles];
	
	if ( [[RacePadSponsor Instance] supportsLocation] )
	{
		[locationLabel setHidden:false];
		[locationSwitch setHidden:false];
		if ( [[RacePadCoordinator Instance] dataServerType] == RPC_TRACK_SERVER_ )
			locationSwitch.selectedSegmentIndex = 2;
		else if ( [AccidentBubble Instance].bubblePref )
			locationSwitch.selectedSegmentIndex = 1;
		else
			locationSwitch.selectedSegmentIndex = 0;
	}
	else
	{
		[locationLabel setHidden:true];
		[locationSwitch setHidden:true];
	}
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
    [super dealloc];
	[events release];
	[sessions release];
}

- (void) updateServerAddresses
{
	if ( [[RacePadCoordinator Instance] dataServerType] == RPC_NORMAL_SERVER_ )
	{
		[video_ip_address_edit_ setHidden:false];
		[video_status setHidden:false];
		[video_connect setHidden:false];
		[video_label setHidden:false];
		
		[ip_address_edit_ setText:[[BasePadPrefs Instance] getPref:@"preferredServerAddress"]];
		[video_ip_address_edit_ setText:[[BasePadPrefs Instance] getPref:@"preferredVideoServerAddress"]];
	}
	else
	{
		[video_ip_address_edit_ setHidden:true];
		[video_status setHidden:true];
		[video_connect setHidden:true];
		[video_label setHidden:true];
		[videoServerTwirl setHidden:true];
		
		[ip_address_edit_ setText:[[BasePadPrefs Instance] getPref:@"preferredTrackServerAddress"]];
	}
}

- (void) updateServerState
{
	if ( [[RacePadCoordinator Instance] connectionType] == BPC_SOCKET_CONNECTION_ )
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
		[video_connect setEnabled:true];
		[video_status setText:@"Connected to server"];
		[videoServerTwirl stopAnimating];
		[videoServerTwirl setHidden:true];
	}
	else
	{
		[video_connect setTitle:@"Connect" forState:UIControlStateNormal];
		
		if([[RacePadCoordinator Instance] videoConnectionStatus] == BPC_CONNECTION_CONNECTING_)
			[video_connect setEnabled:false];
		else
			[video_connect setEnabled:true];
		
		if( [[BasePadMedia Instance] currentStatus] == BPM_CONNECTION_ERROR_ )
		{
			NSString * reportString = @"Connection error :";
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
			NSString * reportString = @"Connection failed :";
			
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
		else if( [[BasePadMedia Instance] currentStatus] == BPM_WAITING_FOR_STREAM_ )
		{
			[video_status setText:@"Waiting for stream...."];
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
	supportVideo.enabled = true;//[[RacePadSponsor Instance]supportsTab:RPS_VIDEO_TAB_];
	bubbleType.enabled = true;
}

/////////////////////////////////////////////////////////////////////
// Class specific methods

-(IBAction)IPAddressChanged:(id)sender
{
	NSString *text = [sender text];
	[[RacePadCoordinator Instance] SetServerAddress:text ShowWindow:YES LightRestart:false];
}

-(IBAction)connectPressed:(id)sender
{
	if ( [[RacePadCoordinator Instance] serverConnected] )
	{
		[[RacePadCoordinator Instance] disconnect];
		[self updateConnectionType];
	}
	else
	{
		NSString *text = [ip_address_edit_ text];
		[[RacePadCoordinator Instance] SetServerAddress:text ShowWindow:YES LightRestart:false];
		[serverTwirl setHidden:false];

	}
}

-(IBAction)videoIPAddressChanged:(id)sender
{
	NSString *text = [sender text];
	[[RacePadCoordinator Instance] SetVideoServerAddress:text];
}

-(IBAction)videoConnectPressed:(id)sender
{
	if ( [[RacePadCoordinator Instance] videoConnectionStatus] == BPC_CONNECTION_SUCCEEDED_ )
	{
		[[BasePadMedia Instance] disconnectVideoServer];
	}
	else if ( [[RacePadCoordinator Instance] videoConnectionStatus] != BPC_CONNECTION_CONNECTING_ )
	{
		[videoServerTwirl setHidden:false];
		[videoServerTwirl startAnimating];
		NSString *text = [video_ip_address_edit_ text];
		[[RacePadCoordinator Instance] SetVideoServerAddress:text];
		[[BasePadMedia Instance] connectToVideoServer];
		[[BasePadMedia Instance] resetConnectionCounts];
	}
}

- (IBAction)loadPressed:(id)sender
{
	NSString *eventName = [events objectAtIndex:[event selectedRowInComponent:0]];
	NSString *sessionName = [sessions objectAtIndex:[event selectedRowInComponent:1]];
	
	if ( eventName != nil && [eventName length] > 0
	  && sessionName != nil && [sessionName length] > 0 )
	{
		[[RacePadCoordinator Instance] loadSession:eventName Session:sessionName];
	}
}

-(IBAction)exitPressed:(id)sender
{
	[[RacePadCoordinator Instance] userExit];
}

-(IBAction)restartPressed:(id)sender
{
	[[RacePadCoordinator Instance] userRestart];
}

- (IBAction)supportVideoChanged:(id)sender
{
	NSNumber *v = [NSNumber numberWithBool:supportVideo.on ];
	[[BasePadPrefs Instance] setPref:@"supportVideo" Value:v];
	[[BasePadPrefs Instance] save];
	[[RacePadCoordinator Instance] updateTabs];
}

- (IBAction)bubbleTypeChanged:(id)sender
{
	int v = bubbleType.selectedSegmentIndex;
	[[BasePadPrefs Instance]setPref:@"bubblePref" Value:[NSNumber numberWithInt: v]];
	[[BasePadPrefs Instance] save];
	if ( v == 2 )
	{
		[[CommentaryBubble Instance] setBubblePref:false];
	}
	else
	{
		[CommentaryBubble Instance].bubbleCommentaryPref = (v == 0);
		[[CommentaryBubble Instance] setBubblePref:true];
	}
}

- (IBAction)diagnosticsChanged:(id)sender
{
	bool on = diagnosticsSwitch.on;
	[[BasePadCoordinator Instance] setDiagnostics:on];
}

-(IBAction)locationChanged:(id)sender
{
	int oldServerType = [[RacePadCoordinator Instance] dataServerType];
	
	int v = locationSwitch.selectedSegmentIndex;
	
	if(v == 0 || v == 1)
	{
		[[BasePadPrefs Instance]setPref:@"accidentPref" Value:[NSNumber numberWithInt: v]];
		[[BasePadPrefs Instance] save];
		[[AccidentBubble Instance] setBubblePref:( v == 1 )];
		
		[[RacePadCoordinator Instance] setDataServerType:RPC_NORMAL_SERVER_];
		[[BasePadPrefs Instance]setPref:@"dataServerType" Value:@"NORMAL"];
		[[BasePadPrefs Instance] save];
	}
	else
	{
		[[AccidentBubble Instance] setBubblePref:( false )];

		[[RacePadCoordinator Instance] setDataServerType:RPC_TRACK_SERVER_];
		[[BasePadPrefs Instance]setPref:@"dataServerType" Value:@"TRACK"];
		[[BasePadPrefs Instance] save];
	}
	
	int newServerType = [[RacePadCoordinator Instance] dataServerType];
	if(newServerType != oldServerType)
	{
		if ( [[RacePadCoordinator Instance] serverConnected] )
		{
			[[RacePadCoordinator Instance] disconnect];
			[self updateConnectionType];
		}
		
		if ( [[RacePadCoordinator Instance] videoConnectionStatus] == BPC_CONNECTION_SUCCEEDED_ )
		{
			[[BasePadMedia Instance] disconnectVideoServer];
		}

		[self updateServerAddresses];
	}
}

@end
