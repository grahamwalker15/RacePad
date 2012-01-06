//
//  MidasHomeViewController.h
//  MidasDemo
//
//  Created by Gareth Griffith on 1/4/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "BasePadViewController.h"

#import "BackgroundView.h"

@interface MidasHomeViewController : BasePadViewController
{
	IBOutlet BackgroundView * backgroundView;
	
	IBOutlet UIButton * button1;	
	IBOutlet UIButton * button2;	
	IBOutlet UIButton * button3;	
	IBOutlet UIButton * button4;	
	IBOutlet UIButton * button5;	
	IBOutlet UIButton * button6;	
	IBOutlet UIButton * button7;	
}

- (void) updateButtons;
- (IBAction) buttonPressed:(id)sender;

@end

