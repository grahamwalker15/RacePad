//
//  InfoChildController.h
//  RacePad
//
//  Created by Gareth Griffith on 2/8/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BackgroundView.h";

@interface InfoChildController : UIViewController <UIWebViewDelegate>
{
	NSString * htmlFile;

	IBOutlet UIToolbar * titleBar;
	
	IBOutlet UIWebView * webView1;
	IBOutlet UIWebView * webView2;
	
	UIWebView * webViewFront;
	UIWebView * webViewBack;
	id placeHolderView;
	float placeHolderAlpha;
	
	IBOutlet UIBarButtonItem * backButton;
	IBOutlet UIBarButtonItem * InfoTitle;
	IBOutlet UIBarButtonItem * previousButton;
	IBOutlet UIBarButtonItem * nextButton;
	
	IBOutlet BackgroundView * backgroundView;
	IBOutlet UIImageView * tableBG;
		
	int webViewCurrent;
	
	bool animatingViews;
	UIViewAnimationTransition htmlTransition;
}

@property (retain) NSString * htmlFile;
@property (nonatomic) UIViewAnimationTransition htmlTransition;

- (void)positionOverlays;
- (void)hideOverlays;
- (void)showOverlays;

- (void)showHTMLContent;
- (void)animateWebView:(UIWebView *)webView;
- (void)fadeWebView:(UIWebView *)webView;

- (IBAction)backPressed:(id)sender;
- (IBAction)previousPressed:(id)sender;
- (IBAction)nextPressed:(id)sender;

@end
