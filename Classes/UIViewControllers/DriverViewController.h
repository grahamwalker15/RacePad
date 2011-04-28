//
//  DriverViewController.h
//  RacePad
//
//  Created by Gareth Griffith on 12/1/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CarViewController.h"

@class LeaderboardView;

@interface DriverViewController : CarViewController
{
	IBOutlet LeaderboardView * leaderboardView;
}

@end


