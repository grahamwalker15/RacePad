//
//  RacePadViewController.h
//  RacePad
//
//  Created by Gareth Griffith on 10/29/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

// Virtual class to ensure that all of our view controllers have certain methods

@interface RacePadViewController : UIViewController
{

}

- (UIView *) baseView;

- (void) RequestRedrawForType:(int)type;

@end
