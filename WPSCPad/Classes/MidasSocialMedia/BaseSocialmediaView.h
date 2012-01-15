//
//  BaseSocialmediaViewController.h
//  F1Test
//
//  Created by Andrew Greenshaw on 05/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kAlphaValue  1.0

//#define USE_REAL_TWITTER
//#define INTERNAL_HIDE_SHOW

@class BaseSocialmediaView;

@protocol BaseSocialmediaViewDelegate
- (void)baseSocialmediaAboutToShow:(BaseSocialmediaView *)controller;
- (void)baseSocialmediaShown:(BaseSocialmediaView *)controller;
- (void)baseSocialmediaAboutToHide:(BaseSocialmediaView *)controller;
- (void)baseSocialmediaHidden:(BaseSocialmediaView *)controller;
@end

@interface BaseSocialmediaView : UIView <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate> {
    UIView *view;
    UIView *topBackView;
    
	UIImageView *bottomBackGraphic;
	UIImageView *topBackGraphic;
	UIImageView *topSendIcon;
	UIImageView *bottomIconGraphic;
	UIImageView *bottonSocialTypeGraphic;
	UIImageView *userIcon;
	UILabel *userName;
	UITextField *sendText;
    UIButton *sendButton;

	UIImageView *shad1;
	UIImageView *shad2;
	UIImageView *shad2_1;
	UIImageView *shad3;
	UIImageView *shad4;
    
    NSMutableArray *entryTimings;
    NSMutableArray *entryTime;
    NSMutableArray *entryName;
    NSMutableArray *entryImage;
    NSMutableArray *entryComment;
    NSMutableArray *entryUserId;
    NSMutableArray *entryReplied;

    NSMutableArray *dummyEntryName;
    NSMutableArray *dummyEntryImage;
    NSMutableArray *dummyEntryComment;
    NSMutableArray *dummyEntryUserId;
    
    NSString *twitUser;
    NSString *twitUserName;
    UIImage *twitImage;
    
    UITableView *socialTable;
    
    BOOL visible;
    BOOL replying;
    int replyRow;
    int lastMessageCount;
    
    int addedRows;
}

@property (nonatomic, assign) id <BaseSocialmediaViewDelegate> delegate;

@property (nonatomic, retain) IBOutlet UIView *view;
@property (nonatomic, retain) IBOutlet UIView *topBackView;

@property (nonatomic, retain) IBOutlet UIImageView *bottomBackGraphic;
@property (nonatomic, retain) IBOutlet UIImageView *topBackGraphic;
@property (nonatomic, retain) IBOutlet UIImageView *topSendIcon;
@property (nonatomic, retain) IBOutlet UIImageView *bottomIconGraphic;
@property (nonatomic, retain) IBOutlet UIImageView *bottonSocialTypeGraphic;
@property (nonatomic, retain) IBOutlet UITableView *socialTable;
@property (nonatomic, retain) IBOutlet UIImageView *userIcon;
@property (nonatomic, retain) IBOutlet UILabel *userName;
@property (nonatomic, retain) IBOutlet UITextField *sendText;
@property (nonatomic, retain) IBOutlet UIButton *sendButton;

@property (nonatomic, retain) IBOutlet UIImageView *shad1;
@property (nonatomic, retain) IBOutlet UIImageView *shad2;
@property (nonatomic, retain) IBOutlet UIImageView *shad2_1;
@property (nonatomic, retain) IBOutlet UIImageView *shad3;
@property (nonatomic, retain) IBOutlet UIImageView *shad4;

@property (nonatomic, retain) NSMutableArray *entryTimings;
@property (nonatomic, retain) NSMutableArray *entryTime;
@property (nonatomic, retain) NSMutableArray *entryName;
@property (nonatomic, retain) NSMutableArray *entryImage;
@property (nonatomic, retain) NSMutableArray *entryComment;
@property (nonatomic, retain) NSMutableArray *entryUserId;
@property (nonatomic, retain) NSMutableArray *entryReplied;

@property (nonatomic, retain) NSMutableArray *dummyEntryName;
@property (nonatomic, retain) NSMutableArray *dummyEntryImage;
@property (nonatomic, retain) NSMutableArray *dummyEntryComment;
@property (nonatomic, retain) NSMutableArray *dummyEntryUserId;

@property (nonatomic, retain) NSString *twitUser;
@property (nonatomic, retain) NSString *twitUserName;
@property (nonatomic, retain) UIImage *twitImage;

@property BOOL visible;
@property BOOL replying;
@property int replyRow;
@property int lastMessageCount;

@property int addedRows;

- (BOOL)isVisible;
- (IBAction)doLike:(id)sender;

- (void)loadData;
- (void)handleSwipe:(UISwipeGestureRecognizer *)sender;
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
- (UIImage *)resizeImage:(UIImage *)image width:(int)width height:(int)height;

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
- (void)getTwitUser;

- (IBAction)sendTextFieldEntered:(id)sender;
- (IBAction)sendButtonTweet:(id)sender;

- (void)__checkForNewMessages:(CGFloat)mTime;
- (void)insertDummyEntry:(int)row;
- (BOOL)haveNewMessage;

@end
