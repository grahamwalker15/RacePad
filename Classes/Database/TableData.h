//
//  TableData.h
//  RacePad
//
//  Created by Mark Riches on 11/10/2010.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataStream;

enum DLC_TEXT_ALIGNMENT {
	TEXT_LEFT,
	TEXT_RIGHT,
	TEXT_CENTRE,
};

enum TD_COLUMN_TYPE {
	TD_COL_STANDALONE,
	TD_COL_PARENT,
	TD_COL_CHILD,
};

enum TD_COLUMN_CONTENT {
	TD_STRINGS,
	TD_IMAGES,
};

enum TD_USE_FOR {
	TD_USE_FOR_LANDSCAPE,
	TD_USE_FOR_PORTRAIT,
	TD_USE_FOR_BOTH,
};

@interface TableCell : NSObject
{
	NSString *string;
	UIColor *fg;
	UIColor *bg;
	unsigned char alignment;
};

@property (retain) NSString *string;
@property (retain) UIColor *fg;
@property (retain) UIColor *bg;
@property unsigned char alignment;

- (TableCell *)initWithStream:(DataStream*)stream Colours: (UIColor **)colours ColoursCount: (int)colourCount;
- (void)updateFromStream:(DataStream*)stream Colours: (UIColor **)colours ColoursCount: (int)colourCount;

@end

@interface TableHeader : TableCell
{
	int width;
	unsigned char columnUse;
	unsigned char columnType;
	unsigned char columnContent;
	NSString *imageListName;
}

@property (readonly) int width;
@property (readonly) unsigned char columnUse;
@property (readonly) unsigned char columnType;
@property (readonly) unsigned char columnContent;
@property (readonly, retain) NSString * imageListName;

- (TableHeader *)initHWithStream:(DataStream*)stream Colours: (UIColor **)colours ColoursCount: (int)colourCount;

@end

@interface TableData : NSObject
{
	NSMutableDictionary *titleFields;
	int coloursCount;
	UIColor **colours;
	int rows, cols;
	NSMutableArray *columnHeaders;
	NSMutableArray *cells;
}

- (int)rows;
- (int)cols;
- (NSString *)titleField: (NSString *)name;
- (TableHeader *) columnHeader : (int) col;
- (TableCell *) cell : (int) row Col : (int) col;

- (void) loadData : (DataStream *) stream;
- (void) updateData : (DataStream *) stream;

@end
