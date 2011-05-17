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
	AV_EVENT_,
	AV_OTHER_
};

@interface AlertView : SimpleListView
{
	int filter;
}

-(void) setFilter:(int) type;
-(int) filteredRowToDataRow:(int)row;

@end
