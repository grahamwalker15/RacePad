//
//  MatchPadReplaysViewController.h
//
//  Created by Gareth Griffith on 1/6/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BasePadPopupViewController.h"
#import "MovieView.h"
#import "SimpleListViewController.h"
#import "AlertView.h"

@interface MatchPadReplaysViewController : BasePadPopupViewController <MovieViewDelegate, SimpleListViewDelegate>
{
	IBOutlet AlertView * alertView;
	IBOutlet UISegmentedControl * typeChooser;
}

- (void) dismissTimerExpired:(NSTimer *)theTimer;

- (IBAction) replaySelected:(id)sender;
- (IBAction) typeChosen:(id)sender;

@end
