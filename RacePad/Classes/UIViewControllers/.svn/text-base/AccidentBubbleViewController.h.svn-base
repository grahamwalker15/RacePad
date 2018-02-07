//
//  AccidentBubbleViewController.h
//  RacePad
//
//  Created by Gareth Griffith on 11/10/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SimpleListViewController.h"
#import "AccidentView.h"
#import "ShinyButton.h"

@interface AccidentBubbleViewController : UIViewController
{
	IBOutlet AccidentView *accidentView;
	IBOutlet UIButton *closeButton;
	
	bool shown;
}

@property (nonatomic, retain) AccidentView * accidentView;
@property (nonatomic, readonly) bool shown;

- (void) popUp;
- (void) popDown: (bool) animate;

- (void) resetWidth;
- (void) sizeCommentary: (int) rowCount FromHeight: (int) fromHeight;

- (IBAction) closePressed:(id)sender;

@end
