//
//  TitleBarController.h
//  RacePad
//
//  Created by Gareth Griffith on 11/4/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ColouredButton.h"

@interface TitleBarViewController : UIViewController
{
	IBOutlet UIButton * sponsorButton;
	IBOutlet UIButton * clock;
	IBOutlet UIButton * eventName;
	IBOutlet ColouredButton * lapCounter;
	IBOutlet UIBarButtonItem * alertButton;
	IBOutlet UIButton * helpButton;
	IBOutlet UIBarButtonItem * helpBarButton;
	IBOutlet UIButton * trackStateButton;
}

@property (readonly) UIButton * sponsorButton;
@property (readonly) UIBarButtonItem * alertButton;
@property (readonly) UIBarButtonItem * helpBarButton;
@property (readonly) UIButton * helpButton;
@property (readonly) UIButton * clock;
@property (readonly) UIButton * eventName;
@property (readonly) ColouredButton * lapCounter;
@property (readonly) UIButton * trackStateButton;

- (void)RequestRedraw;

@end
