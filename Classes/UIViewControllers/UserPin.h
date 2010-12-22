//
//  UserPin.h
//  RacePad
//
//  Created by Mark Riches on 04/11/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GameViewController;

@interface UserPin : UIViewController <UITextFieldDelegate> {

	IBOutlet UITextField *pin;
	IBOutlet UIButton *cancel;
	
	int userPin;
	GameViewController *gameController;
	
	bool changingPin;

}

- (void) getPin: (int)pin Controller: (GameViewController *)controller;
- (IBAction)cancelPressed:(id)sender;
- (IBAction)digitPressed:(id)sender;
- (IBAction)deletePressed:(id)sender;

@end
