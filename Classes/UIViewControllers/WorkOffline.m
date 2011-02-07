    //
//  WorkOffline.m
//  RacePad
//
//  Created by Mark Riches on 05/11/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WorkOffline.h"
#import "RacePadPrefs.h"
#import "RacePadCoordinator.h"
#import "RacePadAppDelegate.h"

@implementation WorkOffline

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		events = [[NSMutableArray alloc] init];
		sessions = [[NSMutableArray alloc] init];
		[self setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
		[self setModalPresentationStyle:UIModalPresentationFormSheet];
    }
    return self;
}

- (void)viewDidLoad
{
	[backgroundView setStyle:BG_STYLE_TRANSPARENT_];
	[online setButtonColour:[UIColor colorWithRed:0.3 green:1.0 blue:0.3 alpha:1.0]];
	[online setShine:0.5];
	
	[online setOutline:true];
	[ok setOutline:true];
	
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


- (void)dealloc {
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
	NSString *folder = [docsFolder stringByAppendingPathComponent:[events objectAtIndex:row]];
	
	NSArray *contents = [fm contentsOfDirectoryAtPath:folder error:NULL];
	int count = [contents count];
	int preferredIndex = -1;
	NSString *preferredSession = [[RacePadPrefs Instance] getPref:@"preferredSession"];
	for ( int i = 0; i < count; i++ )
	{
		NSString *name = [contents objectAtIndex:i];
		NSString *file = [folder stringByAppendingPathComponent:name];
		BOOL isDir;
		if ( [fm fileExistsAtPath:file isDirectory:&isDir] && isDir )
		{
			if ( [name compare:preferredSession] == NSOrderedSame )
				preferredIndex = [sessions count];
			[sessions addObject:name];
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

	NSString *eventName = [events objectAtIndex:[event selectedRowInComponent:0]];
	NSString *sessionName = [sessions objectAtIndex:[event selectedRowInComponent:1]];
	
	if ( eventName != nil && [eventName length] > 0
	  && sessionName != nil && [sessionName length] > 0 )
		[ok setEnabled:YES];
	else
		[ok setEnabled:NO];
}

- (void)viewWillAppear:(BOOL)animated;    // Called when the view is about to made visible. Default does nothing
{
	[events removeAllObjects];
	NSFileManager *fm =	[[NSFileManager alloc]init];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docsFolder = [paths objectAtIndex:0];
	
	NSArray *contents = [fm contentsOfDirectoryAtPath:docsFolder error:NULL];
	int count = [contents count];
	int preferredIndex = -1;
	NSString *preferredEvent = [[RacePadPrefs Instance] getPref:@"preferredEvent"];
	for ( int i = 0; i < count; i++ )
	{
		NSString *name = [contents objectAtIndex:i];
		NSString *file = [docsFolder stringByAppendingPathComponent:name];
		BOOL isDir;
		if ( [fm fileExistsAtPath:file isDirectory:&isDir] && isDir )
		{
			if ( [name compare:@"LocalHTML"] != NSOrderedSame
			  && [name compare:@"Data"] != NSOrderedSame ) // ignore the Data and LocalHTML folders
			{
				if ( [name compare:preferredEvent] == NSOrderedSame )
					preferredIndex = [events count];
				[events addObject:name];
			}
		}
	}
	
	[fm release];
	
	[sessions removeAllObjects];

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
		[ok setEnabled:NO];
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
			[self dismissModalViewControllerAnimated:YES];
			[[RacePadCoordinator Instance] loadSession:eventName Session:sessionName];
		}
	}
}

- (IBAction)onlinePressed:(id)sender
{
	[self dismissModalViewControllerAnimated:NO];
	[[RacePadCoordinator Instance] SetServerAddress:[[RacePadPrefs Instance] getPref:@"preferredServerAddress"] ShowWindow:YES];
}

- (IBAction)settingsPressed:(id)sender
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
