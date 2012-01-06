//
//  MidasBaseViewController.h
//  MidasDemo
//
//  Created by Gareth Griffith on 1/6/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BasePadViewController.h"

@interface MidasBaseViewController : BasePadViewController
{

}

- (void)notifyHidingStandings;
- (void)notifyHidingCircuitView;
- (void)notifyHidingFollowDriver;
- (void)notifyHidingHeadToHead;

@end
