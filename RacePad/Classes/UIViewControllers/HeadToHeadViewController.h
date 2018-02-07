//
//  HeadToHeadViewController.h
//  RacePad
//
//  Created by Gareth Griffith on 8/30/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BasePadViewController.h"
#import "ShinyButton.h"

@class LeaderboardView;
@class HeadToHeadView;
@class DriverLapListController;
@class BackgroundView;

@class AnimationTimer;

enum H2HDragSource {
	H2H_VC_LEADERBOARD_,
	H2H_VC_DRIVER1_,
	H2H_VC_DRIVER2_
};

@interface HeadToHeadViewController : BasePadViewController
{
	IBOutlet BackgroundView *backgroundView;

	IBOutlet UIView * driverContainer1;
	IBOutlet UIView * driverContainer2;
	
	IBOutlet UIImageView * driverPhoto1;
	IBOutlet UIImageView * driverTextBG1;
	IBOutlet UIImageView * pitBoardImage1;
	IBOutlet UIImageView * driverHelmet1;
	
	IBOutlet UILabel * driverFirstNameLabel1;
	IBOutlet UILabel * driverSurnameLabel1;
	IBOutlet UILabel * driverTeamLabel1;
	
	IBOutlet ShinyButton * seeLapsButton1;
		
	IBOutlet UIImageView * driverPhoto2;
	IBOutlet UIImageView * driverTextBG2;
	IBOutlet UIImageView * pitBoardImage2;
	IBOutlet UIImageView * driverHelmet2;
	
	IBOutlet UILabel * driverFirstNameLabel2;
	IBOutlet UILabel * driverSurnameLabel2;
	IBOutlet UILabel * driverTeamLabel2;
	
	IBOutlet ShinyButton * seeLapsButton2;
	
	IBOutlet LeaderboardView * leaderboardView;
	IBOutlet HeadToHeadView * headToHeadView;

	IBOutlet UIView * draggedDriverCell;
	IBOutlet UILabel * draggedDriverText;
	
	NSString * draggedDriverName;
	unsigned char dragSource;

	DriverLapListController * driver_lap_list_controller_;
	
	bool animating;
	bool showPending;
	bool hidePending;
	
	bool driver_lap_list_controller_displayed_;
	bool telemetry_controller_displayed_;
	bool driver_lap_list_controller_closing_;
	
}

- (void)positionOverlays;
- (void) prePositionOverlays;
- (void) postPositionOverlays;

- (void)showOverlays;
- (void)hideOverlays;
- (void)addBackgroundFrames;

- (void)RequestRedraw;

- (IBAction) seeLapsPressed:(id)sender;

- (void)ShowDriverLapList:(NSString *)driver;
- (void)HideDriverLapListAnimated:(bool)animated;

@end
