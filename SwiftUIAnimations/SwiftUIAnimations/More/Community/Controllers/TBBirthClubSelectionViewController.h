//
//  TBCommunityBirthClubViewController.h
//  TheBump
//
//  Created by Goran Svorcan on 7/17/14.
//  Copyright (c) 2014 xo group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBCommunityNavigationDelegate.h"

@interface TBBirthClubSelectionViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) id<TBCommunityNavigationDelegate> communityNavigationDelegate;

@property (nonatomic, strong) NSArray *bClubListArray;

@property (nonatomic, strong) NSNumber *selectedBirthClub;

@end
