//
//  MidasCircuitViewController.h
//  MidasDemo
//
//  Created by Gareth Griffith on 1/7/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MidasBaseViewController.h"
#import "TrackMapView.h"
#import "MovieSelectorView.h"

@interface MidasCircuitViewController : MidasBaseViewController
{
	IBOutlet TrackMapView * trackMapView;
	IBOutlet MovieSelectorView * movieSelectorView;
	
	IBOutlet UIButton * addCircuit;
}

- (IBAction)addToViewButtonPressed:(id)sender;

@end
