//
//  CommentaryBubbleViewController.h
//  RacePad
//
//  Created by Gareth Griffith on 11/10/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SimpleListViewController.h"
#import "CommentaryView.h"
#import "ShinyButton.h"

@interface CommentaryBubbleViewController : UIViewController
{
	IBOutlet CommentaryView *commentaryView;
	IBOutlet UIButton *closeButton;
	
	bool shown;
	bool bottomRight;
	
	bool midasStyle;
}

@property (nonatomic, retain) CommentaryView * commentaryView;
@property (nonatomic, readonly) bool shown;
@property (nonatomic) bool bottomRight;
@property (nonatomic) bool midasStyle;

- (void) popUp;
- (void) popDown: (bool) animate;

- (void) resetWidth;
- (void) sizeCommentary: (int) rowCount FromHeight: (int) fromHeight;

- (IBAction) closePressed:(id)sender;

@end
