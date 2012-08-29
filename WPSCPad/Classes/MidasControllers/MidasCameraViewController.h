//
//  MidasCameraViewController.h
//  MidasDemo
//
//  Created by Gareth Griffith on 8/29/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MidasBaseViewController.h"
#import "TrackMapView.h"
#import "MovieSelectorView.h"
#import "MovieView.h"

@interface MidasCameraViewController : MidasBaseViewController <MovieViewDelegate>
{
	IBOutlet UIButton * onboardButton;
	IBOutlet UIButton * trackCameraButton;
	
	IBOutlet MovieSelectorView * movieSelectorView;
}

- (IBAction)buttonPressed:(id)sender;

@end
