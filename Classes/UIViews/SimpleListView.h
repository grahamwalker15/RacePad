//
//  SimpleListView.h
//  RacePad
//
//  Created by Gareth Griffith on 10/8/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "DrawingView.h"

// Cell types
enum CellTypes {
	SLV_TEXT_CELL_,			
	SLV_IMAGE_CELL_,
	SLV_CLIENT_IMAGE_,
} ;

// Text align types
enum AlignTypes {
	SLV_TEXT_LEFT_,			
	SLV_TEXT_RIGHT_,			
	SLV_TEXT_CENTRE_,			
} ;

// Column types
enum ColumnTypes {
	SLV_COL_STANDALONE_,			
	SLV_COL_PARENT_,			
	SLV_COL_CHILD_			
} ;

// Column priority
enum ColumnPriority {
	SLV_USE_FOR_LANDSCAPE,
	SLV_USE_FOR_PORTRAIT,
	SLV_USE_FOR_BOTH,
} ;

#define SLV_MAX_COLUMNS 1024

@interface SimpleListView : DrawingView
{
	@protected
	
	UIColor * heading_bg_colour_;
	UIColor * heading_text_colour_;
	
	UIColor * option_tyre_;
	UIColor * prime_tyre_;
	UIColor * inter_tyre_;
	UIColor * wet_tyre_;
	
	UIColor * black_;
	UIColor * white_;
	UIColor * blue_;
	UIColor * orange_;
	UIColor * yellow_;
	UIColor * red_;
	UIColor * cyan_;
	UIColor * dark_blue_;
	UIColor * light_blue_;
	UIColor * dark_grey_;
	UIColor * light_grey_;
	UIColor * very_light_blue_;
	UIColor * very_light_grey_;
	UIColor * light_orange_;
	
	int row_count_ ;
	int row_height_;
	
	int column_count_;
	
	int column_width_[SLV_MAX_COLUMNS];
	int column_type_[SLV_MAX_COLUMNS];
	
	bool if_heading_ ;
	bool if_large_font_;
		
	int text_baseline_;
		
	int selected_row_;
	int selected_col_;
	
	int down_row_, down_col_;
	int mouse_x_, mouse_y_;
	int down_x_, down_y_;
	bool select_on_up_;
	
	int click_;
	bool double_click_possible_;
	
	UIColor * base_colour_;
	UIColor * selected_colour_;
	UIColor * focus_colour_;
	UIColor * selected_text_colour_;
	
	UIColor * text_colour_;
	UIColor * background_colour_;
	
	int alignment_;
	
	bool portraitMode;;
		
}

@property (nonatomic, retain, setter=SetBaseColour, getter=BaseColour) UIColor * base_colour_;
@property (nonatomic, retain, setter=SetSelectedColour, getter=SelectedColour) UIColor * selected_colour_;
@property (nonatomic, retain, setter=SetFocusColour, getter=FocusColour) UIColor * focus_colour_;
@property (nonatomic, retain, setter=SetSelectedTextColour, getter=SetSelectedTextColour) UIColor * selected_text_colour_;
@property (nonatomic, retain, setter=SetTextColour, getter=TextColour) UIColor * text_colour_;
@property (nonatomic, retain, setter=SetBackgroundColour, getter=BackgroundColour) UIColor * background_colour_;

- (void) DeleteTable;

- (void) SetRowCount:(int)count;
- (void) SetRowHeight:(int)height;

- (void) AddColumn;
- (void) AddColumnWithWidth:(int)width;
- (void) AddColumnWithWidth:(int)width Type:(int)type;
- (void) SetColumn:(int)column Width:(int)width;

- (int) TableWidth;

- (void) SetHeading:(bool)if_heading;
- (void) SetLargeFont:(bool)if_large;

- (void) ScrollToEnd;
- (void) ScrollToEndAndRedraw;
- (void) ScrollToRow:(int)row;
- (void) ScrollToRowAndRedraw:(int)row;
- (void) MakeRowVisible:(int)row;
- (void) MakeRowVisibleAndRedraw:(int)row;

/*
- (void) MouseDown ( int x, int y, int button, int detail );
- (void) DoubleClick ( int x, int y, int button, int detail );
- (// void MouseMove ( int x, int y, int button, int detail );
- (void) MouseUp ( int x, int y, int button, int detail );
- (void) MousePosition ( int x, int y, int detail );
- (void) Enter ( int x, int y );
- (void) Exit ( );
- (void) ActionKey ( unsigned char ch, int detail );
 - (void) GetMousePosition(int &x, int &y);
 
*/

- (void) ClearRows;
- (bool) IfHeading;

- (void) SetDefaultFormatting:(bool)if_heading;
- (void) SetTextColour:(UIColor *)colour;
- (void) SetBackgroundColour:(UIColor *)colour;
- (void) MixBackgroundColour:(UIColor *)colour MixPct:(int) pct;
- (void) DarkenBackgroundColour;
- (void) LightenBackgroundColour;
- (void) SetBaseColour:(UIColor *)colour;
- (void) SetAlignment:(int)alignment;

// Protected functions that can be overridden
- (bool) IsRowSelected:(int)index;
- (int) InqSelectedRowIndex;
- (bool) IsColSelected:(int)index;
- (int) InqSelectedColIndex;

- (void) DrawRow:(int)row AtY:(float)y;
- (void) Draw:(CGRect)region;
- (void) DrawBase;

// Functions that CAN be overridden for customised content (defaults return local array counts)
- (int) RowCount;
- (int) ColumnCount;

- (int) RowHeight;
- (int) ColumnWidth:(int)col;
- (int) ColumnType:(int)col;
- (int) ColumnUse:(int)col;

// Functions that CAN be overridden for customised content (defaults do nothing)
- (void) PrepareData;
- (void) PrepareRow:(int)row;

// Functions that MUST be overridden for customised content (defaults return no content)
- (int) InqCellTypeAtRow:(int)row Col:(int)col;
- (NSString *) GetCellTextAtRow:(int)row Col:(int)col;
- (UIImage *) GetCellImageAtRow:(int)row Col:(int)col;
- (UIImage *) GetCellClientImageAtRow:(int)row Col:(int)col;
- (NSString *) GetHeadingAtCol:(int)col;

- (void) InitialiseSimpleListViewMembers;

- (bool) FindCellAtX:(float)x Y:(float)y RowReturn:(int *)row_return ColReturn:(int *)col_return;

@end