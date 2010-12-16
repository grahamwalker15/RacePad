//
//  NewCompetitor.h
//  RacePad
//
//  Created by Mark Riches on 04/11/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GameViewController;

@interface NewCompetitor : UIViewController <UITextFieldDelegate> {

	IBOutlet UILabel *status;
	IBOutlet UITextField *name;
	IBOutlet UIActivityIndicatorView *whirl;
	IBOutlet UIButton *cancel;
	
	GameViewController *gameController;

}

- (IBAction)cancelPressed:(id)sender;

-(void) badUser;
- (void) getUser: (GameViewController *)controller;

@end
