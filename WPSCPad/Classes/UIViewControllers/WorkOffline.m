    //
//  WorkOffline.m
//  RacePad
//
//  Created by Mark Riches on 05/11/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WorkOffline.h"
#import "BasePadPrefs.h"
#import "RacePadCoordinator.h"
#import "BasePadMedia.h"
#import "RacePadAppDelegate.h"
#import "RacePadSponsor.h"

@implementation WorkOffline

@synthesize animatedDismissal;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
	{
		events = [[NSMutableArray alloc] init];
		sessions = [[NSMutableArray alloc] init];
		[self setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
		[self setModalPresentationStyle:UIModalPresentationFormSheet];
		
		animatedDismissal = true;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	[ip_address_edit_ setText:[[BasePadPrefs Instance] getPref:@"preferredServerAddress"]];
	[self updateServerState:@""];

	[backgroundView setStyle:BG_STYLE_TRANSPARENT_];
	[online setButtonColour:[UIColor colorWithRed:0.3 green:1.0 blue:0.3 alpha:1.0]];
	[online setShine:0.5];
	
	[online setOutline:true];
	[ok setOutline:true];
	
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
		[ok setEnabled:YES];
	else
		[ok setEnabled:NO];
}

- (void)viewWillAppear:(BOOL)animated;    // Called when the view is about to made visible. Default does nothing
{
	logo.image = [[RacePadSponsor Instance] getSponsorLogo:BPS_LOGO_BIG_];
	
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
		[self updateSessions: [event selectedRowInComponent:0]];
	}
	else
    {
		[ok setEnabled:NO];
    }
    
    [[BasePadCoordinator Instance] AddConnectionFeedbackDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[BasePadCoordinator Instance] RemoveConnectionFeedbackDelegate:self];
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

- (IBAction)okPressed:(id)sender
{
	int eventIndex = [event selectedRowInComponent:0];
	int sessionIndex = [event selectedRowInComponent:1];
	if ( [events count] > eventIndex
	  && [sessions count] > sessionIndex )
	{
		NSString *eventName = [events objectAtIndex:eventIndex];
		NSString *sessionName = [sessions objectAtIndex:sessionIndex];
	
		if ( eventName != nil && [eventName length] > 0
		  && sessionName != nil && [sessionName length] > 0 )
		{
			[self dismissModalViewControllerAnimated:animatedDismissal];
			[[RacePadCoordinator Instance] loadSession:eventName Session:sessionName];
		}
	}
}

- (IBAction)onlinePressed:(id)sender
{
	[self dismissModalViewControllerAnimated:NO];
	
	NSString * serverAddress = [[BasePadPrefs Instance] getPref:@"preferredServerAddress"];
	
	if(serverAddress && [serverAddress length] > 0)
		[[RacePadCoordinator Instance] SetServerAddress:serverAddress ShowWindow:YES LightRestart:false];
	
	NSString * videoServerAddress = [[BasePadPrefs Instance] getPref:@"preferredVideoServerAddress"];
	
	if(videoServerAddress && [videoServerAddress length] > 0)
	{
		[[BasePadMedia Instance] connectToVideoServer];
		[[BasePadMedia Instance] resetConnectionCounts];
	}
}

- (IBAction)settingsPressed:(id)sender
{
	[self dismissModalViewControllerAnimated:animatedDismissal];
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

-(IBAction)IPAddressChanged:(id)sender
{
    /*
	NSString *text = [sender text];
	[[RacePadCoordinator Instance] SetServerAddress:text ShowWindow:YES LightRestart:false];
     */
}

-(IBAction)connectPressed:(id)sender
{
	if ( [[RacePadCoordinator Instance] serverConnected] )
	{
		[[RacePadCoordinator Instance] disconnect];
		[self updateServerState:@"Working offline"];
	}
	else
	{
		NSString *text = [ip_address_edit_ text];
		[[RacePadCoordinator Instance] SetServerAddress:text ShowWindow:YES LightRestart:false];
		[serverTwirl setHidden:false];
        [serverTwirl startAnimating];
        
        [self updateServerState:@"Trying to connect..."];
	}
}

- (void) updateServerState:(NSString *)message;
{
	if ( [[RacePadCoordinator Instance] connectionType] == BPC_SOCKET_CONNECTION_ )
	{
		[connect setTitle:@"Disconnect" forState:UIControlStateNormal];
		[status setText:@"Connected to server"];
	}
	else
	{
		[connect setTitle:@"Connect" forState:UIControlStateNormal];
		[status setText:message];
	}    
}

// ConnectionFeedbackDelegate methods

- (void)notifyConnectionSucceeded
{
    
	[serverTwirl setHidden:true];
    [serverTwirl stopAnimating];

    [self updateServerState:@"Connected to server"];
    [self dismissModalViewControllerAnimated:animatedDismissal];
}

- (void)notifyConnectionRetry
{
    [self updateServerState:@"Trying again to connect..."];
}

- (void)notifyConnectionTimeout
{
    
	[serverTwirl setHidden:true];
    [serverTwirl stopAnimating];

    [self updateServerState:@"Connection attempt timed out"];
}

- (void)notifyConnectionFailed
{
    
	[serverTwirl setHidden:true];
    [serverTwirl stopAnimating];

    [self updateServerState:@"Connection failed"];
}


@end
