//
//  ServerConnect.h
//  RacePad
//
//  Created by Mark Riches on 04/11/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ServerConnect : UIViewController {

	IBOutlet UILabel *label;
	IBOutlet UIActivityIndicatorView *whirl;
	IBOutlet UIButton *retry;
	IBOutlet UIButton *settings;
	IBOutlet UIButton *close;
	
	NSTimer *timer;
	bool shouldBePoppedDown;

}

- (IBAction)retryPressed:(id)sender;
- (IBAction)settingsPressed:(id)sender;
- (IBAction)closePressed:(id)sender;

-(void) popDown;
-(void) badVersion;
-(void) connectionTimeout;

@end
