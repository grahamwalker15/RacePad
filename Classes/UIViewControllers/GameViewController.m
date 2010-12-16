//
//  GameViewController.m
//  RacePad
//
//  Created by Gareth Griffith on 10/11/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "GameViewController.h"
#import "RacePadCoordinator.h"
#import	"RacePadDatabase.h"
#import "UserPin.h"

@implementation GameViewController

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

	[leagueTable SetTableDataClass:[[RacePadDatabase Instance] competitorData]];
	
	[leagueTable SetRowHeight:30];
	[leagueTable SetHeading:true];

	[[RacePadCoordinator Instance] setGameViewController:self];
	[[RacePadCoordinator Instance] AddView:leagueTable WithType:RPC_GAME_VIEW_];
	changingSelection = false;
	locked = false;
	[action setTitleColor: [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:0.7] forState:UIControlStateDisabled];
	[changeUser setTitleColor: [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:0.7] forState:UIControlStateDisabled];
}


- (void)viewWillAppear:(BOOL)animated;    // Called when the view is about to made visible. Default does nothing
{
	[[RacePadCoordinator Instance] RegisterViewController:self WithTypeMask:RPC_GAME_VIEW_];
	[[RacePadCoordinator Instance] SetViewDisplayed:leagueTable];
	[self updatePrediction];

	// We disable the screen locking - because that seems to close the socket
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)viewWillDisappear:(BOOL)animated; // Called when the view is dismissed, covered or otherwise hidden. Default does nothing
{
	[[RacePadCoordinator Instance] SetViewHidden:[self view]];
	[[RacePadCoordinator Instance] ReleaseViewController:self];

	// re-enable the screen locking
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
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

/////////////////////////////////////////////////////////////////////
// Class specific methods

-(void)lock
{
	locked = true;
	// Assume rest getssorted when the new prediction turns up
}

-(void)unlock
{
	RacePrediction *p = [[RacePadDatabase Instance] racePrediction]; 
	if ( p.gameStatus == GS_NOT_STARTED )
	{
		if ( userPin == nil )
			userPin = [[UserPin alloc] initWithNibName:@"UserPin" bundle:nil];
		[userPin getPin:p.pin Controller:self];
	}
}

-(void) pinCorrect
{
	locked = false;
	action.enabled = YES;
	[action setTitle:@"Submit Change" forState:UIControlStateNormal ];
	[action setTitle:@"Submit Change" forState:UIControlStateHighlighted];
	reset.hidden = NO;
	result.allowsSelection = YES;
	drivers.allowsSelection = YES;
}

-(void) pinFailed
{
}

-(IBAction)newUserPressed:(id)sender
{
	action.enabled = YES;
	[action setTitle:@"Submit New" forState:UIControlStateNormal];
	[action setTitle:@"Submit New" forState:UIControlStateHighlighted];
	[[[RacePadDatabase Instance] racePrediction] clear];
	user.text = @"";
	[self updatePrediction];
}

-(IBAction)changeUserPressed:(id)sender
{
	if ( [[[RacePadDatabase Instance]competitorData] rows] )
	{
		if ( changeCompetitor == nil )
			changeCompetitor = [[ChangeCompetitor	alloc] initWithNibName:@"ChangeCompetitor" bundle:nil];
		[changeCompetitor getUser:self];
	}
}

-(bool) validName: (NSString *)name
{
	int count = [name length];
	bool all_spaces = true;
	for ( int i = 0; i < count; i++ )
		if ( [name characterAtIndex:i] != ' ' )
		{
			all_spaces = false;
			break;
		}
	if ( all_spaces )
	{
		UIAlertView *alert = [[UIAlertView alloc] init];
		alert.title = @"User Name";
		alert.cancelButtonIndex = [alert addButtonWithTitle:@"OK"];
		alert.message = @"Name must be provided.";
		[alert show];
		[alert release];
		
		return false;
	}
	return true;
}

-(IBAction)actionPressed:(id)sender
{
	RacePrediction *p = [[RacePadDatabase Instance] racePrediction]; 
	if ( p.gameStatus == GS_NOT_STARTED )
	{
		if ( p.cleared )
		{
			NSString *name = user.text;
			if ( [self validName:name] )
			{
				[[RacePadCoordinator Instance]checkUserName:name];
				action.enabled = NO;
				user.enabled = NO;
				changeUser.enabled = NO;
				[self lock];
				[p setUser:name];
			}
		}
		else
			if ( locked )
				[self unlock];
			else
				[[RacePadCoordinator Instance]sendPrediction];
	}
}

-(IBAction) resetPressed:(id)sender
{
	RacePrediction *p = [[RacePadDatabase Instance] racePrediction]; 
	[[RacePadCoordinator Instance]requestPrediction:p.user];
}

- (void) RequestRedrawForType:(int)type
{
	[drivers reloadData];
	
	// has the number of drivers in the result table changed?
	if ( driverCount != [[[RacePadDatabase Instance]resultData] rows] )
	{
		[self updatePrediction];
		driverCount = [[[RacePadDatabase Instance]resultData] rows];
	}
}

-(void) updatePrediction
{
	[result reloadData];
	RacePrediction *p = [[RacePadDatabase Instance] racePrediction]; 

	NSString *text;
	if ( p.gameStatus == GS_NOT_STARTED )
	{
		int time = p.startTime;
		if ( time >= 0 )
		{
			text = @"Game starts at ";
			NSNumber *n = [NSNumber numberWithInt:time/3600];
			text = [text stringByAppendingString:[n stringValue]];
			text = [text stringByAppendingString:@":"];
			n = [NSNumber numberWithInt:(time%3600)/60];
			text = [text stringByAppendingString:[n stringValue]];
			text = [text stringByAppendingString:@":"];
			n = [NSNumber numberWithInt:time%60];
			text = [text stringByAppendingString:[n stringValue]];
		}
		else
			text = @"Game has not started yet";
		newUser.hidden = NO;
		if ( p.cleared )
		{
			// leave the user name as it is
			user.enabled = YES;
			[action setTitle:@"Submit New" forState:UIControlStateNormal];
			[action setTitle:@"Submit New" forState:UIControlStateHighlighted];
			locked = false;
			result.allowsSelection = YES;
			drivers.allowsSelection = YES;
			reset.hidden = YES;
		}
		else
		{
			user.enabled = NO;
			user.text = p.user;
			if ( locked )
			{
				[action setTitle:@"Unlock" forState:UIControlStateNormal];
				[action setTitle:@"Unlock" forState:UIControlStateHighlighted];
				reset.hidden = YES;
				result.allowsSelection = NO;
				drivers.allowsSelection = NO;
			}
			else
			{
				[action setTitle:@"Submit Change" forState:UIControlStateNormal];
				[action setTitle:@"Submit Change" forState:UIControlStateHighlighted];
				reset.hidden = NO;
				result.allowsSelection = YES;
				drivers.allowsSelection = YES;
			}
		}
		drivers.hidden = NO;
		leagueTable.hidden = YES;

	}
	else
	{
		user.text = p.user;
		if ( p.position < 0 )
		{
			if ( p.gameStatus == GS_PLAYING )
				text = @"Game is in progress";
			else
				text = @"Game is complete";
		}
		else
		{
			if ( p.gameStatus == GS_PLAYING )
				text = @"Current status would make you ";
			else
				text = @"Final result makes you ";
			if ( p.position == 1 )
				if ( p.equal )
					text = [text stringByAppendingString:@"joint WINNER"];
				else
					text = [text stringByAppendingString:@"the WINNER"];
				else
				{
					NSNumber *n = [NSNumber numberWithInt:p.position];
					text = [text stringByAppendingString:[n stringValue]];
					if ( p.position % 100 != 11 && p.position % 10 == 1 )
						text = [text stringByAppendingString:@"st"];
					else if ( p.position % 100 != 12 && p.position % 10 == 2 )
						text = [text stringByAppendingString:@"nd"];
					else if ( p.position % 100 != 13 && p.position % 10 == 3 )
						text = [text stringByAppendingString:@"rd"];
					else
						text = [text stringByAppendingString:@"th"];
					
					if ( p.equal )
						text = [text stringByAppendingString:@"="];
				}
			
			text = [text stringByAppendingString:@" with "];
			NSNumber *n = [NSNumber numberWithInt:p.score];
			text = [text stringByAppendingString:[n stringValue]];
			text = [text stringByAppendingString:@" point"];
			if ( p.score != 1 )
				text = [text stringByAppendingString:@"s"];
		}
		newUser.hidden = YES;
		action.hidden = YES;
		reset.hidden = YES;
		drivers.hidden = YES;
		leagueTable.hidden = NO;
		result.allowsSelection = NO;
		drivers.allowsSelection = NO;
	}
	[status setText:text];
}

-(void)registeredUser
{
	if ( showingBadUser )
		[newCompetitor dismissModalViewControllerAnimated:NO];
	showingBadUser = false;
	locked = false;
	[self updatePrediction];
	action.enabled = YES;
	changeUser.enabled = YES;
	
	if ( pinMessage == nil )
	{
		pinMessage = [[UIAlertView alloc] init];
		pinMessage.title = @"User Added";
		pinMessage.cancelButtonIndex = [pinMessage addButtonWithTitle:@"OK"];
	}
	NSString *message = @"Your PIN is ";
	RacePrediction *p = [[RacePadDatabase Instance] racePrediction];
	NSNumber *number = [NSNumber numberWithInt:p.pin];
	message = [message stringByAppendingString:[number stringValue]];
	message = [message stringByAppendingString:@". You will need this to unlock your entry"];
	pinMessage.message = message;
	[pinMessage show];
}

-(void) badUser
{
	if ( newCompetitor == nil )
		newCompetitor = [[NewCompetitor alloc] initWithNibName:@"NewCompetitor" bundle:nil];
	if ( showingBadUser )
		[newCompetitor badUser];
	else
	{
		[newCompetitor getUser:self];
		showingBadUser = true;
	}
}

-(void)cancelledRegister
{
	RacePrediction *p = [[RacePadDatabase Instance] racePrediction]; 
	[p noUser];
	action.enabled = YES;
	user.enabled = YES;
	changeUser.enabled = YES;
	locked = false;
	showingBadUser = false;
	result.allowsSelection = YES;
	drivers.allowsSelection = YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if ( tableView == result )
		return [[[RacePadDatabase Instance] racePrediction] count];
	return [[[RacePadDatabase Instance]resultData] rows];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"RacePadGame";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:MyIdentifier] autorelease];
    }
	
	if ( tableView == result )
	{
		int v = indexPath.row + 1;
		NSNumber *n = [NSNumber numberWithInt:v];
		NSString *s = [n stringValue];
		if ( v == 1 )
			s = [s stringByAppendingString:@"st"];
		else if ( v == 2 )
			s = [s stringByAppendingString:@"nd"];
		else if ( v == 3 )
			s = [s stringByAppendingString:@"rd"];
		else
			s = [s stringByAppendingString:@"th"];
		cell.textLabel.text = s;
		
		RacePrediction *racePrediction = [[RacePadDatabase Instance] racePrediction];
		int *prediction = [racePrediction prediction];
		int p = -1;
		if ( indexPath.row < [[[RacePadDatabase Instance] racePrediction] count] )
			p = prediction[indexPath.row];
		
		if ( p < 0
			|| p >= [[[RacePadDatabase Instance]driverNames] count] )
			cell.detailTextLabel.text = nil;
		else
		{
			DriverName *driver = [[[RacePadDatabase Instance]driverNames] driverByNumber:prediction[indexPath.row]];
			NSString *name = driver.name;
			if ( racePrediction.gameStatus != GS_NOT_STARTED )
			{
				int pts = [racePrediction scores][indexPath.row];
				NSNumber *points = [NSNumber numberWithInt:pts];
				name = [name stringByAppendingString:@" ("];
				name = [name stringByAppendingString:[points stringValue]];
				name = [name stringByAppendingString:@")"];
			}
			cell.detailTextLabel.text = name;
		}
	}
	else
	{
		TableData *resultData = [[RacePadDatabase Instance]resultData];
		cell.textLabel.text = [[resultData cell:indexPath.row Col:1] string];
		cell.detailTextLabel.text = [[resultData cell:indexPath.row Col:2] string];
	}
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if ( tableView == result )
		return @"Prediction";
	
	return @"Drivers";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ( changingSelection )
		return;
	
	changingSelection = true;
	if ( tableView == result )
	{
		int *prediction = [[[RacePadDatabase Instance] racePrediction] prediction];
		int p = -1;
		if ( indexPath.row < [[[RacePadDatabase Instance] racePrediction] count] )
		{
			int driverNumber = prediction[indexPath.row];
			
			// Find the driver with this number in the result view
			int count = [[[RacePadDatabase Instance] resultData] rows];
			for ( int i = 0; i < count; i++ )
			{
				if ( driverNumber == [[[[[RacePadDatabase Instance] resultData] cell:i Col:0] string] intValue] )
				{
					p = i;
					break;
				}
			}
		}
		
		if ( p == -1 )
		{
			NSIndexPath *currentSelection = [drivers indexPathForSelectedRow];
			if ( currentSelection )
				[drivers deselectRowAtIndexPath:currentSelection animated:TRUE];
		}
		else
		{
			NSIndexPath *newSelection = [NSIndexPath indexPathForRow:p inSection:0];
			[drivers selectRowAtIndexPath:newSelection animated:TRUE scrollPosition:UITableViewScrollPositionMiddle];
		}
	}
	else
	{
		if ( !locked )
		{
			NSIndexPath *currentSelection = [result indexPathForSelectedRow];
			if ( currentSelection )
			{
				int *prediction = [[[RacePadDatabase Instance] racePrediction] prediction];
				int count = [[[RacePadDatabase Instance] racePrediction] count];
				int number = 0;
				if ( indexPath.row < [[[RacePadDatabase Instance] resultData] rows] )
					number = [[[[[RacePadDatabase Instance] resultData] cell:indexPath.row Col:0] string] intValue];
				for ( int i = 0; i < count; i++ )
					if ( prediction[i] == number )
						prediction[i] = -1;
				prediction [currentSelection.row] = number;
				[result reloadData];
			}
		}
	}
	changingSelection = false;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[user resignFirstResponder];
	return YES;
}

@end
