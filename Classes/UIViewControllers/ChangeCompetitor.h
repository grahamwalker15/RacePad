//
//  NewCompetitor.h
//  RacePad
//
//  Created by Mark Riches on 04/11/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GameViewController;

@interface ChangeCompetitor : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource> {

	IBOutlet UIButton *cancel;
	IBOutlet UIButton *select;
	IBOutlet UIPickerView *user;

	NSString *currentUser;
	NSMutableArray *competitorNames;
	
	GameViewController *gameController;
}

- (IBAction)cancelPressed:(id)sender;
- (IBAction)selectPressed:(id)sender;

-(void) getUser:(GameViewController *)controller;

@end
