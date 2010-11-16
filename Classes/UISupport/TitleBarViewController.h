//
//  TitleBarController.h
//  RacePad
//
//  Created by Gareth Griffith on 11/4/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TitleBarViewController : UIViewController
{
	IBOutlet UIButton * sponsorButton;
	IBOutlet UIButton * clock;
	IBOutlet UIButton * eventName;
	IBOutlet UIButton * lapCounter;
	IBOutlet UIBarButtonItem * alertButton;
}

@property (readonly) UIButton * sponsorButton;
@property (readonly) UIBarButtonItem * alertButton;
@property (readonly) UIButton * clock;
@property (readonly) UIButton * eventName;
@property (readonly) UIButton * lapCounter;

- (void)RequestRedraw;

@end
