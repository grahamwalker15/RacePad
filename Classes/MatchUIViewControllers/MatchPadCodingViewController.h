//
//  MatchPadCodingViewController.h
//  MatchPad
//
//  Created by Simon Cuff on 14/04/2014.
//
//

#import <UIKit/UIKit.h>

#import "BasePadPopupViewController.h"
#import "MovieView.h"
#import "SimpleListViewController.h"
#import "CodingView.h"

@interface MatchPadCodingViewController : BasePadPopupViewController <MovieViewDelegate, SimpleListViewDelegate>
{
	IBOutlet CodingView * codingView;
	IBOutlet UISegmentedControl * typeChooser;
}

- (void) dismissTimerExpired:(NSTimer *)theTimer;

- (IBAction) replaySelected:(id)sender;
- (IBAction) typeChosen:(id)sender;

@end
