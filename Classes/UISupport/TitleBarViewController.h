//
//  TitleBarController.h
//  RacePad
//
//  Created by Gareth Griffith on 11/4/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ShinyButton.h"

@interface TitleBarViewController : UIViewController
{
	IBOutlet UIToolbar * toolbar;
	
	IBOutlet UIButton * sponsorButton;
	IBOutlet UIButton * clock;
	IBOutlet UIButton * eventName;
	IBOutlet ShinyButton * lapCounter;
	IBOutlet UIBarButtonItem * alertButton;
	IBOutlet UIButton * helpButton;
	IBOutlet UIBarButtonItem * helpBarButton;
	IBOutlet UIButton * trackStateButton;
	IBOutlet UIBarButtonItem * playStateBarItem;
	IBOutlet UIButton * playStateButton;

	NSArray * allItems;

}

@property (readonly) UIToolbar * toolbar;
@property (readonly) UIButton * sponsorButton;
@property (readonly) UIBarButtonItem * alertButton;
@property (readonly) UIBarButtonItem * helpBarButton;
@property (readonly) UIButton * helpButton;
@property (readonly) UIButton * clock;
@property (readonly) UIButton * eventName;
@property (readonly) ShinyButton * lapCounter;
@property (readonly) UIButton * trackStateButton;
@property (readonly) UIBarButtonItem * playStateBarItem;
@property (readonly) UIButton * playStateButton;

@property (readonly) NSArray * allItems;

- (void)RequestRedraw;

@end
