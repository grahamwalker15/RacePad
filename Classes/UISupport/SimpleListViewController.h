//
//  SimpleListViewController.h
//  RacePad
//
//  Created by Gareth Griffith on 10/21/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BasePadViewController.h"

@interface SimpleListViewController : BasePadViewController
{
}

- (bool) HandleSelectHeading;
- (bool) HandleSelectRow:(int)row DoubleClick:(bool)double_click LongPress:(bool)long_press;
- (bool) HandleSelectCol:(int)col;
- (bool) HandleSelectCellRow:(int)row Col:(int)col DoubleClick:(bool)double_click LongPress:(bool)long_press;
- (bool) HandleSelectBackgroundDoubleClick:(bool)double_click LongPress:(bool)long_press;
- (void) HandleTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y;

@end
