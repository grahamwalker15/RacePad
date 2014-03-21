//
//  DownloadProgress.h
//  RacePad
//
//  Created by Mark Riches on 04/11/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DownloadProgress : UIViewController {

	IBOutlet UILabel *eventName;
	IBOutlet UILabel *sessionName;
	IBOutlet UILabel *progressValue;
	IBOutlet UIProgressView *progressView;
	IBOutlet UIButton * cancelButton;
	
	NSString *event;
	NSString *session;
	
	int sizeToLoad;
	int sizeLoaded;
}

- (void) setProject:(NSString *)event SessionName:(NSString *)session SizeInMB:(int) sizeInMB;
- (void) setProgress: (int)sizeInMB;

- (IBAction)cancelPressed:(id)sender;

@end
