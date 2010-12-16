//
//  GameViewController.h
//  RacePad
//
//  Created by Gareth Griffith on 10/11/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RacePadViewController.h"
#import "NewCompetitor.h"
#import "ChangeCompetitor.h"
#import "TableDataView.h"

@class	UserPin;

@interface GameViewController : RacePadViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
{
	IBOutlet UITextField *user;
	IBOutlet UIButton *newUser;
	IBOutlet UIButton *changeUser;
	IBOutlet UITableView *result;
	IBOutlet UITableView *drivers;
	IBOutlet UIButton *action;
	IBOutlet UIButton *reset;
	IBOutlet UILabel *status;
	IBOutlet TableDataView *leagueTable;
	
	bool changingSelection;
	int driverCount;
	bool changingUser;
	bool locked;
	int competitorCount;
	bool showingBadUser;
	
	NewCompetitor *newCompetitor;
	ChangeCompetitor *changeCompetitor;
	UserPin *userPin;
	UIAlertView *pinMessage;
}

-(IBAction) newUserPressed:(id)sender;
-(IBAction) changeUserPressed:(id)sender;
-(IBAction) actionPressed:(id)sender;
-(IBAction) resetPressed:(id)sender;
-(void) updatePrediction;
-(void) registeredUser;
-(void) cancelledRegister;
-(void) badUser;
-(void) pinCorrect;
-(void) pinFailed;
-(bool) validName:(NSString *)name;
-(void) lock;

@end
