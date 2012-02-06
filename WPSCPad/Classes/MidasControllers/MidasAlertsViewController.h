//
//  MidasAlertsViewController.h
//  MidasDemo
//
//  Created by Gareth Griffith on 1/9/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MidasBaseViewController.h"
#import "AlertView.h"
#import "MovieSelectorView.h"
#import "MovieView.h"


@class MidasAlertsViewController;
@class MidasAlertsExpansionView;

@interface MidasAlertsView : AlertView
{
	MidasAlertsViewController * parentController;
	MidasAlertsExpansionView * expansionView;
	
	int expandedDataRow;
}

@property (nonatomic, retain) MidasAlertsViewController * parentController;
@property (nonatomic, retain) MidasAlertsExpansionView * expansionView;
@property (nonatomic) int expandedDataRow;

@end

@interface MidasAlertsExpansionView : UIView
{
}
@end

@interface MidasAlertsViewController : MidasBaseViewController <MovieViewDelegate>
{
	IBOutlet MidasAlertsView * alertView;
	IBOutlet MidasAlertsExpansionView * expansionView;

	// Expansion view content
	IBOutlet MovieSelectorView * movieSelectorView;

	IBOutlet UIBarButtonItem * closeButton;
	IBOutlet UISegmentedControl * typeChooser;
	
	// Expansion animation image
	IBOutlet UIImageView * viewAnimationImage;
	
}

- (void) UpdateList;

- (void) dismissTimerExpired:(NSTimer *)theTimer;

- (IBAction) typeChosen:(id)sender;

- (bool) HandleSelectRow:(int)row DoubleClick:(bool)double_click LongPress:(bool)long_press;

- (void) placeExpansionViewAtRow:(int)row;

@end
