//
//  HTMLViewController.h
//  RacePad
//
//  Created by Gareth Griffith on 10/14/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HTMLViewController : UIViewController
{
	NSString * htmlFile;
	
	IBOutlet UIToolbar * titleBar;

	IBOutlet UIWebView * webView;

	IBOutlet UIBarButtonItem * backButton;
	IBOutlet UIBarButtonItem * InfoTitle;
	IBOutlet UIBarButtonItem * previousButton;
	IBOutlet UIBarButtonItem * nextButton;
}

@property (retain) NSString * htmlFile;

- (IBAction)backPressed:(id)sender;
- (IBAction)previousPressed:(id)sender;
- (IBAction)nextPressed:(id)sender;

@end
