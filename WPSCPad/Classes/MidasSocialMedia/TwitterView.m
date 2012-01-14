//
//  TwitterView.m
//  F1Test
//
//  Created by Andrew Greenshaw on 09/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TwitterView.h"

#ifdef USE_REAL_TWITTER
#import <Accounts/Accounts.h>
#import "JSON.h"
#import <Twitter/Twitter.h>
#endif


#define kTestDataLen    12

@implementation TwitterView

@synthesize lastTweetId;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#ifdef USE_REAL_TWITTER

- (void)sendTweet:(NSString *)tweet {
    if (([tweet length] > 0) && [TWTweetComposeViewController canSendTweet]) 
    {
        // Create account store, followed by a twitter account identifier
        // At this point, twitter is the only account type available
        ACAccountStore *account = [[ACAccountStore alloc] init];
        ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        // Request access from the user to access their Twitter account
        [account requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) 
         {
             // Did user allow us access?
             if (granted == YES)
             {
                 // Populate array with all available Twitter accounts
                 NSArray *arrayOfAccounts = [account accountsWithAccountType:accountType];
                 
                 // Sanity check
                 if ([arrayOfAccounts count] > 0) 
                 {
                     // Keep it simple, use the first account available
                     ACAccount *twitAccount = [arrayOfAccounts objectAtIndex:0];
                     NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
                     [params setObject:tweet forKey:@"status"];
                     
                     NSURL *url = [NSURL URLWithString:@"http://api.twitter.com/1/statuses/update.json"];
                     TWRequest *request = [[TWRequest alloc] initWithURL:url parameters:params requestMethod:TWRequestMethodPOST];
                     
                     [request setAccount:twitAccount];  
                     
                     [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) 
                      {
                          //NSString *output = [NSString stringWithFormat:@"HTTP Response with %i", [urlResponse statusCode]];
                          //NSLog(@"send tweet resp = %@", output);
                      }];
                 }
             }
         }];
    }
}

- (IBAction)sendButtonTweet:(id)sender
{
    [self sendTweet:self.sendText.text];
    [self hideView:0.4];
    self.sendText.text = @"";
    [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(scrollToEnd) userInfo:nil repeats:NO];
}

- (void)scrollToEnd {
    if ([self.entryTime count] > 0)
    {
        NSIndexPath *ipath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.socialTable scrollToRowAtIndexPath :ipath atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }
}
- (void)updateTable:(id)object
{
    [self.socialTable reloadData];
    [self.socialTable beginUpdates];
    [self.socialTable endUpdates];
}

- (void)addEntry:(NSString *)text {
    [self sendTweet:text];
}

- (void)loadTweets
{
    if (self.replying == NO) // will have to get the updates next time if replying....
    {
        ACAccountStore *account = [[ACAccountStore alloc] init];
        ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        // Request access from the user to access their Twitter account
        [account requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) 
         {
             // Did user allow us access?
             if (granted == YES)
             {
                 // Populate array with all available Twitter accounts
                 NSArray *arrayOfAccounts = [account accountsWithAccountType:accountType];
                 
                 // Sanity check
                 if ([arrayOfAccounts count] > 0) 
                 {
                     // Keep it simple, use the first account available
                     ACAccount *twitAccount = [arrayOfAccounts objectAtIndex:0];
                     
                     //NSLog(@"User = %@", twitAccount.username);
                     //NSLog(@"User Id = %@", twitAccount.identifier);
                     
                     NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
                     [params setObject:@"1" forKey:@"include_entities"];
                     [params setObject:@"14" forKey:@"count"];
                     if (self.lastTweetId > 0L)
                     {
                         // Only want tweets since last one (ie latest)
                         NSString *count = [[NSString alloc] initWithFormat:@"%llu", self.lastTweetId];
                         [params setObject:count forKey:@"since_id"];
                     }
                     
                     //  The endpoint that we wish to call
                     NSURL *url = [NSURL URLWithString:@"http://api.twitter.com/1/statuses/home_timeline.json"];
                     
                     //  Build the request with our parameter 
                     TWRequest *request = [[TWRequest alloc] initWithURL:url parameters:params requestMethod:TWRequestMethodGET];
                     
                     // Post the request
                     [request setAccount:twitAccount];
                     
                     // Block handler to manage the response
                     [request performRequestWithHandler:^(NSData *rponseData, NSHTTPURLResponse *urlResponse, NSError *error) 
                      {
                          NSString *responseString = [[NSString alloc] initWithData:rponseData encoding:NSUTF8StringEncoding];
                          //NSLog(@"resp %@", responseString);
                          //NSLog(@"Twitter response, HTTP response: %i", [urlResponse statusCode]);
                          if (error != nil) 
                          {
                              // inspect the contents of error 
                              NSLog(@"%@", error);
                          } 
                          else 
                          {
                              NSError *jsonError = nil;
                              NSArray *timeline = [responseString JSONValue];
                              if (jsonError == nil && timeline && [timeline count] > 0) 
                              {                          
                                  // at this point, we have an object that we can parse
                                  for (int i = [timeline count] - 1; i >= 0; i--)
                                  {
                                      NSDictionary *aTweet = [timeline objectAtIndex:i];
                                      NSDictionary *aUser = [aTweet objectForKey:@"user"];
                                      NSLog(@"%@", aTweet);
                                      //NSLog(@"%@", [aTweet objectForKey:@"text"]);
                                      //NSLog(@"%@", [aTweet objectForKey:@"created_at"]);
                                      //NSLog(@"%@", [aUser objectForKey:@"name"]);
                                      //NSLog(@"%@", [aUser objectForKey:@"screen_name"]);
                                      //NSLog(@"%@", [aUser objectForKey:@"profile_image_url"]);
                                      
                                      NSString *ltime = [aTweet objectForKey:@"created_at"];
                                      NSRange rnge = NSMakeRange(11, 5);
                                      [self.entryTime insertObject:[ltime substringWithRange:rnge] atIndex:0];
                                      [self.entryName insertObject:[aUser objectForKey:@"name"] atIndex:0];
                                      [self.entryImage insertObject:[aUser objectForKey:@"profile_image_url"] atIndex:0];
                                      NSString *text = [aTweet objectForKey:@"text"];
                                      text = [text stringByReplacingOccurrencesOfString:@" \n" withString:@" "];
                                      text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
                                      [self.entryComment insertObject:text atIndex:0];
                                      NSString *userId = [[NSString alloc] initWithFormat:@"@%@ ", [aUser objectForKey:@"screen_name"]];
                                      [self.entryUserId insertObject:userId atIndex:0];
                                      [self.entryReplied insertObject:@"NO" atIndex:0];                                  
									  
                                      NSURL *url = [NSURL URLWithString:[self.entryImage objectAtIndex:0]];
                                      NSData *data = [NSData dataWithContentsOfURL:url];
                                      UIImage *tmpImage = [UIImage imageWithData:data];                                          
                                      [self.entryImage replaceObjectAtIndex:0 withObject:tmpImage];
                                      
                                      if (i == 0)
                                      {
                                          // Save tweet id
                                          NSString *tweetId = [aTweet objectForKey:@"id"];
                                          if (tweetId)
                                          {
                                              self.lastTweetId = [tweetId longLongValue] + 1L;
                                          }
                                      }
                                  }
                                  [self performSelectorOnMainThread:@selector(updateTable:) withObject:nil waitUntilDone:NO];
                              } 
                              else 
                              { 
                                  // inspect the contents of jsonError
                                  //NSLog(@"%@", jsonError);
                              }
                          }
                      }];
                 }
             }
         }];
    }
}

#endif

- (void)loadData {
    self.lastTweetId = 0;
    self.entryTimings = [[NSMutableArray alloc] initWithCapacity:kTestDataLen];
    self.entryTime = [[NSMutableArray alloc] initWithCapacity:kTestDataLen];
    self.entryName = [[NSMutableArray alloc] initWithCapacity:kTestDataLen];
    self.entryImage = [[NSMutableArray alloc] initWithCapacity:kTestDataLen];
    self.entryComment = [[NSMutableArray alloc] initWithCapacity:kTestDataLen];
    self.entryUserId = [[NSMutableArray alloc] initWithCapacity:kTestDataLen];
    self.entryReplied = [[NSMutableArray alloc] initWithCapacity:kTestDataLen];
	
    self.dummyEntryName = [[NSMutableArray alloc] initWithCapacity:kTestDataLen];
    self.dummyEntryImage = [[NSMutableArray alloc] initWithCapacity:kTestDataLen];
    self.dummyEntryComment = [[NSMutableArray alloc] initWithCapacity:kTestDataLen];
    self.dummyEntryUserId = [[NSMutableArray alloc] initWithCapacity:kTestDataLen];
	
    NSNumber *aNumber = [NSNumber numberWithFloat:1];
    [self.entryTimings addObject:aNumber];
    [self.entryTimings addObject:aNumber];
    aNumber = [NSNumber numberWithFloat:2];
    [self.entryTimings addObject:aNumber];
    aNumber = [NSNumber numberWithFloat:3];
    [self.entryTimings addObject:aNumber];
    aNumber = [NSNumber numberWithFloat:6];
    [self.entryTimings addObject:aNumber];
    aNumber = [NSNumber numberWithFloat:10];
    [self.entryTimings addObject:aNumber];
    aNumber = [NSNumber numberWithFloat:12];
    [self.entryTimings addObject:aNumber];
    aNumber = [NSNumber numberWithFloat:16];
    [self.entryTimings addObject:aNumber];
    aNumber = [NSNumber numberWithFloat:20];
    [self.entryTimings addObject:aNumber];
    aNumber = [NSNumber numberWithFloat:25];
    [self.entryTimings addObject:aNumber];
    aNumber = [NSNumber numberWithFloat:40];
    [self.entryTimings addObject:aNumber];
    aNumber = [NSNumber numberWithFloat:60];
    [self.entryTimings addObject:aNumber];
	
    [self.dummyEntryName addObject:@"John J"];
    [self.dummyEntryName addObject:@"Freddie F1"];
    [self.dummyEntryName addObject:@"Mary Jane"];
    [self.dummyEntryName addObject:@"Chris"];
    [self.dummyEntryName addObject:@"Hazel I"];
    [self.dummyEntryName addObject:@"Jake BBCF1"];
    [self.dummyEntryName addObject:@"Eddie I BBCF1"];
    [self.dummyEntryName addObject:@"R Schumacher"];
    [self.dummyEntryName addObject:@"Chris F1 Fan"];
    [self.dummyEntryName addObject:@"Marky Boy"];
    [self.dummyEntryName addObject:@"Kylie M"];
    [self.dummyEntryName addObject:@"Nigel Mansell"];
    
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"user1.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"user2.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"user3.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"user2.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"user1.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"user2.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"user3.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"user1.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"user3.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"user2.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"user1.png"]];
    [self.dummyEntryImage addObject:[UIImage imageNamed:@"user3.png"]];
    
    [self.dummyEntryComment addObject:@"John J Comment"];
    [self.dummyEntryComment addObject:@"Freddie F1 Comment"];
    [self.dummyEntryComment addObject:@"Mary Jane Comment Mary Jane Comment Mary Jane Comment"];
    [self.dummyEntryComment addObject:@"Chris Comment"];
    [self.dummyEntryComment addObject:@"Hazel I Comment Hazel I Comment Hazel I Comment"];
    [self.dummyEntryComment addObject:@"Jake BBCF1 Comment"];
    [self.dummyEntryComment addObject:@"Eddie I BBCF1 Comment"];
    [self.dummyEntryComment addObject:@"R Schumacher Comment"];
    [self.dummyEntryComment addObject:@"Chris F1 Fan Comment"];
    [self.dummyEntryComment addObject:@"Marky Boy Comment"];
    [self.dummyEntryComment addObject:@"Kylie M Comment"];
    [self.dummyEntryComment addObject:@"Nigel Mansell Comment Nigel Mansell Comment"];
    
    [self.dummyEntryUserId addObject:@"@johnj "];
    [self.dummyEntryUserId addObject:@"@freddief1 "];
    [self.dummyEntryUserId addObject:@"@maryjane "];
    [self.dummyEntryUserId addObject:@"@chris "];
    [self.dummyEntryUserId addObject:@"@hazeli "];
    [self.dummyEntryUserId addObject:@"@jakebbc1 "];
    [self.dummyEntryUserId addObject:@"@eddiebbc1 "];
    [self.dummyEntryUserId addObject:@"@rschumacher "];
    [self.dummyEntryUserId addObject:@"@chrisf1 "];
    [self.dummyEntryUserId addObject:@"@markyboy "];
    [self.dummyEntryUserId addObject:@"@kyliem "];
    [self.dummyEntryUserId addObject:@"@nigelmansell "];
	
#ifdef USE_REAL_TWITTER
    if ([TWTweetComposeViewController canSendTweet]) 
    {
        [self loadTweets];
    }
    [NSTimer scheduledTimerWithTimeInterval:90 target:self selector:@selector(loadTweets) userInfo:nil repeats:YES];
#endif
}

- (void)__checkForNewMessages:(CGFloat)mTime {
    if (mTime > 0.0 && self.replying == NO)
    {
        for (int i = 0; i < [self.entryTimings count]; i++)
        {
            CGFloat aFloat = [[self.entryTimings objectAtIndex:i] floatValue];
            if (mTime > aFloat - 0.1 && mTime < aFloat + 0.1)
            {
                [self insertDummyEntry:i];
                [self.socialTable reloadData];
                [self scrollToEnd];
            }
        }
    }
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
