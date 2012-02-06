//
//  MidasStandingsViewController.h
//  MidasDemo
//
//  Created by Gareth Griffith on 1/6/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


#import "MidasBaseViewController.h"
#import "TableDataView.h"
#import "MovieView.h"

@class MidasStandingsViewController;
@class MidasStandingsExpansionView;

@interface MidasStandingsView : TableDataView
{
	MidasStandingsViewController * parentController;
	MidasStandingsExpansionView * expansionView;
	
	NSString * expandedDriver;
}

@property (nonatomic, retain) MidasStandingsViewController * parentController;
@property (nonatomic, retain) MidasStandingsExpansionView * expansionView;
@property (nonatomic, retain) NSString * expandedDriver;

@end

@interface MidasStandingsExpansionView : UIView
{
}
@end

@interface MidasStandingsViewController : MidasBaseViewController <MovieViewDelegate>
{
	// View panels
	IBOutlet UIView * standingsViewContainer;
	IBOutlet MidasStandingsView * standingsView;
	IBOutlet MidasStandingsExpansionView * expansionView;
	
	// Expansion view content
	IBOutlet UILabel * teamName;
	IBOutlet UIImageView * nationalityFlag;
	IBOutlet UILabel * votesForCount;
	IBOutlet UILabel * votesAgainstCount;
	IBOutlet UILabel * ratingLabel;
	
	IBOutlet UIButton * voteForButton;
	IBOutlet UIButton * voteAgainstButton;
	IBOutlet UIButton * onboardVideoButton;
	
	// Expansion animation image
	IBOutlet UIImageView * viewAnimationImage;
	
}

- (void) placeExpansionViewAtRow:(int)row;
- (void) fillExpansionViewForRow:(int)row;

- (UIImage *) getNationalFlag:(int)row;

-(IBAction)movieSelected:(id)sender;

@end
