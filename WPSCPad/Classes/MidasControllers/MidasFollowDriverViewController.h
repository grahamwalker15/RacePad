//
//  MidasFollowDriverViewController.h
//  MidasDemo
//
//  Created by Gareth Griffith on 1/7/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MidasBaseViewController.h"
#import "TableDataView.h"

@interface MidasFollowDriverViewController : MidasBaseViewController
{
	IBOutlet UIButton * expandButton;
	IBOutlet UIView * extensionContainer;
	
	IBOutlet TableDataView * lapTimesView;
	
	bool expanded;
}

- (void) expandView;
- (void) reduceView;

- (void) animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void*)context;

- (IBAction) expandPressed;

@end
