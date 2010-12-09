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
	[[RacePadCoordinator Instance] setGameViewController:self];
	[[RacePadCoordinator Instance] AddView:[self view] WithType:RPC_GAME_VIEW_];
	[[RacePadCoordinator Instance] DisableViewRefresh:[self view]];
	changingSelection = false;
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
		
		int *prediction = [[[RacePadDatabase Instance] racePrediction] prediction];
		int p = -1;
		if ( indexPath.row < [[[RacePadDatabase Instance] racePrediction] count] )
			p = prediction[indexPath.row];
			
		if ( p < 0
		  || p >= [[[RacePadDatabase Instance]driverNames] count] )
			cell.detailTextLabel.text = nil;
		else
		{
			DriverName *driver = [[[RacePadDatabase Instance]driverNames] driver:prediction[indexPath.row]];
			cell.detailTextLabel.text = [driver name];
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
			p = prediction[indexPath.row];
			
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
		NSIndexPath *currentSelection = [result indexPathForSelectedRow];
		if ( currentSelection )
		{
			int *prediction = [[[RacePadDatabase Instance] racePrediction] prediction];
			int count = [[[RacePadDatabase Instance] racePrediction] count];
			int index = 0;
			if ( indexPath.row < [[[RacePadDatabase Instance] resultData] rows] )
				index = [[[[[RacePadDatabase Instance] resultData] cell:indexPath.row Col:0] string] intValue];
			for ( int i = 0; i < count; i++ )
				if ( prediction[i] == index )
					prediction[i] = -1;
			prediction [currentSelection.row] = index;
			[result reloadData];
		}
	}
	changingSelection = false;
}

- (void)viewWillAppear:(BOOL)animated;    // Called when the view is about to made visible. Default does nothing
{
	[[RacePadCoordinator Instance] RegisterViewController:self WithTypeMask:RPC_GAME_VIEW_];
	[[RacePadCoordinator Instance] SetViewDisplayed:[self view]];
	[userName setText:[[[RacePadDatabase Instance] racePrediction] user]];
	[self updatePrediction];
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
}

/////////////////////////////////////////////////////////////////////
// Class specific methods

-(IBAction)predictPressed:(id)sender
{
	[[RacePadCoordinator Instance] sendPrediction];
}
			
-(IBAction) userChanged:(id)sender
{
	[[[RacePadDatabase Instance] racePrediction] setUser:userName.text];
	[userName resignFirstResponder];
}
			
- (void) RequestRedrawForType:(int)type
{
	[drivers reloadData];
}

-(void) updatePrediction
{
	[result reloadData];
	RacePrediction *p = [[RacePadDatabase Instance] racePrediction]; 
	[userName setText:p.user];
	NSString *text;
	if ( p.gameStatus == GS_NOT_STARTED )
		text = @"Game has not started yet";
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
	[status setText:text];
}
			
@end
