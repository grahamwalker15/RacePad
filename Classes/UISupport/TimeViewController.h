//
//  TimeViewController.h
//  RacePad
//
//  Created by Gareth Griffith on 10/26/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TimeViewController : UIViewController
{
	IBOutlet UIToolbar * toolbar;
	IBOutlet UIBarButtonItem * playButton;
	IBOutlet UIButton * clock;
	IBOutlet UISlider * timeSlider;
	IBOutlet UIBarButtonItem * alertButton;
}

@property (readonly) UIBarButtonItem * playButton;
@property (readonly) UIBarButtonItem * alertButton;
@property (readonly) UISlider * timeSlider;
@property (readonly) UIButton * clock;

@end
