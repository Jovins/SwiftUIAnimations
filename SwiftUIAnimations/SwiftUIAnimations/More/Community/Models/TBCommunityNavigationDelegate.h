//
//  TBCommunityNavigationDelegate.h
//  TheBump
//
//  Created by Ravi Joshi on 3/31/15.
//  Copyright (c) 2015 xo group. All rights reserved.
//

@protocol TBCommunityNavigationDelegate <NSObject>

@required
- (void)presentBirthClubSelectionViewWithList:(NSArray *)birthClubs
                       andSelectedBirthClubId:(NSNumber *)birthClubId;

- (void)presentAllForumsViewAndHasBirthClubSelectionChanged:(BOOL)hasChanged;
@end
