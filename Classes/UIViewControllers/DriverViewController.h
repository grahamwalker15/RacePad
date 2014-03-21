//
//  DriverViewController.h
//  RacePad
//
//  Created by Gareth Griffith on 12/1/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CarViewController.h"
#import "ShinyButton.h"
#import "TableDataView.h"

@class LeaderboardView;
@class DriverLapListController;
@class TelemetryCarViewController;

// Local version of table data view to allow override of ColumnUse
@interface DriverViewControllerTimingView : TableDataView
{
}
@end

@interface DriverViewController : CarViewController
{
	IBOutlet UIView * pitBoardContainer;
	
	IBOutlet DriverViewControllerTimingView * timingView;
	DriverLapListController * driver_lap_list_controller_;
	TelemetryCarViewController * telemetry_controller_;

	IBOutlet UIImageView * driverPhoto;
	IBOutlet UIImageView * driverTextBG;
	IBOutlet UIImageView * pitBoardImage;
	IBOutlet UIImageView * driverHelmet;
	
	IBOutlet UILabel * driverFirstNameLabel;
	IBOutlet UILabel * driverSurnameLabel;
	IBOutlet UILabel * driverTeamLabel;
	
	IBOutlet ShinyButton * seeLapsButton;
	IBOutlet ShinyButton * telemetryButton;

	IBOutlet UILabel * positionLabel;
	
	IBOutlet UILabel * carBehindLabel;
	IBOutlet UILabel * gapBehindLabel;
	
	IBOutlet UILabel * carAheadLabel;
	IBOutlet UILabel * gapAheadLabel;
	
	IBOutlet ShinyButton * allButton;
	IBOutlet LeaderboardView * leaderboardView;
	
	bool animating;
	bool showPending;
	bool hidePending;
	
	bool driver_lap_list_controller_displayed_;
	bool telemetry_controller_displayed_;
	bool driver_lap_list_controller_closing_;
}

- (void)RequestRedraw;

- (void) showDriverInfo:(bool) animated;
- (void) hideDriverInfo:(bool) animated;
- (void) showDriverInfoAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void*)context;
- (void) hideDriverInfoAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void*)context;

- (IBAction) allButtonPressed:(id)sender;
- (IBAction) seeLapsPressed:(id)sender;
- (IBAction) telemetryPressed:(id)sender;

- (void) setAllSelected:(bool)selected;

- (void)ShowDriverLapList:(NSString *)driver;
- (void)HideDriverLapListAnimated:(bool)animated;

- (void)HideTelemetryAnimated:(bool)animated;

@end


