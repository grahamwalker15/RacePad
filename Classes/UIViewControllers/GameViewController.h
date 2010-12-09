//
//  GameViewController.h
//  RacePad
//
//  Created by Gareth Griffith on 10/11/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RacePadViewController.h"


@interface GameViewController : RacePadViewController <UITableViewDelegate, UITableViewDataSource>
{
	IBOutlet UIButton *sendPrediction;
	IBOutlet UITableView *result;
	IBOutlet UITableView *drivers;
	IBOutlet UITextField *userName;
	IBOutlet UILabel *status;
	
	bool changingSelection;
}

-(IBAction) predictPressed:(id)sender;
-(IBAction) userChanged:(id)sender;
-(void) updatePrediction;

@end
