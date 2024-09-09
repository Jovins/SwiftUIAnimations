//
//  TBCommunityAllForumsViewController.h
//  TheBump
//
//  Created by Goran Svorcan on 7/17/14.
//  Copyright (c) 2014 xo group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBCommunityNavigationDelegate.h"

@interface TBCommunityAllForumsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id<TBCommunityNavigationDelegate> communityNavigationDelegate;

- (void)reloadAllForumsTable;

- (void)presentBirthClubSelectionConfirmation;

- (void)navigateToForumURLString:(NSString *)url withName:(NSString *)name;

@end
