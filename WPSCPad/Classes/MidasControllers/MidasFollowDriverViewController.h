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
#import "MovieView.h"

@class TrackMapView;
@class LeaderboardView;
@class BackgroundView;
@class HeadToHeadView;
@class MidasVotingView;

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
	IBOutlet UIImageView * driverFlag;
	
	IBOutlet UILabel * driverNameLabel;
	IBOutlet UILabel * driverAgeLabel;
	IBOutlet UILabel * driverNationalityLabel;
	IBOutlet UILabel * driverTeamLabel;
	
	IBOutlet UILabel * positionLabel;
	IBOutlet UILabel * placeLabel;
	
	IBOutlet UILabel * carBehindLabel;
	IBOutlet UILabel * gapBehindLabel;
	
	IBOutlet UILabel * carAheadLabel;
	IBOutlet UILabel * gapAheadLabel;
	
	IBOutlet UILabel * votesForCount;
	IBOutlet UILabel * votesAgainstCount;
	IBOutlet UILabel * ratingLabel;
	
	IBOutlet UIButton * voteForButton;
	IBOutlet UIButton * voteAgainstButton;

	IBOutlet LeaderboardView * leaderboardView;
	IBOutlet TrackMapView * trackMapView;
	IBOutlet BackgroundView *trackMapContainer;
	IBOutlet MidasVotingView * midasVotingView;
	
	bool expanded;
	
	NSString * driverToFollow;
}

- (void) expandView;
- (void) reduceViewAnimated:(bool)animated;

- (void) animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void*)context;

- (IBAction) expandPressed;

- (int) getDriverNumber:(NSString *)tag;
- (int) getDriverAge:(NSString *)tag;
- (NSString *) getDriverNationality:(NSString *)tag;
- (UIImage *) getNationalFlag:(NSString *)tag;

- (IBAction) votePressed:(id)sender;

@end
