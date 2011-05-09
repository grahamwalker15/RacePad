//
//  HomeViewController.h
//  RacePad
//
//  Created by Gareth Griffith on 5/9/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RacePadViewController.h"

#import "ShinyButton.h"
#import "BackgroundView.h"

@interface HomeViewController : RacePadViewController
{
	IBOutlet ShinyButton * button1;	
	IBOutlet ShinyButton * button2;	
	IBOutlet ShinyButton * button3;	
	IBOutlet ShinyButton * button4;	
	IBOutlet ShinyButton * button5;	
	IBOutlet ShinyButton * button6;	
	IBOutlet ShinyButton * button7;	
}

- (void) updateButtons;
- (IBAction) buttonPressed:(id)sender;

@end
