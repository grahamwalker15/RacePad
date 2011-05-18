//
//  TimeViewController.h
//  RacePad
//
//  Created by Gareth Griffith on 10/26/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShinyButton.h"

@interface TimeViewController : UIViewController
{
	IBOutlet UIToolbar * toolbar;
	IBOutlet UIBarButtonItem * playButton;
	IBOutlet UIButton * clock;
	IBOutlet UISlider * timeSlider;
	IBOutlet UIBarButtonItem * replayButton;
	
	IBOutlet UIButton * minus1sButton;
	IBOutlet UIButton * minus10sButton;
	IBOutlet UIButton * minus30sButton;
	
	IBOutlet UIButton * plus1sButton;
	IBOutlet UIButton * plus10sButton;
	IBOutlet UIButton * plus30sButton;
	
	IBOutlet UIButton * slowMotionButton;
	
	IBOutlet ShinyButton * goLiveButton;

	IBOutlet UIView * scrubControl;
}

@property (readonly) UIToolbar * toolbar;
@property (readonly) UIBarButtonItem * playButton;
@property (readonly) UIBarButtonItem * replayButton;
@property (readonly) UISlider * timeSlider;
@property (readonly) UIButton * clock;
@property (readonly) ShinyButton * goLiveButton;

@property (readonly)  UIButton * minus1sButton;
@property (readonly)  UIButton * minus10sButton;
@property (readonly)  UIButton * minus30sButton;

@property (readonly)  UIButton * plus1sButton;
@property (readonly)  UIButton * plus10sButton;
@property (readonly)  UIButton * plus30sButton;

@property (readonly)  UIButton * slowMotionButton;

@end
