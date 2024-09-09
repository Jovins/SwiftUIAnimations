//
//  TBCommunityBirthClubViewController.m
//  TheBump
//
//  Created by Goran Svorcan on 7/17/14.
//  Copyright (c) 2014 xo group. All rights reserved.
//

#import "TBBirthClubSelectionViewController.h"
#import "TBCommunityBirthClubSelectionView.h"
#import "TBCommunityBirthClubSelectionCollectionViewCell.h"
#import "TBCommunityBirthClubSelectionConfirmationView.h"
#import "TBCommunityDataManager.h"
#import "TBCommunityAPIConstants.h"
#import "TBAPIHelper.h"
#import "TBForum.h"
#import "TBStaleTimeDataManager.h"
#import "NSDate+TheBump.h"
#import <CoreFoundation/CoreFoundation.h>
#import <TheBump-Swift.h>

@interface TBBirthClubSelectionViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) TBCommunityBirthClubSelectionView *birthClubSelectionView;

@end

@implementation TBBirthClubSelectionViewController

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    _birthClubSelectionView = [[TBCommunityBirthClubSelectionView alloc] init];
    _birthClubSelectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [_birthClubSelectionView.birthClubSelectionCollectionView registerClass:[TBCommunityBirthClubSelectionCollectionViewCell class]
                                                 forCellWithReuseIdentifier:TBCommunityBirthClubSelectionCollectionViewCell.defaultReuseIdentifier];
    _birthClubSelectionView.birthClubSelectionCollectionView.dataSource = self;
    _birthClubSelectionView.birthClubSelectionCollectionView.delegate = self;
    [self.view addSubview:_birthClubSelectionView];
    
    [self setupCommunityBirthClubViewConstraints];
    
    UITapGestureRecognizer *tapToDismissGesture = [[UITapGestureRecognizer alloc]
                                                   initWithTarget:self
                                                   action:@selector(dismissBClubSelectionView:)];
    
    tapToDismissGesture.delegate = self;
    [self.view addGestureRecognizer:tapToDismissGesture];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.birthClubSelectionView.birthClubSelectionCollectionView.alpha = 0.0;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UIView animateWithDuration:0.01 animations:^{
        [self.birthClubSelectionView.birthClubSelectionCollectionView reloadData];
        [self scrollToSelectedBirthClub:[TBMemberDataManager sharedInstance].memberDataObject.selectedBirthClubId
                   orSuggestedBirthClub:self.selectedBirthClub
                 fromBirthClubForumList:[[TBCommunityDataManager sharedInstance] fetchForumsByCategory:kCommunityBirthClubsKey]];
        self.birthClubSelectionView.birthClubSelectionCollectionView.alpha = 1.0;
    } completion:nil];
}

- (void)setupCommunityBirthClubViewConstraints {
    NSDictionary *viewsDictionary = @{@"_birthClubSelectionView": _birthClubSelectionView};
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_birthClubSelectionView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_birthClubSelectionView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
}

- (void)saveUserBirthClubSelectionForBirthClub:(TBForum *)bClub {
    TBMemberDataModel *user = [TBMemberDataManager sharedInstance].memberDataObject;
    user.selectedBirthClub.idObjc = bClub.forumId;
    user.selectedBirthClub.name = bClub.forumName;
    user.selectedBirthClub.url = bClub.forumUrl;
    
    KSPromise *memberDataUpdatePromise = [[TBAPIHelper sharedInstance] updateUserWithUserID:[TBMemberDataManager sharedInstance].memberDataObject.memberUserId
                                                                                  firstName:[TBMemberDataManager sharedInstance].memberDataObject.memberFirstName
                                                                                   lastName:[TBMemberDataManager sharedInstance].memberDataObject.memberLastName
                                                                                      email:[TBMemberDataManager sharedInstance].memberDataObject.memberEmail
                                                                                   username:[TBMemberDataManager sharedInstance].memberDataObject.memberUserName
                                                                                      isTTC:[TBMemberDataManager sharedInstance].memberDataObject.ttcStatus
                                                                        selectedBirthClubId:bClub.forumId
                                                                                  hasAvatar:[[TBMemberDataManager sharedInstance].memberDataObject doesUserHaveAvatar]
                                                                              withAuthToken:[[TBMemberDataManager sharedInstance] authenticationToken]];
    [memberDataUpdatePromise then:^id(id value) {
        return value;
    } error:^id(NSError *error) {
        [[TBAPIHelper sharedInstance] handleApiError:error
                                                from:self];
        return error;
    }];
}

#pragma mark - Collection Delegate Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.bClubListArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TBCommunityBirthClubSelectionCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:TBCommunityBirthClubSelectionCollectionViewCell.defaultReuseIdentifier
                                                                                                      forIndexPath:indexPath];
    TBForum *bClub = self.bClubListArray[indexPath.row];
    
    if ([[TBMemberDataManager sharedInstance].memberDataObject hasBirthClub]) {
        cell.selected = [[TBMemberDataManager sharedInstance].memberDataObject.selectedBirthClubId isEqualToNumber:bClub.forumId];
    } else if ([self.selectedBirthClub isEqualToNumber:bClub.forumId]) {
        cell.selected = YES;
    }
    
    [cell setupWithBirthClubName:bClub.forumName];
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    BOOL hasChangedBClub = NO;
    TBForum *bClub = self.bClubListArray[indexPath.row];
    [self saveUserBirthClubSelectionForBirthClub:bClub];
    if (![self.selectedBirthClub isEqualToNumber:bClub.forumId]) {
        hasChangedBClub = YES;
    }
    self.selectedBirthClub = bClub.forumId;
    [collectionView reloadData];
    [self performSelector:@selector(invokeCommunityNavigationDelegate:) withObject:@(hasChangedBClub) afterDelay:0.2];
}

- (void)invokeCommunityNavigationDelegate:(NSNumber *)hasChangedBClub {
    if ([self.communityNavigationDelegate respondsToSelector:@selector(presentAllForumsViewAndHasBirthClubSelectionChanged:)]) {
        [self.communityNavigationDelegate presentAllForumsViewAndHasBirthClubSelectionChanged:[hasChangedBClub boolValue]];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    TBForum *bClub = [[TBCommunityDataManager sharedInstance] fetchForumsByCategory:kCommunityBirthClubsKey][indexPath.row];
    
    CGSize cellSize = CGSizeZero;
    
    if ([[TBMemberDataManager sharedInstance].memberDataObject hasBirthClub]) {
        cellSize = [[TBMemberDataManager sharedInstance].memberDataObject.selectedBirthClubId
                    isEqualToNumber:bClub.forumId] ? CGSizeMake(120.0f, 120.0f) : CGSizeMake(80.0f, 80.0f);
    } else if ([self.selectedBirthClub isEqualToNumber:bClub.forumId]) {
        cellSize = CGSizeMake(120.0f, 120.0f);
    } else {
        cellSize = CGSizeMake(80.0f, 80.0f);
    }
    return cellSize;
}

#pragma mark - Helper Methods

- (void)scrollToSelectedBirthClub:(NSNumber *)selectedBirthClubId
             orSuggestedBirthClub:(NSNumber *)suggestedBirthClubId
           fromBirthClubForumList:(NSArray *)birthClubForumList {
    
    NSNumber *birthClubIdToScrollTo = nil;
    if (selectedBirthClubId
        && [selectedBirthClubId isKindOfClass:[NSNumber class]]
        && ![selectedBirthClubId isEqualToNumber:@(TBMemberDataModel.kNoSelectedBirthClubNumber)]) {
        birthClubIdToScrollTo = selectedBirthClubId;
    } else if (suggestedBirthClubId) {
        birthClubIdToScrollTo = suggestedBirthClubId;
    }
    
    if (!birthClubIdToScrollTo) return;
    
    NSInteger suggestedBirthClubIndex = -1;
    for (NSInteger i = 0; i < [birthClubForumList count]; i++) {
        if ([((TBForum *)birthClubForumList[i]).forumId isEqualToNumber:birthClubIdToScrollTo]) {
            suggestedBirthClubIndex = i;
        }
    }
    
    if (suggestedBirthClubIndex >= 0) {
        [self.birthClubSelectionView.birthClubSelectionCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:suggestedBirthClubIndex inSection:0]
                                                                             atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                                                                     animated:NO];
    } else {
        // Move to the current month and year
        [self.birthClubSelectionView.birthClubSelectionCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:[self indexForForumDate:[NSDate date]
                                                                                                                                          fromList:birthClubForumList] inSection:0]
                                                                             atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                                                                     animated:NO];
    }
}

- (void)dismissBClubSelectionView:(UITapGestureRecognizer *)gesture {
    if ([self.communityNavigationDelegate respondsToSelector:@selector(presentAllForumsViewAndHasBirthClubSelectionChanged:)]) {
        [self.communityNavigationDelegate presentAllForumsViewAndHasBirthClubSelectionChanged:NO];
    }
}

#pragma mark- Gesture Recognizer Delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return ![touch.view isDescendantOfView:self.birthClubSelectionView.birthClubSelectionCollectionView];
}

#pragma mark- Utility Method

- (NSInteger)indexForForumDate:(NSDate *)forumDate fromList:(NSArray *)bClubList{
    NSInteger index = 0;
    for (NSInteger i = 0; i < [bClubList count]; i++) {
        TBForum *currentForum = ((TBForum *)bClubList[i]);
        
        if ([self areDates:forumDate andDate:currentForum.forumBirthClubDate
      equalForComponentDay:0
                  forMonth:kCFCalendarUnitMonth
                   forYear:kCFCalendarUnitYear]) {
            index = i;
            break;
        }
    }
    return index;
}

- (BOOL)areDates:(NSDate *)date1
         andDate:(NSDate *)date2
equalForComponentDay:(CFCalendarUnit)dayComponent
        forMonth:(CFCalendarUnit)monthComponent
         forYear:(CFCalendarUnit)yearComponent {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSInteger comps = 0;
    
    if (dayComponent == kCFCalendarUnitDay) {
        comps = dayComponent;
    }
    
    if (monthComponent == kCFCalendarUnitMonth) {
        comps = comps | monthComponent;
    }
    
    if (yearComponent == kCFCalendarUnitYear) {
        comps = comps | yearComponent;
    }
    
    NSDateComponents *date1Components = [calendar components:comps
                                                    fromDate: date1];
    NSDateComponents *date2Components = [calendar components:comps
                                                    fromDate: date2];
    
    if ([date1Components day] == [date2Components day]
        && [date1Components month] == [date2Components month]
        && [date1Components year] == [date2Components year]) {
        return YES;
    } else {
        return NO;
    }
}

@end
