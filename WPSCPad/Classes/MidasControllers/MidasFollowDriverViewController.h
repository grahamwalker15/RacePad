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

@class TrackMapView;
@class LeaderboardView;
@class BackgroundView;
@class HeadToHeadView;

@interface MidasFollowDriverLapListView : TableDataView
{
}
@end

@interface MidasFollowDriverViewController : MidasBaseViewController
{
	IBOutlet UIButton * expandButton;
	IBOutlet UIView * extensionContainer;
	
	IBOutlet MidasFollowDriverLapListView * lapTimesView;
	IBOutlet HeadToHeadView * headToHeadView;
	
	IBOutlet UIImageView * animationPanelImage;
	IBOutlet UIView * driverInfoPanel;
	IBOutlet UIView * selectDriverPanel;
	
	IBOutlet UIImageView * driverPhoto;
	IBOutlet UIImageView * driverHelmet;
	IBOutlet UIImageView * driverCar;
	
	IBOutlet UILabel * driverNameLabel;
	IBOutlet UILabel * driverNumberLabel;
	IBOutlet UILabel * driverTeamLabel;
	
	IBOutlet UILabel * positionLabel;
	
	IBOutlet UILabel * carBehindLabel;
	IBOutlet UILabel * gapBehindLabel;
	
	IBOutlet UILabel * carAheadLabel;
	IBOutlet UILabel * gapAheadLabel;
	
	IBOutlet UIButton * onboardVideoButton;

	IBOutlet LeaderboardView * leaderboardView;
	IBOutlet TrackMapView * trackMapView;
	IBOutlet BackgroundView *trackMapContainer;
	
	bool expanded;
	
	NSString * driverToFollow;
}

- (void) expandView;
- (void) reduceViewAnimated:(bool)animated;

- (void) animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void*)context;

- (IBAction) expandPressed;
- (IBAction) movieSelected:(id)sender;

- (int) getDriverNumber:(NSString *)tag;

@end
