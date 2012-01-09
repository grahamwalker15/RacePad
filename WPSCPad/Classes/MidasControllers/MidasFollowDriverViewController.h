//
//  MidasFollowDriverViewController.h
//  MidasDemo
//
//  Created by Gareth Griffith on 1/7/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BasePadViewController.h"

@interface MidasFollowDriverViewController : BasePadViewController
{
	IBOutlet UIImageView * container;
	IBOutlet UIImageView * heading;
	
	IBOutlet UIButton * expandButton;

	IBOutlet UIView * extensionContainer;
	
	bool expanded;
}

@property (readonly) UIImageView * container;

- (void) expandView;
- (void) reduceView;

- (void) animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void*)context;

- (IBAction) expandPressed;

@end
