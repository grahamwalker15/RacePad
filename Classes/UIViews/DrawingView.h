//
//  DrawingView.h
//  RacePad
//
//  Created by Gareth Griffith on 10/5/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DrawingView : UIScrollView
{
	@protected
		
		UIColor * fg_;
		UIColor * bg_;
	
		UIFont * current_font_;
		CGRect current_bounds_;
		CGSize current_size_;
		CGPoint current_origin_;
		CGPoint current_bottom_left_;
		CGPoint current_top_right_;
	
		CGPoint current_scroll_offset_;
	
	
		CGContextRef current_context_;
		
		bool entered_;
				
		int last_x_, last_y_;
		
}
	
// Properties for synthesizing

@property (nonatomic, retain, setter=SetFGColour, getter=FGColour) UIColor * fg_;
@property (nonatomic, retain, setter=SetBGColour, getter=BGColour) UIColor * bg_;

// Initialisation
- (void)InitialiseDrawingViewMembers;
- (void)InitialiseImageDrawing;
- (void)InitialiseFonts;

- (UIColor *)CreateColourRed:(int)r Green:(int)g Blue:(int)b;
- (UIColor *)CreateColourRed:(int)r Green:(int)g Blue:(int)b Alpha:(int)a;

- (UIColor *)CreateHighlightColourFromColour:(UIColor *)source;
- (UIColor *)CreateShadowColourFromColour:(UIColor *)source;

// Basic utilities
- (CGSize)InqSize;

// Request a redraw on next cycle
- (void)RequestRedraw;
- (void)RequestRedrawInRect:(CGRect)rect;

// Recraw window (N.B. THESE METHODS SHOULD BE OVERRIDDEN)
- (void)Draw;
- (void)Draw:(CGRect)rect;

// Drawing should be bracketed with BeginDrawing/EndDrawing. This ensures that
// the display gets flushed correctly on buffered screens.
- (void)BeginDrawing;
- (void)EndDrawing;

// 
// Drawing primitives
// Lines & text drawn in foreground colour
// Fills and text bg drawn in background colour
//

- (void)SaveGraphicsState;
- (void)RestoreGraphicsState;

- (void)ClearScreen;
- (void)SetClippingArea:(CGRect)rect; // N.B. Sets it to an intersection with current clip area. Need a save/restore around it

- (void)SetLineWidth:(float)width;
- (void)SetSolidLine;
- (void)SetDashedLine;

- (void)SetDropShadowXOffset:(float)xoffset YOffset:(float)yoffset Blur:(float)blur; // N.B. Need a save/restore around it to switch off

- (void)LineX0:(float)x0 Y0:(float)y0 X1:(float)x1 Y1:(float)y1;
- (void)LinePoint0:(CGPoint)p0 Point1:(CGPoint)p1;

- (void)FillRectangle:(CGRect)rect;
- (void)FillShadedRectangle:(CGRect)rect;
- (void)LineRectangle:(CGRect)rect;
- (void)FillRectangleX0:(float)x0 Y0:(float)y0 X1:(float)x1 Y1:(float)y1;
- (void)FillShadedRectangleX0:(float)x0 Y0:(float)y0 X1:(float)x1 Y1:(float)y1;
- (void)LineRectangleX0:(float)x0 Y0:(float)y0 X1:(float)x1 Y1:(float)y1;

- (void)EtchRectangle:(CGRect)rect EtchIn:(bool)etch_in;

- (void)FillPolygonPoints:(int)point_count XCoords:(float *)x YCoords:(float *)y;
- (void)LinePolygonPoints:(int)point_count XCoords:(float *)x YCoords:(float *)y;

- (void)SetXorLines:(bool)set;

//
// Image Drawing
//

- (void) DrawImage:(UIImage *)image AtX:(float)x Y:(float)y;
- (void) DrawImage:(UIImage *)image AtX:(float)x Y:(float)y WithAlpha:(float)alpha;

- (void) DrawImage:(UIImage *)image InRect:(CGRect)rect;
- (void) DrawImage:(UIImage *)image InRect:(CGRect)rect WithAlpha:(float)alpha;

- (void) DrawPattern:(UIImage *)image InRect:(CGRect)rect;

//
// Text Drawing
//

- (void)DrawString:(NSString *)string AtX:(float)x Y:(float)y;
- (void)DrawClippedString:(NSString *)string AtX:(float)x Y:(float)y MaxWidth:(float)max_width;
- (void)GetStringBox:(NSString *)string WidthReturn:(float *)width HeightReturn:(float *)height;

- (void)UseTitleFont;
- (void)UseBigFont;
- (void)UseControlFont;
- (void)UseBoldFont;
- (void)UseMediumBoldFont;
- (void)UseRegularFont;

- (void)SelectUIFont;

// Matrix manipulation
- (void)SetScale:(float) scale;
- (void)SetTranslateX:(float)x Y:(float)y;


// Scrolling support

- (void)SetContentWidth:(float)width AndHeight:(float)height;

@end
