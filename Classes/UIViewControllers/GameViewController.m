//
//  GameViewController.m
//  RacePad
//
//  Created by Gareth Griffith on 10/11/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "GameViewController.h"

#import "GameHelpController.h"

#import "RacePadCoordinator.h"
#import	"RacePadDatabase.h"
#import "UserPin.h"
#import "RacePadTitleBarController.h"
#import "RacePadTimeController.h"

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

	[leagueTable SetTableDataClass:[[RacePadDatabase Instance] competitorData]];
	
	[leagueTable SetRowHeight:30];
	[leagueTable SetHeading:true];
	[leagueTable SetBackgroundAlpha:0.8];

	[predictionBG removeFromSuperview];
	[result setBackgroundView:predictionBG];
	[result setSeparatorColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.8]];
	
	[background setStyle:BG_STYLE_FULL_SCREEN_GREY_];
	
	[draggedDriverCell removeFromSuperview];

	changingSelection = false;
	draggingCell = false;
	draggedDriverIndex = -1;
	draggedTargetIndex= nil;
	
	needPin = false;
	gettingPin = false;

	gameStatus = GS_NOT_STARTED;
	predictionChanged = false;
	predictionComplete = false;
	predictionEmpty = true;
	
	inDrivingGame = false;
	
	[action setTitleColor: [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:0.7] forState:UIControlStateDisabled];
	[changeUser setTitleColor: [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:0.7] forState:UIControlStateDisabled];
	
	// Add drop shadows to all of the views
	/*
	[self addDropShadowToView:result WithOffsetX:5 Y:5 Blur:3];
	[self addDropShadowToView:drivers1 WithOffsetX:5 Y:5 Blur:3];
	[self addDropShadowToView:drivers2 WithOffsetX:5 Y:5 Blur:3];
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
	[self addTapRecognizerToView:users];
	[self addTapRecognizerToView:drivers1];
	[self addTapRecognizerToView:drivers2];
	[self addTapRecognizerToView:newUser];
	[self addTapRecognizerToView:signOut];
	[self addTapRecognizerToView:changeUser];
	[self addTapRecognizerToView:action];
	[self addTapRecognizerToView:reset];
	[self addTapRecognizerToView:raceMSC];
	[self addTapRecognizerToView:raceROS];
	
	[self addDragRecognizerToView:result WithTarget:result];
	[self addDragRecognizerToView:drivers1 WithTarget:result];
	[self addDragRecognizerToView:drivers2 WithTarget:result];
}

- (void)viewWillAppear:(BOOL)animated;    // Called when the view is about to made visible. Default does nothing
{
	// Grab the title bar
	[[RacePadTitleBarController Instance] displayInViewController:self];
	
	// Register this UI as current
	[[RacePadCoordinator Instance] RegisterViewController:self WithTypeMask:RPC_GAME_VIEW_];
	
	[leagueTable SetBaseColour:[leagueTable light_grey_]];

	 // Update UI
	[self updatePrediction];
	[self positionViews];
	[self showViews];

	[[RacePadCoordinator Instance] SetViewDisplayed:leagueTable];

	// We disable the screen locking - because that seems to close the socket
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	inDrivingGame = false;
}

- (void)viewWillDisappear:(BOOL)animated; // Called when the view is dismissed, covered or otherwise hidden. Default does nothing
{
	[[RacePadCoordinator Instance] SetViewHidden:leagueTable];
	[[RacePadCoordinator Instance] ReleaseViewController:self];

	// re-enable the screen locking
	if (!inDrivingGame)
		[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[self hideViews];
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
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

/////////////////////////////////////////////////////////////////////
// Class specific methods

- (HelpViewController *) helpController
{
	if(!helpController)
		helpController = [[GameHelpController alloc] initWithNibName:@"GameHelp" bundle:nil];
	
	return (HelpViewController *)helpController;
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

- (void)positionViews
{
	// Positions all views that aren't handled automatically, regardless
	// of whether they will be displayed or not
	
	// Get the UI orientation
	bool portraitMode = [[RacePadCoordinator Instance] deviceOrientation] == UI_ORIENTATION_PORTRAIT_;
	
	// Position the driver lists to the right of the prediction and under the title
	CGRect resultFrame = [result frame];
	CGRect titleFrame = [status frame];
	CGRect userFrame = [user frame];
	
	float xOrigin, yOrigin;
	float driverTableHeight;
	
	if(portraitMode)
	{
		xOrigin = resultFrame.origin.x + resultFrame.size.width + 50;
		yOrigin = titleFrame.origin.y;
		driverTableHeight = 24 * 35 + 30;
	}
	else
	{
		xOrigin = resultFrame.origin.x + resultFrame.size.width + 30;
		yOrigin = userFrame.origin.y;
		driverTableHeight = 13 * 35 + 30;
	}
	
	float resultTableHeight = 8 * 44 + 30;
	
	CGRect newResultFrame = CGRectMake(resultFrame.origin.x, resultFrame.origin.y, resultFrame.size.width, resultTableHeight);
	[result setFrame:newResultFrame];
	
	CGRect leagueFrame = [leagueTable frame];
	leagueFrame = CGRectMake(xOrigin, userFrame.origin.y, 335, leagueFrame.size.height);
	[leagueTable setFrame:leagueFrame];
	
	CGRect drivers1Frame = [drivers1 frame];
	drivers1Frame = CGRectMake(xOrigin, yOrigin, drivers1Frame.size.width, driverTableHeight);
	[drivers1 setFrame:drivers1Frame];
	
	CGRect drivers2Frame = [drivers2 frame];
	drivers2Frame = CGRectMake(xOrigin + drivers1Frame.size.width + 30, yOrigin, drivers2Frame.size.width, driverTableHeight);
	[drivers2 setFrame:drivers2Frame];
	
	if ( [self inqGameStatus] == GS_NOT_STARTED )
	{
		if(portraitMode)
		{			
			[drivers1 reloadData];
		}
		else
		{
			[drivers1 reloadData];
			[drivers2 reloadData];
		}
	}
	else
	{
		[drivers1 setHidden:true];
		[drivers2 setHidden:true];
	}
	
}

- (void)hideViews
{
	// Called when about to change orientation - just hide the views that don't rotate nicely
	// They may be hidden already, but that doesn't matter
	
	leagueTable.hidden = YES;
	drivers2.hidden = YES;
}

- (void)showViews
{
	// Get the UI orientation
	bool portraitMode = [[RacePadCoordinator Instance] deviceOrientation] == UI_ORIENTATION_PORTRAIT_;
	
	// And the game status
	bool gameStarted = ([self inqGameStatus] != GS_NOT_STARTED);
	bool validUser = ([[[RacePadDatabase Instance] racePrediction] validUser]);
	
	//[background clearFrames];

	if(gameStarted)
	{
		leagueTable.hidden =  NO;
		//[background addFrame:[leagueTable frame]];
	}
	else
	{
		leagueTable.hidden = YES;
	}

	if (validUser)
	{
		// We have a valid user, but he/she may not yet have entered pin
		
		user.hidden = NO;
		result.hidden = NO;

		users.hidden = YES;
		newUser.hidden = YES;
		signInLabel.hidden = YES;
		orLabel.hidden = YES;
		
		signIn.hidden = YES;
		raceMSC.hidden = YES;
		raceROS.hidden = YES;
		
		signOut.hidden = NO;
		changeUser.hidden = NO;
		
		action.hidden = (needPin || !(predictionComplete && !gameStarted));
		reset.hidden = (needPin || !(predictionChanged && !gameStarted));
		
		drivers1.hidden = gameStarted;
		drivers2.hidden = (gameStarted || portraitMode); // Hidden in portrait mode, shown in landscape
	}
	else
	{
		// We do not have a logged in user
		
		user.hidden = YES;
		
		result.hidden = YES;
		signOut.hidden = YES;
		changeUser.hidden = YES;
		action.hidden = YES;
		reset.hidden = YES;
		
		drivers1.hidden = YES;
		drivers2.hidden = YES;
		
		// If the game has not started, we can add new users - otherwise we can't
		signInLabel.hidden = gameStarted;
		users.hidden = gameStarted;
		orLabel.hidden = gameStarted;
		newUser.hidden = gameStarted;
		
		signIn.hidden = !gameStarted;
		raceMSC.hidden = NO;
		raceROS.hidden = NO;
	}
}

-(void)lock
{
	needPin = [self inqGameStatus] == GS_NOT_STARTED;
	// Assume rest gets sorted when the new prediction turns up
}

-(void)unlock
{
	RacePrediction *p = [[RacePadDatabase Instance] racePrediction]; 
	if ( [self inqGameStatus] == GS_NOT_STARTED
	  && !gettingPin )
	{
		if ( userPin == nil )
			userPin = [[UserPin alloc] initWithNibName:@"UserPin" bundle:nil];
		
		gettingPin = true;
		[userPin getPin:p.pin Controller:self];
	}
}

-(void) pinCorrect
{
	needPin = false;
	gettingPin = false;
	action.enabled = YES;
	reset.hidden = NO;
	result.allowsSelection = YES;
	drivers1.allowsSelection = YES;
	drivers2.allowsSelection = YES;
	[self showViews];
}

-(void) pinFailed
{
	// Explicitly log out for now 
	// Once we have two stagelog in, this will probably revert to old user
	
	gettingPin = false;
	RacePrediction *p = [[RacePadDatabase Instance] racePrediction];
	[p noUser];
	[self updatePrediction];
}

-(IBAction)changeUserPressed:(id)sender
{
	if ( [self inqGameStatus] == GS_NOT_STARTED )
	{
		[self signOutPressed:sender];
	}
	else
	{
		if ( [[[RacePadDatabase Instance]competitorData] rows] )
		{
			if ( changeCompetitor == nil )
				changeCompetitor = [[ChangeCompetitor	alloc] initWithNibName:@"ChangeCompetitor" bundle:nil];
			[changeCompetitor getUser:self];
			needPin = true;
		}
	}
}

-(IBAction)newUserPressed:(id)sender
{
	[self makeNewUser];
}

-(IBAction)raceMSCPressed:(id)sender
{
	if ( drivingGame == nil )
		drivingGame = [[DrivingViewController alloc] initWithNibName:@"DrivingView" bundle:nil];
	drivingGame.car = RPD_BLUE_CAR_;
	inDrivingGame = true;
	[self presentModalViewController:drivingGame animated:YES];
}

-(IBAction)raceROSPressed:(id)sender
{
	if ( drivingGame == nil )
		drivingGame = [[DrivingViewController alloc] initWithNibName:@"DrivingView" bundle:nil];
	drivingGame.car = RPD_RED_CAR_;
	inDrivingGame = true;
	[self presentModalViewController:drivingGame animated:YES];
}

-(IBAction)signOutPressed:(id)sender
{
	RacePrediction *p = [[RacePadDatabase Instance] racePrediction];
	[p noUser];
	[self updatePrediction];
}

-(bool) validName: (NSString *)name
{
	int count = [name length];
	bool all_spaces = true;
	for ( int i = 0; i < count; i++ )
	{
		if ( [name characterAtIndex:i] != ' ' )
		{
			all_spaces = false;
			break;
		}
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
	if ( [self inqGameStatus] == GS_NOT_STARTED )
	{
		[[RacePadCoordinator Instance]sendPrediction];
		predictionChanged = false;
		[self showViews];
	}
}

-(IBAction) resetPressed:(id)sender
{
	RacePrediction *p = [[RacePadDatabase Instance] racePrediction]; 
	[[RacePadCoordinator Instance]requestPrediction:p.user];
	predictionChanged = false;
	[self showViews];
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
	[users reloadData];
}

-(void) updatePrediction
{
	[result reloadData];
	[users reloadData];
	
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
		
		[self checkPrediction];
		
		result.allowsSelection = YES;
		drivers1.allowsSelection = YES;
		drivers2.allowsSelection = YES;
	}
	else
	{
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
			{
				if ( p.equal )
					text = [text stringByAppendingString:@"joint WINNER"];
				else
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
		
		result.allowsSelection = NO;
		[result deselectRowAtIndexPath:[result indexPathForSelectedRow] animated:TRUE];
		
		drivers1.allowsSelection = NO;
		[drivers1 deselectRowAtIndexPath:[drivers1 indexPathForSelectedRow] animated:TRUE];
		
		drivers2.allowsSelection = NO;
		[drivers2 deselectRowAtIndexPath:[drivers2 indexPathForSelectedRow] animated:TRUE];
	}
	
	if([p user])
	{
		NSString * userText = @"User : ";
		userText = [userText stringByAppendingString:[p user]];
		user.text = userText;
	}
	else
	{
		user.text = @"";
	}

	[status setText:text];
	
	[self showViews];
	
	if ( needPin && [p validUser] && p.gotPin )
		[self unlock];
}

-(void) checkPrediction
{
	RacePrediction *p = [[RacePadDatabase Instance] racePrediction]; 
	
	predictionEmpty = true;
	predictionComplete = true;
	int *pre = [p prediction];
	for ( int i = 0; i < p.count; i++ )
	{
		if ( pre[i] == -1 )
			predictionComplete = false;
		else
			predictionEmpty = false;
	}
}

-(void)registeredUser
{
	if ( showingBadUser )
		[newCompetitor dismissModalViewControllerAnimated:NO];
	
	showingBadUser = false;
	needPin = false;
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
	message = [message stringByAppendingString:@". You will need this to sign in again"];
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
	needPin = false;
}

-(void)cancelledRegister
{
	RacePrediction *p = [[RacePadDatabase Instance] racePrediction]; 
	[p noUser];
	action.enabled = YES;
	changeUser.enabled = YES;
	showingBadUser = false;
	result.allowsSelection = YES;
	drivers1.allowsSelection = YES;
	drivers2.allowsSelection = YES;
}

- (void)addToPrediction:(int)driverIndex AtIndexPath:(NSIndexPath *)indexPath Reorder:(bool)reorder
{
	// Can't change prediction once the game has started
	if ( [self inqGameStatus] != GS_NOT_STARTED )
		return;

	//Otherwise do it
	int *prediction = [[[RacePadDatabase Instance] racePrediction] prediction];
	int count = [[[RacePadDatabase Instance] racePrediction] count];
	
	int newPosition = indexPath.row;
	
	// Get the selected driver number
	int number = -1;
	if ( driverIndex < [[[RacePadDatabase Instance] driverNames] count] )
		number = [[[[RacePadDatabase Instance] driverNames] driver:driverIndex] number];
	
	// If he's already picked for a position, remove him from there, and record the old position
	int oldPosition = -1;
	for ( int i = 0; i < count; i++ )
	{
		if ( prediction[i] == number )
		{
			oldPosition = i;
			prediction[i] = -1;
		}
	}
	
	// If we're reordering, move all drivers that must be moved
	if(reorder && oldPosition >= 0)
	{
		if(oldPosition < newPosition)
		{
			int p = newPosition;
			while(prediction[p] >= 0 && p > 0) // Will definitely stop at oldPosition if not before
				p--;
			
			if(p < newPosition)
			{
				for ( int i = p; i < newPosition; i++ )
				{
					prediction[i] = prediction[i+1];
				}
			}
		}
		else if(oldPosition > newPosition)
		{
			int p = newPosition;
			while(prediction[p] >= 0 && p < count - 1) // Will definitely stop at oldPosition if not before
				p++;
			
			if(p > newPosition)
			{
				for ( int i = p; i > newPosition; i-- )
				{
					prediction[i] = prediction[i-1];
				}
			}
		}
	}
	
	// And add him to the prediction
	prediction [newPosition] = number;
	[result reloadData];
	predictionChanged = true;
	
	// Check status of prediction and display ui accordingly
	[self checkPrediction];
	[self showViews];
}

////////////////////////////////////////////////////////////////////////////
// Table view delegate routines

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// Get the UI orientation
	bool portraitMode = [[RacePadCoordinator Instance] deviceOrientation] == UI_ORIENTATION_PORTRAIT_;
	
	if ( tableView == result )
		return [[[RacePadDatabase Instance] racePrediction] count];
	else if ( tableView == users )
		return [[[RacePadDatabase Instance]competitorData] rows];
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
 	// Get the UI orientation
	bool portraitMode = [[RacePadCoordinator Instance] deviceOrientation] == UI_ORIENTATION_PORTRAIT_;

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
	else if ( tableView == users )
	{
		cell.textLabel.text = [[[[RacePadDatabase Instance]competitorData] cell:indexPath.row Col:1] string];
		cell.detailTextLabel.text = nil;
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
	else if ( tableView == users )
		return @"Users";
	else // One of the driver lists
		return @"Drivers";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Get the UI orientation
	bool portraitMode = [[RacePadCoordinator Instance] deviceOrientation] == UI_ORIENTATION_PORTRAIT_;
	
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
				[drivers2 deselectRowAtIndexPath:[drivers2 indexPathForSelectedRow] animated:false];
			}
			else
			{
				NSIndexPath *newSelection = [NSIndexPath indexPathForRow:(p - driverListSplit) inSection:0];
				[drivers2 selectRowAtIndexPath:newSelection animated:TRUE scrollPosition:UITableViewScrollPositionMiddle];
				[drivers1 deselectRowAtIndexPath:[drivers1 indexPathForSelectedRow] animated:false];
			}
		}
	}
	else if ( tableView == users )
	{
		NSString *currentUser = [[[[RacePadDatabase Instance]competitorData] cell:indexPath.row Col:1] string];
		RacePrediction *p = [[RacePadDatabase Instance] racePrediction]; 
		[p setUser:currentUser];
		[self lock];
		[[RacePadCoordinator Instance] requestPrediction:currentUser];
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
		RacePrediction *p = [[RacePadDatabase Instance] racePrediction]; 
		if ( [p validUser] && !needPin && !invalid )
		{
			NSIndexPath *currentSelection = [result indexPathForSelectedRow];
			if ( currentSelection )
			{
				[self addToPrediction:selectedDriverIndex AtIndexPath:currentSelection Reorder:false];
			}
		}
		
		[drivers1 deselectRowAtIndexPath:[drivers1 indexPathForSelectedRow] animated:TRUE];
		[drivers2 deselectRowAtIndexPath:[drivers2 indexPathForSelectedRow] animated:TRUE];
	}
	
	changingSelection = false;
	
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	return YES;
}


////////////////////////////////////////////////////////////////////////////
// Gesture recognizers

- (void) OnDragGestureInView:(UIView *)gestureView ByX:(float)x Y:(float)y SpeedX:(float)speedx SpeedY:(float)speedy State:(int)state Recognizer:(UIDragDropGestureRecognizer *)recognizer
{
	// Get the UI orientation
	bool portraitMode = [[RacePadCoordinator Instance] deviceOrientation] == UI_ORIENTATION_PORTRAIT_;

	// Behaviour depends on state	
	switch(state)
	{
		case UIGestureRecognizerStateBegan:
		{	
			CGPoint point = [recognizer downPoint];
			NSIndexPath * selectedRow = [(UITableView *)gestureView indexPathForRowAtPoint:point];
			if(selectedRow)
			{
				// Get the picked driver - may be from either driver list, or the prediction
				int selectedDriverIndex = -1;
				bool invalid = true;

				if(gestureView == drivers1 || gestureView == drivers2)
				{
					int driverListSplit = portraitMode ? [[[RacePadDatabase Instance]driverNames] count] : [[[RacePadDatabase Instance]driverNames] count] / 2;
					int driverListOffset = (gestureView == drivers1) ? 0 : driverListSplit;
					selectedDriverIndex = selectedRow.row + driverListOffset;
					invalid = (selectedDriverIndex < 0 || (gestureView == drivers1 && selectedDriverIndex > driverListSplit) || selectedDriverIndex >= [[[RacePadDatabase Instance]driverNames] count]);
				}
				else if(gestureView == result)
				{
					RacePrediction *racePrediction = [[RacePadDatabase Instance] racePrediction];
					int * prediction = [racePrediction prediction];
					
					if ( selectedRow.row < [[[RacePadDatabase Instance] racePrediction] count] )
					{
						int p = prediction[selectedRow.row];
						if(p >= 0)
						{
							selectedDriverIndex = [[[RacePadDatabase Instance] driverNames] driverIndexByNumber:p];
							invalid = (selectedDriverIndex < 0 || selectedDriverIndex >= [[[RacePadDatabase Instance]driverNames] count]);
						}
					}
				}
								
				// Pick driver if we're allowed
				RacePrediction *p = [[RacePadDatabase Instance] racePrediction]; 
				if ( [p validUser] && !needPin && !invalid )
				{
					[self.view addSubview:draggedDriverCell];
					[self addDropShadowToView:draggedDriverCell WithOffsetX:5 Y:5 Blur:3];

					CGRect rowRect = [(UITableView *)gestureView rectForRowAtIndexPath:selectedRow];
					CGRect tableFrame = [gestureView frame];
					CGRect dragFrame = CGRectMake(tableFrame.origin.x + rowRect.origin.x, tableFrame.origin.y + rowRect.origin.y, rowRect.size.width, rowRect.size.height);
					[draggedDriverCell setFrame:dragFrame];
					
					UITableViewCell * cell = [(UITableView *)gestureView cellForRowAtIndexPath:selectedRow];
					[draggedDriverText setText:[[cell textLabel] text]];
					[draggedDriverDetailText setText:[[cell detailTextLabel] text]];

					
					draggingCell = true;
					reorderOnDrop = (gestureView == result);
					draggedDriverIndex = selectedDriverIndex;
				}
			}

			[result deselectRowAtIndexPath:[result indexPathForSelectedRow] animated:false];
			[drivers1 deselectRowAtIndexPath:[drivers1 indexPathForSelectedRow] animated:false];
			[drivers2 deselectRowAtIndexPath:[drivers2 indexPathForSelectedRow] animated:false];

			break;
		}
			
		case UIGestureRecognizerStateChanged:
		{
			// Only do anything if we started properly
			if(!draggingCell)
				break;
			
			// Move the dragged cell
			CGRect frame = [draggedDriverCell frame];
			CGRect newFrame = CGRectOffset(frame, x, y);
			[draggedDriverCell setFrame:newFrame];
			
			// Check whether we are over a cell in the result table
			bool resultCellSelected = false;
			CGPoint resultPoint = [recognizer locationInView:result];
			if([result pointInside:resultPoint withEvent:nil])
			{
				NSIndexPath * resultRow = [result indexPathForRowAtPoint:resultPoint];
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
				[draggedDriverCell removeFromSuperview];
				
				// Check whether we are over a cell in the result table
				if(draggedTargetIndex)
				{
					[self addToPrediction:draggedDriverIndex AtIndexPath:draggedTargetIndex Reorder:reorderOnDrop];
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

- (void) OnTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
	/*
	 if ( gestureView == [self view] || gestureView == leagueTable )
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
	 */
}


@end
