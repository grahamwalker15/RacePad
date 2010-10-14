//
//  DrawingViewController.h
//  RacePad
//
//  Created by Gareth Griffith on 10/12/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DrawingViewController : UIViewController
{

}

// Action callbacks

- (void) OrientationChange:(NSNotification *)notification;

- (IBAction) OnTouchDownX:(float)x Y:(float)y;
- (IBAction) OnTouchUpX:(float)x Y:(float)y;
- (IBAction) OnTouchMoveX:(float)x Y:(float)y;
- (IBAction) OnTouchCancelledX:(float)x Y:(float)y;

@end
