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
#import "RacePadTitleBarController.h"
#import "RacePadTimeController.h"

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

	[predictionBG removeFromSuperview];
	[result setBackgroundView:predictionBG];
	[result setSeparatorColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.8]];
	
	[background setStyle:BG_STYLE_FULL_SCREEN_GREY_];
	
	[draggedDriver removeFromSuperview];

	changingSelection = false;
	draggingCell = false;
	draggedDriverIndex = -1;
	draggedTargetIndex= nil;
	
	locked = false;

	gameStatus = GS_NOT_STARTED;

	[action setTitleColor: [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:0.7] forState:UIControlStateDisabled];
	[changeUser setTitleColor: [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:0.7] forState:UIControlStateDisabled];
	
	portraitMode = false; // Arbitrary - will be set properly on display or rotation
	
	// Add drop shadows to all of the views
	/*
	[self addDropShadowToView:user WithOffsetX:5 Y:5 Blur:3];
	[self addDropShadowToView:newUser WithOffsetX:5 Y:5 Blur:3];
	[self addDropShadowToView:changeUser WithOffsetX:5 Y:5 Blur:3];
	[self addDropShadowToView:result WithOffsetX:5 Y:5 Blur:3];
	[self addDropShadowToView:drivers1 WithOffsetX:5 Y:5 Blur:3];
	[self addDropShadowToView:drivers2 WithOffsetX:5 Y:5 Blur:3];
	[self addDropShadowToView:action WithOffsetX:5 Y:5 Blur:3];
	[self addDropShadowToView:reset WithOffsetX:5 Y:5 Blur:3];
	[self addDropShadowToView:relock WithOffsetX:5 Y:5 Blur:3];
	[self addDropShadowToView:leagueTable WithOffsetX:5 Y:5 Blur:3];
	*/
	
	// Register our interest in data feeds
	[[RacePadCoordinator Instance] setGameViewController:self];
	[[RacePadCoordinator Instance] AddView:leagueTable WithType:RPC_GAME_VIEW_];

	
	// We get the tap to show/hide the time controller
	[self addTapRecognizerToView:leagueTable];
	[self addTapRecognizerToView:[self view]];
	
	// But, we don't want it on these controls
	[self addTapRecognizerToView:result];
	[self addTapRecognizerToView:drivers1];
	[self addTapRecognizerToView:drivers2];
	[self addTapRecognizerToView:newUser];
	[self addTapRecognizerToView:changeUser];
	[self addTapRecognizerToView:action];
	[self addTapRecognizerToView:reset];
	[self addTapRecognizerToView:relock];
	
	[self addDragRecognizerToView:drivers1 WithTarget:result];
	[self addDragRecognizerToView:drivers2 WithTarget:result];
}

- (void)positionViews
{
	// Position the driver lists to the right of the prediction and under the title
	CGRect resultFrame = [result frame];
	CGRect titleFrame = [status frame];
	
	float xOrigin = resultFrame.origin.x + resultFrame.size.width + 30;
	float yOrigin = titleFrame.origin.y + titleFrame.size.height + 30;
	
	CGRect leagueFrame = [leagueTable frame];
	leagueFrame = CGRectMake(xOrigin, yOrigin, 335, leagueFrame.size.height);
	[leagueTable setFrame:leagueFrame];
	
	CGRect drivers1Frame = [drivers1 frame];
	drivers1Frame = CGRectMake(xOrigin, yOrigin, drivers1Frame.size.width, drivers1Frame.size.height);
	[drivers1 setFrame:drivers1Frame];
	
	CGRect drivers2Frame = [drivers2 frame];
	drivers2Frame = CGRectMake(xOrigin + drivers1Frame.size.width + 30, yOrigin, drivers2Frame.size.width, drivers2Frame.size.height);
	[drivers2 setFrame:drivers2Frame];
	
	if(portraitMode)
	{
		[drivers1 setHidden:false];
		[drivers2 setHidden:true];
	}
	else
	{
		[drivers1 setHidden:false];
		[drivers2 setHidden:false];
	}

}

- (void)hideViews
{
	leagueTable.hidden = YES;
	drivers2.hidden = YES;
}

- (unsigned char) inqGameStatus
{
	if ( [[RacePadCoordinator Instance] connectionType] == RPC_SOCKET_CONNECTION_ )
	{
		RacePrediction *p = [[RacePadDatabase Instance] racePrediction]; 
		return p.gameStatus;
	}
	else
	{
		if ( [[RacePadTitleBarController Instance] inqCurrentLap] > 1 )
			return GS_PLAYING;
	}
	
	return GS_NOT_STARTED;
}

- (void)showViews
{
	if ( [self inqGameStatus] != GS_NOT_STARTED )
		leagueTable.hidden = NO;
}

- (void)viewWillAppear:(BOOL)animated;    // Called when the view is about to made visible. Default does nothing
{
	// Get the UI orientation
	portraitMode = [[RacePadCoordinator Instance] deviceOrientation] == UI_ORIENTATION_PORTRAIT_;

	// Register this UI as current
	[[RacePadCoordinator Instance] RegisterViewController:self WithTypeMask:RPC_GAME_VIEW_];
	[[RacePadCoordinator Instance] SetViewDisplayed:leagueTable];
	
	// Update UI
	[self updatePrediction];
	[self positionViews];

	// We disable the screen locking - because that seems to close the socket
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)viewWillDisappear:(BOOL)animated; // Called when the view is dismissed, covered or otherwise hidden. Default does nothing
{
	[[RacePadCoordinator Instance] SetViewHidden:leagueTable];
	[[RacePadCoordinator Instance] ReleaseViewController:self];

	// re-enable the screen locking
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[self hideViews];
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	// Get the UI orientation
	portraitMode = [[RacePadCoordinator Instance] deviceOrientation] == UI_ORIENTATION_PORTRAIT_;
	
	// Update UI
	[self positionViews];
	[self showViews];
	
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
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

- (void) OnTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
	if ( gestureView == [self view]
	  || gestureView == leagueTable )
	{
		RacePadTimeController * time_controller = [RacePadTimeController Instance];
		
		if(![time_controller displayed])
		{
			[time_controller displayInViewController:self Animated:true];
		}
		else
		{
			[time_controller hide];
		}
	}
}

/////////////////////////////////////////////////////////////////////
// Class specific methods

-(void)lock
{
	locked = true;
	// Assume rest gets sorted when the new prediction turns up
}

-(void)unlock
{
	RacePrediction *p = [[RacePadDatabase Instance] racePrediction]; 
	if ( [self inqGameStatus] == GS_NOT_STARTED )
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
	[action setTitle:@"Send Prediction" forState:UIControlStateNormal ];
	[action setTitle:@"Send Prediction" forState:UIControlStateHighlighted];
	reset.hidden = NO;
	relock.hidden = NO;
	result.allowsSelection = YES;
	drivers1.allowsSelection = YES;
	drivers2.allowsSelection = YES;
	newUser.hidden = YES;
}

-(void) pinFailed
{
}

-(IBAction)newUserPressed:(id)sender
{
	action.enabled = YES;
	[action setTitle:@"Send Prediction" forState:UIControlStateNormal];
	[action setTitle:@"Send Prediction" forState:UIControlStateHighlighted];
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
	if ( [self inqGameStatus] == GS_NOT_STARTED )
	{
		if ( p.cleared )
		{
			NSString *name = user.text;
			if ( [self validName:name] )
			{
				action.enabled = NO;
				user.enabled = NO;
				changeUser.enabled = NO;
				[self lock];
				[p setUser:name];
				[[RacePadCoordinator Instance]checkUserName:name];
			}
		}
		else
			if ( locked )
				[self unlock];
			else
			{
				[[RacePadCoordinator Instance]sendPrediction];
				reset.hidden = NO;
				relock.hidden = NO;
			}
	}
}

-(IBAction) resetPressed:(id)sender
{
	RacePrediction *p = [[RacePadDatabase Instance] racePrediction]; 
	[[RacePadCoordinator Instance]requestPrediction:p.user];
}

-(IBAction) relockPressed:(id)sender
{
	locked = true;
	
	action.enabled = YES;
	[action setTitle:@"Change Prediction" forState:UIControlStateNormal ];
	[action setTitle:@"Change Prediction" forState:UIControlStateHighlighted];
	
	reset.hidden = YES;
	relock.hidden = YES;
	
	result.allowsSelection = NO;
	[result deselectRowAtIndexPath:[result indexPathForSelectedRow] animated:TRUE];
	
	drivers1.allowsSelection = NO;
	[drivers1 deselectRowAtIndexPath:[drivers1 indexPathForSelectedRow] animated:TRUE];
	
	drivers2.allowsSelection = NO;
	[drivers2 deselectRowAtIndexPath:[drivers2 indexPathForSelectedRow] animated:TRUE];
	
	newUser.hidden = NO;
	RacePrediction *p = [[RacePadDatabase Instance] racePrediction]; 
	[[RacePadCoordinator Instance]requestPrediction:p.user];
}

- (void) RequestRedrawForType:(int)type
{
	[drivers1 reloadData];
	[drivers2 reloadData];
		
	// has the number of drivers in the result table changed?
	// or the gameStatus changed
	if ( driverCount != [[[RacePadDatabase Instance]driverNames] count] || gameStatus != [self inqGameStatus] )
	{
		[self updatePrediction];
		driverCount = [[[RacePadDatabase Instance]driverNames] count];
		gameStatus = [self inqGameStatus];
	}
}

-(void) updatePrediction
{
	[result reloadData];
	RacePrediction *p = [[RacePadDatabase Instance] racePrediction]; 

	NSString *text;
	if ( [self inqGameStatus] == GS_NOT_STARTED )
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
		{
			text = @"Game has not started yet";
		}
		
		if ( p.cleared )
		{
			// leave the user name as it is
			user.enabled = YES;
			[action setTitle:@"Send Prediction" forState:UIControlStateNormal];
			[action setTitle:@"Send Prediction" forState:UIControlStateHighlighted];
			locked = false;
			result.allowsSelection = YES;
			drivers1.allowsSelection = YES;
			drivers2.allowsSelection = YES;
			reset.hidden = YES;
			relock.hidden = YES;
			newUser.hidden = YES;
		}
		else
		{
			user.enabled = NO;
			user.text = p.user;
			if ( locked )
			{
				[action setTitle:@"Change Prediction" forState:UIControlStateNormal];
				[action setTitle:@"Change Prediction" forState:UIControlStateHighlighted];
				
				reset.hidden = YES;
				relock.hidden = YES;
				
				result.allowsSelection = NO;
				[result deselectRowAtIndexPath:[result indexPathForSelectedRow] animated:TRUE];
				
				drivers1.allowsSelection = NO;
				[drivers1 deselectRowAtIndexPath:[drivers1 indexPathForSelectedRow] animated:TRUE];
				
				drivers2.allowsSelection = NO;
				[drivers2 deselectRowAtIndexPath:[drivers2 indexPathForSelectedRow] animated:TRUE];
				
				newUser.hidden = NO;
			}
			else
			{
				[action setTitle:@"Send Prediction" forState:UIControlStateNormal];
				[action setTitle:@"Send Prediction" forState:UIControlStateHighlighted];
				
				bool empty = true;
				int *pre = [p prediction];
				for ( int i = 0; i < p.count; i++ )
				{
					if ( pre[i] != -1 )
						empty = false;
				}
				
				reset.hidden = empty;
				relock.hidden = empty;
				result.allowsSelection = YES;
				drivers1.allowsSelection = YES;
				drivers2.allowsSelection = YES;
				newUser.hidden = YES;
			}
		}
		drivers1.hidden = NO;
		drivers2.hidden = portraitMode; // Hidden if in portrait mode, displayed in landscape
		leagueTable.hidden = YES;

	}
	else
	{
		user.text = p.user;
		if ( p.position < 0 )
		{
			if ( [self inqGameStatus] == GS_PLAYING )
				text = @"Game is in progress";
			else
				text = @"Game is complete";
		}
		else
		{
			if ( [self inqGameStatus] == GS_PLAYING )
				text = @"Current status would make you ";
			else
				text = @"Final result makes you ";
			
			if ( p.position == 1 )
				if ( p.equal )
				{
					text = [text stringByAppendingString:@"joint WINNER"];
				}
				else
				{
					text = [text stringByAppendingString:@"the WINNER"];
				}
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
		relock.hidden = YES;
		drivers1.hidden = YES;
		drivers2.hidden = YES;
		leagueTable.hidden = NO;
		
		result.allowsSelection = NO;
		[result deselectRowAtIndexPath:[result indexPathForSelectedRow] animated:TRUE];
		
		drivers1.allowsSelection = NO;
		[drivers1 deselectRowAtIndexPath:[drivers1 indexPathForSelectedRow] animated:TRUE];
		
		drivers2.allowsSelection = NO;
		[drivers2 deselectRowAtIndexPath:[drivers2 indexPathForSelectedRow] animated:TRUE];
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
	message = [message stringByAppendingString:@". You will need this to change your entry"];
	pinMessage.message = message;
	[pinMessage show];
}

-(void) badUser
{
	if ( newCompetitor == nil )
	{
		newCompetitor = [[NewCompetitor alloc] initWithNibName:@"NewCompetitor" bundle:nil];
	}
	if ( showingBadUser )
	{
		[newCompetitor badUser];
	}
	else
	{
		[newCompetitor getUser:self AlreadyBad:true];
		showingBadUser = true;
	}
}

-(void) makeNewUser
{
	[[[RacePadDatabase Instance] racePrediction] clear];
	
	if ( newCompetitor == nil )
		newCompetitor = [[NewCompetitor alloc] initWithNibName:@"NewCompetitor" bundle:nil];
	
	[newCompetitor getUser:self AlreadyBad:false];
	showingBadUser = true;
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
	drivers1.allowsSelection = YES;
	drivers2.allowsSelection = YES;
}

- (void)addToPrediction:(int)driverIndex AtIndexPath:(NSIndexPath *)indexPath
{
	int *prediction = [[[RacePadDatabase Instance] racePrediction] prediction];
	int count = [[[RacePadDatabase Instance] racePrediction] count];
	
	// Get the selected driver number
	int number = -1;
	if ( driverIndex < [[[RacePadDatabase Instance] driverNames] count] )
		number = [[[[RacePadDatabase Instance] driverNames] driver:driverIndex] number];
	
	// If he's already picked for a position, remove him from there
	for ( int i = 0; i < count; i++ )
	{
		if ( prediction[i] == number )
			prediction[i] = -1;
	}
	
	// And add him to the prediction
	prediction [indexPath.row] = number;
	[result reloadData];
}

////////////////////////////////////////////////////////////////////////////
// Table view delegate routines

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if ( tableView == result )
		return [[[RacePadDatabase Instance] racePrediction] count];
	else
	{
		int driverListSplit = portraitMode ? [[[RacePadDatabase Instance]driverNames] count] : [[[RacePadDatabase Instance]driverNames] count] / 2;
		if ( tableView == drivers1 )
			return portraitMode ? [[[RacePadDatabase Instance]driverNames] count] : driverListSplit;
		else if ( tableView == drivers2 )
			return portraitMode ? 0 : [[[RacePadDatabase Instance]driverNames] count] - driverListSplit;
	}
	
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"RacePadGame";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil)
	{
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
		
		if ( p <= 0 )
		{
			cell.detailTextLabel.text = nil;
		}
		else
		{
			DriverName *driver = [[[RacePadDatabase Instance]driverNames] driverByNumber:prediction[indexPath.row]];
			NSString *name = driver.name;
			if ( [self inqGameStatus] != GS_NOT_STARTED )
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
	else // tableView is one of the driver lists
	{
		int driverListSplit = portraitMode ? [[[RacePadDatabase Instance]driverNames] count] : [[[RacePadDatabase Instance]driverNames] count] / 2;
		int driverIndexAtRow = (tableView == drivers1) ? indexPath.row : indexPath.row + driverListSplit;
		
		if((tableView == drivers1 && driverIndexAtRow >= driverListSplit) || driverIndexAtRow > [[[RacePadDatabase Instance]driverNames] count])
		{
			cell.detailTextLabel.text = nil;
			cell.textLabel.text = nil;
		}
		else
		{
			DriverName *driver = [[[RacePadDatabase Instance]driverNames] driver:driverIndexAtRow];
			cell.textLabel.text = driver.name;
			cell.detailTextLabel.text = driver.team;
		}
	}
	
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if ( tableView == result )
		return @"Prediction";
	else // One of the driver lists
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
			p = [[[RacePadDatabase Instance] driverNames] driverIndexByNumber:driverNumber];
		}
		
		if ( p == -1 )
		{
			[drivers1 deselectRowAtIndexPath:[drivers1 indexPathForSelectedRow] animated:TRUE];
			[drivers2 deselectRowAtIndexPath:[drivers2 indexPathForSelectedRow] animated:TRUE];
		}
		else
		{
			int driverListSplit = portraitMode ? [[[RacePadDatabase Instance]driverNames] count] : [[[RacePadDatabase Instance]driverNames] count] / 2;

			if(p < driverListSplit)
			{
				NSIndexPath *newSelection = [NSIndexPath indexPathForRow:p inSection:0];
				[drivers1 selectRowAtIndexPath:newSelection animated:TRUE scrollPosition:UITableViewScrollPositionMiddle];
			}
			else
			{
				NSIndexPath *newSelection = [NSIndexPath indexPathForRow:(p - driverListSplit) inSection:0];
				[drivers2 selectRowAtIndexPath:newSelection animated:TRUE scrollPosition:UITableViewScrollPositionMiddle];
			}
		}
	}
	else // tableView is one of the driver selection list tables
	{
		// Get the picked driver - may be from either driver list
		int driverListSplit = portraitMode ? [[[RacePadDatabase Instance]driverNames] count] : [[[RacePadDatabase Instance]driverNames] count] / 2;
		int driverListOffset = (tableView == drivers1) ? 0 : driverListSplit;
		int selectedDriverIndex = indexPath.row + driverListOffset;
		
		// Don't act on any rows picked below the last driver in the first list
		bool invalid = (tableView == drivers1 && selectedDriverIndex > driverListSplit);

		// Pick driver if we're allowed
		if ( !locked && !invalid )
		{
			NSIndexPath *currentSelection = [result indexPathForSelectedRow];
			if ( currentSelection )
			{
				[self addToPrediction:selectedDriverIndex AtIndexPath:currentSelection];
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


////////////////////////////////////////////////////////////////////////////
// Gesture recognizers

- (void) OnDragGestureInView:(UIView *)gestureView ByX:(float)x Y:(float)y SpeedX:(float)speedx SpeedY:(float)speedy State:(int)state Recognizer:(UIGestureRecognizer *)recognizer
{
	// Only relevant for driver list views
	if(gestureView != drivers1 && gestureView != drivers2)
		return;
	
	// Behaviour depends on state
	
	switch(state)
	{
		case UIGestureRecognizerStateBegan:
		{	
			CGPoint point = [recognizer locationInView:gestureView];
			NSIndexPath * selectedRow = [(UITableView *)gestureView indexPathForRowAtPoint:point];
			if(selectedRow)
			{
				// Get the picked driver - may be from either driver list
				int driverListSplit = portraitMode ? [[[RacePadDatabase Instance]driverNames] count] : [[[RacePadDatabase Instance]driverNames] count] / 2;
				int driverListOffset = (gestureView == drivers1) ? 0 : driverListSplit;
				int selectedDriverIndex = selectedRow.row + driverListOffset;
				
				// Don't act on any rows picked below the last driver in the first list
				bool invalid = (selectedDriverIndex < 0 || (gestureView == drivers1 && selectedDriverIndex > driverListSplit) || selectedDriverIndex >= [[[RacePadDatabase Instance]driverNames] count]);
				
				// Pick driver if we're allowed
				if ( !locked && !invalid )
				{
					[self.view addSubview:draggedDriver];
					[self addDropShadowToView:draggedDriver WithOffsetX:5 Y:5 Blur:3];

					CGRect rowRect = [(UITableView *)gestureView rectForRowAtIndexPath:selectedRow];
					CGRect tableFrame = [gestureView frame];
					CGRect dragFrame = CGRectMake(tableFrame.origin.x + rowRect.origin.x, tableFrame.origin.y + rowRect.origin.y, rowRect.size.width, rowRect.size.height);
					[draggedDriver setFrame:dragFrame];
					draggingCell = true;
					draggedDriverIndex = selectedDriverIndex;
				}
			}

			[result deselectRowAtIndexPath:[result indexPathForSelectedRow] animated:false];

			break;
		}
			
		case UIGestureRecognizerStateChanged:
		{
			// Only do anything if we started properly
			if(!draggingCell)
				break;
			
			// Move the dragged cell
			CGRect frame = [draggedDriver frame];
			CGRect newFrame = CGRectOffset(frame, x, y);
			[draggedDriver setFrame:newFrame];
			
			// Check whether we are over a cell in the result table
			bool resultCellSelected = false;
			CGPoint resultPoint = [recognizer locationInView:result];
			if([result pointInside:resultPoint withEvent:nil])
			{
				NSIndexPath * resultRow = [(UITableView *)gestureView indexPathForRowAtPoint:resultPoint];
				if(resultRow)
				{
					UITableViewCell * cell = [result cellForRowAtIndexPath:resultRow];
					if(cell)
					{
						if(![cell isSelected])
						{
							[result deselectRowAtIndexPath:[result indexPathForSelectedRow] animated:false];
							[result selectRowAtIndexPath:resultRow animated:false scrollPosition:UITableViewScrollPositionMiddle];
							
							if(draggedTargetIndex)
								[draggedTargetIndex release];
							
							draggedTargetIndex = [resultRow retain];
							//[result reloadData];
						}
						
						resultCellSelected = true;
						
					}
				}
			}
			
			if(!resultCellSelected)
			{
				[result deselectRowAtIndexPath:[result indexPathForSelectedRow] animated:false];
				
				if(draggedTargetIndex)
					[draggedTargetIndex release];
				
				draggedTargetIndex = nil;
			}
			
			break;
		}
			
		case UIGestureRecognizerStateEnded:
		{
			if(draggingCell)
			{
				[draggedDriver removeFromSuperview];
				
				// Check whether we are over a cell in the result table
				if(draggedTargetIndex)
				{
					[self addToPrediction:draggedDriverIndex AtIndexPath:draggedTargetIndex];
				}
				
				[result deselectRowAtIndexPath:[result indexPathForSelectedRow] animated:false];
				
			}
			
			if(draggedTargetIndex)
				[draggedTargetIndex release];
			
			draggedTargetIndex = nil;
			
			draggingCell = false;
			break;
		}
			
		default:
			break;
	}
}


@end
