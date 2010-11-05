//
//  WorkOffline.h
//  RacePad
//
//  Created by Mark Riches on 05/11/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WorkOffline : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource> {
	
	IBOutlet UIPickerView *event;
	IBOutlet UIButton *ok;
	IBOutlet UIButton *online;
	
	NSMutableArray *events;
	NSMutableArray *sessions;

}

- (IBAction)okPressed:(id)sender;
- (IBAction)onlinePressed:(id)sender;

@end
