//
//  AlertView.h
//  RacePad
//
//  Created by Gareth Griffith on 11/10/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimpleListView.h"

enum AlertFilter {
	AV_ALL_,
	AV_PIT_,
	AV_OVERTAKE_,
	AV_INCIDENT_,
	AV_EVENT_,
	AV_OTHER_,
	AV_DRIVER_,
};	// Keepin same order as segments in nib file

@interface AlertView : SimpleListView
{
	int filter;
	NSString *driver;
}

-(void) setFilter:(int) type Driver:(NSString *)driver;
-(int) filteredRowToDataRow:(int)row;

@end
