//
//  BaseSocialMediaView.h
//  MidasDemo
//
//  Created by Andrew Greenshaw on 05/01/2012.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kAlphaValue  0.85

@class BaseSocialMediaView;

@protocol BaseSocialMediaViewDelegate
- (void)baseSocialMediaAboutToShow:(BaseSocialMediaView *)controller;
- (void)baseSocialMediaShown:(BaseSocialMediaView *)controller;
- (void)baseSocialMediaAboutToHide:(BaseSocialMediaView *)controller;
- (void)baseSocialMediaHidden:(BaseSocialMediaView *)controller;
@end

@interface BaseSocialMediaView : UIView <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate> {
    UIView *view;
    UIView *topBackView;
    
	UIImageView *bottomBackGraphic;
	UIImageView *topBackGraphic;
	UIImageView *topSendIcon;
	UIImageView *bottomIconGraphic;
	UIImageView *bottonSocialTypeGraphic;
	UITextField *sendText;
    
    NSMutableArray *entryTime;
    NSMutableArray *entryName;
    NSMutableArray *entryImage;
    NSMutableArray *entryComment;
    NSMutableArray *entryUserId;
    NSMutableArray *entryReplied;
    
    UITableView *socialTable;
    
    BOOL visible;
    BOOL replying;
    int replyRow;
}

@property (nonatomic, assign) id <BaseSocialMediaViewDelegate> delegate;

@property (nonatomic, retain) IBOutlet UIView *view;
@property (nonatomic, retain) IBOutlet UIView *topBackView;

@property (nonatomic, retain) IBOutlet UIImageView *bottomBackGraphic;
@property (nonatomic, retain) IBOutlet UIImageView *topBackGraphic;
@property (nonatomic, retain) IBOutlet UIImageView *topSendIcon;
@property (nonatomic, retain) IBOutlet UIImageView *bottomIconGraphic;
@property (nonatomic, retain) IBOutlet UIImageView *bottonSocialTypeGraphic;
@property (nonatomic, retain) IBOutlet UITableView *socialTable;
@property (nonatomic, retain) IBOutlet UITextField *sendText;

@property (nonatomic, retain) NSMutableArray *entryTime;
@property (nonatomic, retain) NSMutableArray *entryName;
@property (nonatomic, retain) NSMutableArray *entryImage;
@property (nonatomic, retain) NSMutableArray *entryComment;
@property (nonatomic, retain) NSMutableArray *entryUserId;
@property (nonatomic, retain) NSMutableArray *entryReplied;

@property BOOL visible;
@property BOOL replying;
@property int replyRow;

- (BOOL)isVisible;
- (IBAction)doLike:(id)sender;

- (void)loadData;
- (void)handleTap:(UITapGestureRecognizer *)sender;
- (void)hideView:(CGFloat)slideDuration;
- (void)showView:(CGFloat)slideDuration;
- (void)showViewAtPos:(CGFloat)slideDuration:(int)atXpos;
- (void)scrollUpStop:(NSString*)animationID finished:(BOOL)finished context:(void *)context;
- (void)scrollDownStop:(NSString*)animationID finished:(BOOL)finished context:(void *)context;
- (void)hideReplying;
- (void)scrollToEnd;
- (CGFloat)getTextHeight:(NSString *)text;
- (void)addEntry:(NSString *)text;

- (UIColor *)getCellBackColour;
- (UIColor *)getSeparatorColour;
- (UIImage *)getHeaderIcon;
- (NSString *)getDefaultText;
- (UIImage *)getFooterIcon;
- (UIImage *)getFooterText;
- (UIImage *)getFooterLogo;
- (UIImage *)getSendLogo;
- (UIImage *)getRepliedIcon;
- (CGRect)getSendTextFrame;
- (CGRect)getTimeTextFrame:(CGFloat)height;
- (CGRect)getNameTextFrame;
- (CGRect)getCommentTextFrame:(CGFloat)height;
- (NSString *)getReplyPrefix:(int)row;
- (NSString *)getCommentText:(int)row;
- (NSString *)getUnformattedCommentText:(int)row;  
- (UIColor *)getTextColour;
- (BOOL)canPostReply;
- (CGFloat)heightForRowAtIndexPath:(CGFloat)row;
- (NSString *)getTimeEntry:(int)offset;
- (BOOL)canLike;

- (IBAction)sendTextFieldEntered:(id)sender;

@end
