//
//  TableDataView.h
//  RacePad
//
//  Created by Gareth Griffith on 10/12/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SimpleListView.h"

@interface TableDataView : SimpleListView
{
	id table_data_;
	bool smallHeadings;
}

@property (nonatomic, retain, setter=SetTableDataClass:, getter=TableData) id table_data_;
@property (nonatomic) bool smallHeadings;

@end
