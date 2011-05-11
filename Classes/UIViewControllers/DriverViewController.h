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
	IBOutlet UIView * pitBoardContainer;
	
	IBOutlet UIImageView * driverPhoto;
	IBOutlet UIImageView * driverTextBG;
	IBOutlet UIImageView * pitBoardImage;
	IBOutlet UIImageView * driverHelmet;
	
	IBOutlet UILabel * driverFirstNameLabel;
	IBOutlet UILabel * driverSurnameLabel;
	IBOutlet UILabel * driverTeamLabel;
	
	IBOutlet UILabel * positionLabel;
	
	IBOutlet UILabel * carBehindLabel;
	IBOutlet UILabel * gapBehindLabel;
	
	IBOutlet UILabel * carAheadLabel;
	IBOutlet UILabel * gapAheadLabel;
	
	IBOutlet LeaderboardView * leaderboardView;
}

- (void)RequestRedraw;

- (void) showDriverInfo:(bool) animated;
- (void) hideDriverInfo:(bool) animated;
- (void) hideDriverInfoAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void*)context;

@end


