//
//  SimpleListViewController.h
//  RacePad
//
//  Created by Gareth Griffith on 10/21/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DrawingViewController.h"


@interface SimpleListViewController : DrawingViewController
{

}

- (bool) HandleSelectHeading;
- (bool) HandleSelectRow:(int)row DoubleClick:(bool)double_click;
- (bool) HandleSelectCol:(int)col;
- (bool) HandleSelectCellRow:(int)row Col:(int)col DoubleClick:(bool)double_click;

@end
