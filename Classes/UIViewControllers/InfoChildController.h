//
//  InfoChildController.h
//  RacePad
//
//  Created by Gareth Griffith on 2/8/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BackgroundView.h";

@interface InfoChildController : UIViewController
{
	NSString * htmlFile;

	IBOutlet UIToolbar * titleBar;
	
	IBOutlet UIWebView * webView;
	
	IBOutlet UIBarButtonItem * backButton;
	IBOutlet UIBarButtonItem * InfoTitle;
	IBOutlet UIBarButtonItem * previousButton;
	IBOutlet UIBarButtonItem * nextButton;
	
	IBOutlet BackgroundView * backgroundView;
}

@property (retain) NSString * htmlFile;

- (void)positionOverlays;
- (void)hideOverlays;
- (void)showOverlays;

- (IBAction)backPressed:(id)sender;
- (IBAction)previousPressed:(id)sender;
- (IBAction)nextPressed:(id)sender;

@end
