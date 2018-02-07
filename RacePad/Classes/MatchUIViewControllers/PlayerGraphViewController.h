//
//  PlayerGraphViewController.h
//  RacePad
//
//  Created by Gareth Griffith on 10/1/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BasePadViewController.h"

@class PlayerGraphView;
@class BackgroundView;

@interface PlayerGraphViewController : BasePadViewController
{
	IBOutlet BackgroundView *mainBackgroundView;
	IBOutlet BackgroundView *backgroundView;
	IBOutlet PlayerGraphView *graphView;

	IBOutlet UIToolbar * title_bar_;
	IBOutlet UIView * swipe_catcher_view_;
	
	IBOutlet UIBarButtonItem * back_button_;
	IBOutlet UIBarButtonItem * effectiveness_button_;
	IBOutlet UIBarButtonItem * passes_button_;
	IBOutlet UIBarButtonItem * title_;
	IBOutlet UIBarButtonItem * previous_button_;
	IBOutlet UIBarButtonItem * next_button_;
}

- (IBAction)BackButton:(id)sender;
- (IBAction)EffectivenessButton:(id)sender;
- (IBAction)PassesButton:(id)sender;
- (IBAction)PreviousButton:(id)sender;
- (IBAction)NextButton:(id)sender;

@end
