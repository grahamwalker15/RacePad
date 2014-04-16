//
//  PhysicalStatsController.h
//  MatchPad
//
//  Created by Simon Cuff on 15/04/2014.
//
//

#import <UIKit/UIKit.h>

#import "BasePadPopupViewController.h"
#import "BackgroundView.h"
#import "TableDataView.h"
#import "ShinyButton.h"

@class PlayerGraphViewController;

@interface PhysicalStatsController : BasePadPopupViewController <SimpleListViewDelegate>
{
	IBOutlet BackgroundView * backgroundView;
	
	IBOutlet TableDataView * physical_stats_view_;
	IBOutlet ShinyButton *homeButton;
	IBOutlet ShinyButton *awayButton;
	
	PlayerGraphViewController *playerGraphViewController;
	
	bool playerGraphViewControllerDisplayed;
	bool playerGraphViewControllerClosing;
	
	bool home;
}

@property bool home;

- (IBAction)homePressed:(id)sender;
- (IBAction)awayPressed:(id)sender;

- (void)ShowPlayerGraph:(int)player;
- (void)HidePlayerGraph:(bool)animated;

@end

