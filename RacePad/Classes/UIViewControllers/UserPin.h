//
//  UserPin.h
//  RacePad
//
//  Created by Mark Riches on 04/11/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GameViewController;

@interface UserPin : UIViewController <UITextFieldDelegate>
{

	IBOutlet UIButton *titleButton;
	IBOutlet UITextField *pin1;
	IBOutlet UITextField *pin2;
	IBOutlet UITextField *pin3;
	IBOutlet UITextField *pin4;
	IBOutlet UIButton *cancel;
	
	int userPin;
	GameViewController *gameController;
	
	bool changingPin;
	bool wrongPinEntered;

}

- (void) getPin: (int)pin Controller: (GameViewController *)controller;
- (IBAction)cancelPressed:(id)sender;
- (IBAction)digitPressed:(id)sender;
- (IBAction)deletePressed:(id)sender;

@end
