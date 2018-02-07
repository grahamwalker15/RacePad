//
//  WeatherViewController.h
//  RacePad
//
//  Created by Gareth Griffith on 6/21/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BasePadViewController.h"


// In IOS 5.0 :@interface WeatherViewController : UIViewController <UIWebViewDelegate, NSURLConnectionDelegate>
@interface WeatherViewController : BasePadViewController <UIWebViewDelegate>
{
	IBOutlet UIWebView * webView;
}

- (void)showHTMLContent;

- (IBAction)backPressed:(id)sender;
- (IBAction)previousPressed:(id)sender;
- (IBAction)nextPressed:(id)sender;

@end
