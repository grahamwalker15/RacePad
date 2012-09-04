//
//  MidasFacebookTableViewCell.h
//  Midas
//
//  Created by Daniel Tull on 17/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import <DCTTableViewDataSources/DCTTableViewDataSources.h>

@interface MidasFacebookTableViewCell : DCTTableViewCell
@property (nonatomic, copy) void(^likeHandler)();
@end
