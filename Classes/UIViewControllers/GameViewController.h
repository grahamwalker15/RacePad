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
#import "BackgroundView.h"
#import "DrivingViewController.h"

@class	UserPin;

@interface GameViewController : RacePadViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
{
	IBOutlet BackgroundView *background;
	
	IBOutlet UILabel *signInLabel;
	IBOutlet UITableView *users;
	IBOutlet UILabel *orLabel;
	IBOutlet UIButton *newUser;

	IBOutlet UILabel *user;
	IBOutlet UIButton *changeUser;
	IBOutlet UIButton *signOut;
	
	IBOutlet UIButton *signIn;
	
	IBOutlet UITableView *result;
	IBOutlet UITableView *drivers1;
	IBOutlet UITableView *drivers2;
	IBOutlet UIButton *action;
	IBOutlet UIButton *reset;
	IBOutlet UILabel *status;
	IBOutlet TableDataView *leagueTable;
	IBOutlet UIImageView * predictionBG;
	
	IBOutlet UIView * draggedDriverCell;
	IBOutlet UILabel * draggedDriverText;
	IBOutlet UILabel * draggedDriverDetailText;
	
	IBOutlet UIButton *raceMSC;
	IBOutlet UIButton *raceROS;

	bool changingSelection;
	
	bool draggingCell;
	bool reorderOnDrop;
	int draggedDriverIndex;
	NSIndexPath * draggedTargetIndex;
	
	int driverCount;
	bool changingUser;
	bool needPin;
	bool gettingPin;
	int competitorCount;
	bool showingBadUser;
	unsigned char gameStatus;
	bool predictionChanged;
	bool predictionComplete;
	bool predictionEmpty;
	
	NewCompetitor *newCompetitor;
	ChangeCompetitor *changeCompetitor;
	UserPin *userPin;
	UIAlertView *pinMessage;
	
	DrivingViewController *drivingGame;
	bool inDrivingGame;
}

-(IBAction) newUserPressed:(id)sender;
-(IBAction) changeUserPressed:(id)sender;
-(IBAction) signOutPressed:(id)sender;
-(IBAction) actionPressed:(id)sender;
-(IBAction) resetPressed:(id)sender;
-(void) updatePrediction;
-(void) checkPrediction;
-(void) registeredUser;
-(void) cancelledRegister;
-(void) badUser;
-(void) pinCorrect;
-(void) pinFailed;
-(bool) validName:(NSString *)name;
-(void) lock;
-(void) makeNewUser;
-(void) addToPrediction:(int)driverIndex AtIndexPath:(NSIndexPath *)indexPath Reorder:(bool)reorder;
-(IBAction) raceMSCPressed:(id)sender;
-(IBAction) raceROSPressed:(id)sender;

- (unsigned char) inqGameStatus;
- (void) showViews;
- (void) hideViews;
- (void) positionViews;

@end
