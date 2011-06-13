//
//  HelpViewController.h
//  RacePad
//
//  Created by Gareth Griffith on 1/25/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HelpViewMaster

- (bool) helpMasterPlaying;
- (void) helpMasterPausePlay;
- (void) helpMasterStartPlay;

@end


@interface HelpViewController : UIViewController <UIWebViewDelegate, UIPopoverControllerDelegate>
{
	IBOutlet UIBarButtonItem * closeButton;
	
	IBOutlet UIView * backgroundView;
	IBOutlet UIImageView * imageView;
	
	IBOutlet UIButton * helpButton1;
	IBOutlet UIButton * helpButton2;
	IBOutlet UIButton * helpButton3;
	IBOutlet UIButton * helpButton4;
	IBOutlet UIButton * helpButton5;
	IBOutlet UIButton * helpButton6;
	IBOutlet UIButton * helpButton7;
	IBOutlet UIButton * helpButton8;
	IBOutlet UIButton * helpButton9;
	IBOutlet UIButton * helpButton10;
	
	IBOutlet UIWebView * helpTextDefault;
	
	IBOutlet UIWebView * helpText1;
	IBOutlet UIWebView * helpText2;
	IBOutlet UIWebView * helpText3;
	IBOutlet UIWebView * helpText4;
	IBOutlet UIWebView * helpText5;
	IBOutlet UIWebView * helpText6;
	IBOutlet UIWebView * helpText7;
	IBOutlet UIWebView * helpText8;
	IBOutlet UIWebView * helpText9;
	IBOutlet UIWebView * helpText10;
	
	UIButton * helpButtonCurrent;
	UIWebView * helpTextCurrent;
	UIWebView * helpTextPrevious;
	
	UIPopoverController * parentPopover;
	
	int loadCount;
	int loadTarget;
	bool loadComplete;
	bool needsRestartAfterLoad;
	NSTimer *loadTimer;
	
	bool animatingViews;
}

@property (nonatomic, retain) UIPopoverController * parentPopover;

- (void) positionViews;
- (void) getHTMLForView:(UIWebView *)webView WithIndex:(int)index;

- (IBAction) closePressed:(id)sender;
- (IBAction) helpButtonPressed:(id)sender;

- (void) setLoadTimer;
- (void) loadTimerExpired:(NSTimer *)theTimer;

+ (void) specifyHelpMaster:(id) master;

@end
