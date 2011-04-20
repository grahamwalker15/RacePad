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
#import "RacePadSponsor.h"

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
	[ip_address_edit_ setText:[[RacePadPrefs Instance] getPref:@"preferredServerAddress"]];
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
	NSString *preferredSession = [[RacePadPrefs Instance] getPref:@"preferredSession"];
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
			
			if ( [file compare:@"event.rpf"] == NSOrderedSame )
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
	NSString *preferredEvent = [[RacePadPrefs Instance] getPref:@"preferredEvent"];
	for ( int i = 0; i < count; i++ )
	{
		NSString *fileName = [contents objectAtIndex:i];
		NSArray *nameChunks = [fileName componentsSeparatedByString:@"-"];
		if ( [nameChunks count] == 3 )
		{
			NSString *name = [nameChunks objectAtIndex:0];
			NSString *file = [nameChunks objectAtIndex:2];
		
			if ( [file compare:@"event.rpf"] == NSOrderedSame )
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

- (void)viewWillAppear:(BOOL)animated;    // Called when the view is about to made visible. Default does nothing
{
	[[RacePadCoordinator Instance] RegisterViewController:self WithTypeMask:RPC_SETTINGS_VIEW_];
	[[RacePadCoordinator Instance] SetViewDisplayed:[self view]];
	[self updateServerState];
	[self updateConnectionType];
	[self updateEvents];
	NSNumber *v = [[RacePadPrefs Instance]getPref:@"supportVideo"];
	if ( v )
		supportVideo.on = [v boolValue];
	[self updateSponsor];
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

- (void) updateServerState
{
	if ( [[RacePadCoordinator Instance] connectionType] == RPC_SOCKET_CONNECTION_ )
	{
		[connect setTitle:@"Disconnect" forState:UIControlStateNormal];
		[status setText:@"Connected to server"];
	}
	else
	{
		[connect setTitle:@"Connect" forState:UIControlStateNormal];
		[status setText:@"Working offline"];
	}
}

- (void) updateConnectionType
{
	[self updateServerState];
}

- (void) updateSponsor
{
	supportVideo.enabled = [[RacePadSponsor Instance]supportsTab:RPS_VIDEO_TAB_];
}

/////////////////////////////////////////////////////////////////////
// Class specific methods

-(IBAction)IPAddressChanged:(id)sender
{
	NSString *text = [sender text];
	[[RacePadCoordinator Instance] SetServerAddress:text ShowWindow:YES];
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
		[[RacePadCoordinator Instance] SetServerAddress:text ShowWindow:YES];
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
	[[RacePadPrefs Instance] setPref:@"supportVideo" Value:v];
	[[RacePadPrefs Instance] save];
	[[RacePadCoordinator Instance] updateTabs];
}


@end
