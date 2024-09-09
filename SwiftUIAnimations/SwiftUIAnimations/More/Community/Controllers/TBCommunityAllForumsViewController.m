//
//  TBCommunityAllForumsViewController.m
//  TheBump
//
//  Created by Goran Svorcan on 7/17/14.
//  Copyright (c) 2014 xo group. All rights reserved.
//

#import "TBCommunityAllForumsViewController.h"
#import "TBAllForumsTableHeaderView.h"
#import "TBAllForumsIndividualForumTableViewCell.h"
#import "TBCommunityDataManager.h"
#import "TBStaleTimeDataManager.h"
#import "TBAPIHelper.h"
#import "TBAllForumsCategoryTableViewCell.h"
#import "TBForum.h"
#import "TBForumFavorite.h"
#import "TBAllForumsEmptySectionTableViewCell.h"
#import "TBTabBarViewController.h"
#import "TBCommunityAPIConstants.h"
#import "TBCommunityBirthClubSelectionConfirmationView.h"
#import <TheBump-Swift.h>
#import "TBCommunityViewController.h"
#import "TBBirthClubSelectionViewController.h"
#import "TBAPIConstants.h"
#import <FullStory/FullStory.h>

#define kFavoriteButtonSectionOffset 1000

@interface TBCommunityAllForumsViewController ()

@property (nonatomic, strong) NSMutableDictionary *expandedForumCategories;
@property (nonatomic, strong) TBAllForumsHeaderView *forumsHeaderView;
@property (nonatomic, strong) NSLayoutConstraint *forumsTableViewTopConstraint;
@property (nonatomic, strong) NSLayoutConstraint *forumsTableViewHeightConstraint;
@property (nonatomic, strong) UITableView *forumsTableView;

@property (nonatomic, strong) NSLayoutConstraint *webViewLeftConstraint;
@property (nonatomic, strong) TBBrowserViewModel *viewModel;
@property (nonatomic, strong) TBBrowserViewController *forumCookieWebView;
@property (nonatomic, assign) BOOL isShowingWebView;
@property (nonatomic, strong) UIBarButtonItem *backBarButton;
@property (nonatomic, strong) UIBarButtonItem *refreshBarButton;

@property (nonatomic, strong) NSNumber *suggestedBirthClubId;
@property (nonatomic, strong) NSString *suggestedBirthClubName;
@property (nonatomic, strong) NSString *suggestedBirthClubUrl;

@property (nonatomic, strong) TBCommunityBirthClubSelectionConfirmationView *birthClubConfirmationSelectionView;
@property (nonatomic, strong) NSLayoutConstraint *birthClubConfirmationTopConstraint;
@property (nonatomic, assign) NSInteger additionalSectionCount;
@property (nonatomic, assign) NSInteger maxAdditionalSectionValue;

@end

@implementation TBCommunityAllForumsViewController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = UIColor.OffWhite;
    
    _additionalSectionCount = 3;
    _maxAdditionalSectionValue = 2;
    _forumsTableView = [[UITableView alloc] init];
    CGFloat headerHeight = [UIDevice isPad] ? 180 : 120;
    _forumsHeaderView = [[TBAllForumsHeaderView alloc] initWithFrame:CGRectMake(0, 20, UIScreen.mainScreen.bounds.size.width, headerHeight)];

    _forumsTableView.contentInset = UIEdgeInsetsMake(0, 0, 16, 0);
    _forumsTableView.tableHeaderView = _forumsHeaderView;
    _forumsTableView.translatesAutoresizingMaskIntoConstraints = NO;
    _forumsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _forumsTableView.showsVerticalScrollIndicator = NO;
    [_forumsTableView registerClass:[TBAllForumsTableHeaderView class]
 forHeaderFooterViewReuseIdentifier:TBAllForumsTableHeaderView.defaultReuseIdentifier];
    [_forumsTableView registerClass:[TBAllForumsCategoryTableViewCell class]
             forCellReuseIdentifier:TBAllForumsCategoryTableViewCell.defaultReuseIdentifier];
    [_forumsTableView registerClass:[TBAllForumsIndividualForumTableViewCell class]
             forCellReuseIdentifier:TBAllForumsIndividualForumTableViewCell.defaultReuseIdentifier];
    [_forumsTableView registerClass:[TBAllForumsEmptySectionTableViewCell class]
             forCellReuseIdentifier:TBAllForumsEmptySectionTableViewCell.defaultReuseIdentifier];
    _forumsTableView.dataSource = self;
    _forumsTableView.delegate = self;
    [self.view addSubview:_forumsTableView];

    _viewModel = [[TBBrowserViewModel alloc] initWithTitle:@"" url: nil lifeCycleHandlerType: LifeCycleHandlerTypeDefaultType routerHandlerType: RouterHandlerTypeDefaultType customNavBarColor: self.navigationController.navigationBar.barTintColor shouldOpenNativeArticle: YES shouldScrollToTopAndRefresh: NO shouldNotifyWebViewIsMovingFromParent: NO goBackAsWebView: NO goBackByDeleteAccount: NO maskNavigationBar: NO shouldSetHTTPHeaderField: YES shouldControlBarHidden: NO isCommunity: YES];
    _forumCookieWebView = [[TBBrowserViewController alloc] initWithViewModel: _viewModel];
    _forumCookieWebView.view.translatesAutoresizingMaskIntoConstraints = NO;
    _forumCookieWebView.view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_forumCookieWebView.view];
    [_forumCookieWebView didMoveToParentViewController:self];

    _birthClubConfirmationSelectionView = [[TBCommunityBirthClubSelectionConfirmationView alloc] init];
    _birthClubConfirmationSelectionView.translatesAutoresizingMaskIntoConstraints = NO;
    _birthClubConfirmationSelectionView.alpha = 0;
    [self.view addSubview:_birthClubConfirmationSelectionView];
    
    [self setupCommunityAllForumsViewConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDisableLeftSwipeNotification object:nil];
    
    [self fetchAllForums];
    [self fetchExistingFavoriteForums];
    [self fetchBirthClubs];
    [self.forumsTableView reloadData];
    self.parentViewController.navigationItem.leftBarButtonItem = self.backBarButton;
    self.parentViewController.navigationItem.rightBarButtonItem = self.isShowingWebView ? self.refreshBarButton : nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kEnableLeftSwipeNotification object:nil];
    
    if ([[TBMemberDataManager sharedInstance].memberDataObject hasBirthClub]) {
        self.birthClubConfirmationTopConstraint.constant = -self.birthClubConfirmationSelectionView.minHeight;
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
        
    } else {
        self.birthClubConfirmationTopConstraint.constant = 0.0f;
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    }
}

- (void)setupCommunityAllForumsViewConstraints {
    NSDictionary *viewsDictionary = @{@"_forumsTableView": _forumsTableView,
                                      @"forumCookieWebView": self.forumCookieWebView.view,
                                      @"_birthClubConfirmationSelectionView": _birthClubConfirmationSelectionView};
    
    self.forumsTableViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.forumsTableView
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.view
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1.0
                                                                      constant:0.0];
    
    [self.view addConstraint:self.forumsTableViewTopConstraint];
    
    self.forumsTableViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.forumsTableView
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.view
                                                                        attribute:NSLayoutAttributeHeight
                                                                       multiplier:1.0
                                                                         constant:0.0];

    [self.view addConstraint:self.forumsTableViewHeightConstraint];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-25-[_forumsTableView]-25-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.forumCookieWebView.view
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.forumCookieWebView.view
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.forumCookieWebView.view
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    
    self.webViewLeftConstraint = [NSLayoutConstraint constraintWithItem:self.forumCookieWebView.view
                                                              attribute:NSLayoutAttributeLeft
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeLeft
                                                             multiplier:1.0f
                                                               constant:CGRectGetWidth([[UIScreen mainScreen] bounds])];
    
    [self.view addConstraint:self.webViewLeftConstraint];
    
    // Birth Club Selection Confirmation View Constraints
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_birthClubConfirmationSelectionView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_birthClubConfirmationSelectionView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.0f
                                                           constant:self.birthClubConfirmationSelectionView.minHeight]];
    
    self.birthClubConfirmationTopConstraint = [NSLayoutConstraint constraintWithItem:_birthClubConfirmationSelectionView
                                                                           attribute:NSLayoutAttributeTop
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.view
                                                                           attribute:NSLayoutAttributeTop
                                                                          multiplier:1.0f
                                                                            constant:0.0f];
    
    [self.view addConstraint:self.birthClubConfirmationTopConstraint];
}

- (void)swapToSelectableBirthClub {
    if ([self.communityNavigationDelegate respondsToSelector:@selector(presentBirthClubSelectionViewWithList:andSelectedBirthClubId:)]) {
        NSNumber *birthClubId;
        if ([[TBMemberDataManager sharedInstance].memberDataObject hasBirthClub]) {
            birthClubId = [TBMemberDataManager sharedInstance].memberDataObject.selectedBirthClubId;
        } else {
            birthClubId = self.suggestedBirthClubId;
        }
        [self.communityNavigationDelegate presentBirthClubSelectionViewWithList:[[TBCommunityDataManager sharedInstance] fetchForumsByCategory:kCommunityBirthClubsKey]
                                                         andSelectedBirthClubId:birthClubId];
    }
}

- (void)reloadAllForumsTable {
    [self.forumsTableView reloadData];
}

- (void)presentBirthClubSelectionConfirmation {
    [self.view layoutSubviews];
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.birthClubConfirmationSelectionView.alpha = 1.0;
                         self.birthClubConfirmationTopConstraint.constant = 0.0f;
                         self.forumsTableViewTopConstraint.constant = self.birthClubConfirmationSelectionView.minHeight;
                         self.forumsTableViewHeightConstraint.constant = -self.birthClubConfirmationSelectionView.minHeight;
                         [self.view setNeedsLayout];
                         [self.view layoutIfNeeded];
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.5
                                               delay:1.5
                                             options:0
                                          animations:^{
                                              self.birthClubConfirmationTopConstraint.constant = -self.birthClubConfirmationSelectionView.minHeight;
                                              self.forumsTableViewTopConstraint.constant = 0.0f;
                                              self.forumsTableViewHeightConstraint.constant = 0.0f;
                                              [self.view setNeedsLayout];
                                              [self.view layoutIfNeeded];
                                          } completion:nil];
                     }];
}

#pragma mark - Table View Data Source and Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _additionalSectionCount + [[TBCommunityDataManager sharedInstance].forumCategoryList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return MAX(1, [[[TBCommunityDataManager sharedInstance] fetchUserForumFavorites] count]);
    } else if (section == 1) {
        return 1;
    } else if (section == [tableView numberOfSections] - 1) {
        return 1;
    } else if (section - _maxAdditionalSectionValue < [[TBCommunityDataManager sharedInstance].forumCategoryList count]) {
        NSString *categoryName = [TBCommunityDataManager sharedInstance].forumCategoryList[section - _maxAdditionalSectionValue];

        if (self.expandedForumCategories[categoryName]) {
            return [[[TBCommunityDataManager sharedInstance] fetchForumsByCategory:categoryName] count] + 1;
        }
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if ([[[TBCommunityDataManager sharedInstance] fetchUserForumFavorites] count] == 0) {
            TBAllForumsEmptySectionTableViewCell *emptySectionCell = [tableView dequeueReusableCellWithIdentifier:TBAllForumsEmptySectionTableViewCell.defaultReuseIdentifier
                                                                                                     forIndexPath:indexPath];
            
            [emptySectionCell setupEmtpySectionCellWithImage:[UIImage imageNamed:@"CommunityStar normal"] andDescriptionText:@"Tap the star next to any forum name to save it here!"];
            
            return emptySectionCell;
        } else {
            TBAllForumsIndividualForumTableViewCell *favoriteForumCell = [tableView dequeueReusableCellWithIdentifier:TBAllForumsIndividualForumTableViewCell.defaultReuseIdentifier
                                                                                                         forIndexPath:indexPath];
            
            TBForumFavorite *favoriteForum = [[TBCommunityDataManager sharedInstance] fetchUserForumFavorites][indexPath.row];
            [favoriteForumCell setupCellWithName:favoriteForum.communityForumName
                              favoriteVisibility:YES
                               andFavoriteStatus:YES];
            [favoriteForumCell.favoriteButton addTarget:self action:@selector(favoriteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            favoriteForumCell.favoriteButton.tag = (indexPath.section * kFavoriteButtonSectionOffset) + indexPath.row;
            
            [favoriteForumCell setNeedsUpdateConstraints];
            [FS mask: favoriteForumCell.contentView];
            
            return favoriteForumCell;
        }
    } else if (indexPath.section == 1) {
        if ([[TBMemberDataManager sharedInstance].memberDataObject hasBirthClub]) {
            TBAllForumsIndividualForumTableViewCell *birthClubCell = [tableView dequeueReusableCellWithIdentifier:TBAllForumsIndividualForumTableViewCell.defaultReuseIdentifier
                                                                                                     forIndexPath:indexPath];
            
            [birthClubCell setupCellWithName:[TBMemberDataManager sharedInstance].memberDataObject.selectedBirthClubName
                          favoriteVisibility:NO
                           andFavoriteStatus:[[TBCommunityDataManager sharedInstance] isForumIdFavorited:[TBMemberDataManager sharedInstance].memberDataObject.selectedBirthClubId]];
            
            [birthClubCell.favoriteButton addTarget:self action:@selector(favoriteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            birthClubCell.favoriteButton.tag = (indexPath.section * kFavoriteButtonSectionOffset) + indexPath.row;
            
            [birthClubCell setNeedsUpdateConstraints];
            [FS mask: birthClubCell.contentView];
            return birthClubCell;
        } else {
            if (self.suggestedBirthClubId) {
                TBAllForumsIndividualForumTableViewCell *birthClubCell = [tableView dequeueReusableCellWithIdentifier:TBAllForumsIndividualForumTableViewCell.defaultReuseIdentifier
                                                                                                         forIndexPath:indexPath];
                
                [birthClubCell setupCellWithName:self.suggestedBirthClubName
                              favoriteVisibility:NO
                               andFavoriteStatus:[[TBCommunityDataManager sharedInstance]
                                                  isForumIdFavorited:self.suggestedBirthClubId]];
                
                [birthClubCell.favoriteButton addTarget:self action:@selector(favoriteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                birthClubCell.favoriteButton.tag = (indexPath.section * kFavoriteButtonSectionOffset) + indexPath.row;
                
                [birthClubCell setNeedsUpdateConstraints];
                
                return birthClubCell;
            } else {
                TBAllForumsEmptySectionTableViewCell *emptySectionCell = [tableView dequeueReusableCellWithIdentifier:TBAllForumsEmptySectionTableViewCell.defaultReuseIdentifier
                                                                                                         forIndexPath:indexPath];
                [emptySectionCell setupEmtpySectionCellWithImage:nil andDescriptionText:@"Tap the change button above to select your birth club!"];
                return emptySectionCell;
            }
        }
    } else if (indexPath.section == [tableView numberOfSections] - 1) {
        TBAllForumsIndividualForumTableViewCell *groupsCell = [tableView dequeueReusableCellWithIdentifier:TBAllForumsIndividualForumTableViewCell.defaultReuseIdentifier
                                                                                              forIndexPath:indexPath];
        
        [groupsCell setupCellWithName:@"Groups"
                   favoriteVisibility:NO
                    andFavoriteStatus:NO];
        
        [groupsCell setNeedsUpdateConstraints];
        
        return groupsCell;
    } else if (indexPath.section > 1) {
        NSString *categoryName = [TBCommunityDataManager sharedInstance].forumCategoryList[indexPath.section - _maxAdditionalSectionValue];
        
        if (indexPath.row == 0) {
            TBAllForumsCategoryTableViewCell *categoryCell = [tableView dequeueReusableCellWithIdentifier:TBAllForumsCategoryTableViewCell.defaultReuseIdentifier
                                                                                             forIndexPath:indexPath];
            
            [categoryCell setupCellWithName:categoryName];
            [categoryCell setExpanded:[self.expandedForumCategories[categoryName] boolValue] withAnimation:NO];
            
            return categoryCell;
        } else {
            TBAllForumsIndividualForumTableViewCell *forumCell = [tableView dequeueReusableCellWithIdentifier:TBAllForumsIndividualForumTableViewCell.defaultReuseIdentifier
                                                                                                 forIndexPath:indexPath];
            
            TBForum *currentForum = [[TBCommunityDataManager sharedInstance] fetchForumsByCategory:categoryName][indexPath.row - 1];
            [forumCell setupCellWithName:currentForum.forumName
                      favoriteVisibility:YES
                       andFavoriteStatus:[[TBCommunityDataManager sharedInstance] isForumIdFavorited:currentForum.forumId]];
            [forumCell.favoriteButton addTarget:self action:@selector(favoriteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            forumCell.favoriteButton.tag = (indexPath.section * kFavoriteButtonSectionOffset) + indexPath.row;
            
            [forumCell setNeedsUpdateConstraints];
            
            return forumCell;
        }
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row < [[[TBCommunityDataManager sharedInstance] fetchUserForumFavorites] count]) {
        TBForumFavorite *currentFavoriteForum = [[TBCommunityDataManager sharedInstance] fetchUserForumFavorites][indexPath.row];
        
        [TBAnalyticsManager logEventNamed:kAnalyticsEventMenuInteraction
                           withProperties:@{kAnalyticsKeyPlacement: @"nav",
                                            kAnalyticsKeyHeader: @"Community",
                                            kAnalyticsKeySelection: currentFavoriteForum.communityForumName}];
        
        [TBAnalyticsManager logScreenNamed:currentFavoriteForum.communityForumName
                            withProperties:nil];

        [self showWebView:YES withName:@"COMMUNITY" andUrlString:currentFavoriteForum.communityForumUrl];

    } else if (indexPath.section == 1) {
        if ([[TBMemberDataManager sharedInstance].memberDataObject hasBirthClub]) {
            [TBAnalyticsManager logEventNamed:kAnalyticsEventMenuInteraction
                               withProperties:@{kAnalyticsKeyPlacement: @"nav",
                                                kAnalyticsKeyHeader: @"Community",
                                                kAnalyticsKeySelection: [TBMemberDataManager sharedInstance].memberDataObject.selectedBirthClubName}];
            
            [TBAnalyticsManager logScreenNamed:[TBMemberDataManager sharedInstance].memberDataObject.selectedBirthClubName
                                withProperties:nil];

            [self showWebView:YES withName:@"COMMUNITY"
                 andUrlString:[TBMemberDataManager sharedInstance].memberDataObject.selectedBirthClubUrl];
        } else {
            [TBAnalyticsManager logEventNamed:kAnalyticsEventMenuInteraction
                               withProperties:@{kAnalyticsKeyPlacement: @"nav",
                                                kAnalyticsKeyHeader: @"Community",
                                                kAnalyticsKeySelection: self.suggestedBirthClubName == nil ? @"" : self.suggestedBirthClubName}];
            
            [TBAnalyticsManager logScreenNamed:self.suggestedBirthClubName
                                withProperties:nil];
            [self swapToSelectableBirthClub];
        }
    } else if (indexPath.section == [tableView numberOfSections] - 1) {
        [TBAnalyticsManager logEventNamed:kAnalyticsEventMenuInteraction
                           withProperties:@{kAnalyticsKeyPlacement: @"nav",
                                            kAnalyticsKeyHeader: @"Community",
                                            kAnalyticsKeySelection: @"Groups"}];
        
        [TBAnalyticsManager logScreenNamed:@"Groups"
                            withProperties:nil];

        [self showWebView:YES withName:@"COMMUNITY" andUrlString:kCommunityGroups];
    } else if (indexPath.section > 1) {
        NSString *categoryName = [TBCommunityDataManager sharedInstance].forumCategoryList[indexPath.section - _maxAdditionalSectionValue];
        
        if (indexPath.row == 0) {
            [TBAnalyticsManager logEventNamed:kAnalyticsEventMenuInteraction
                               withProperties:@{kAnalyticsKeyPlacement: @"nav",
                                                kAnalyticsKeyHeader: @"Community",
                                                kAnalyticsKeySelection: categoryName}];
            
            [TBAnalyticsManager logScreenNamed:categoryName
                                withProperties:nil];
            
            if (self.expandedForumCategories[categoryName]) {
                [self.expandedForumCategories removeObjectForKey:categoryName];
                [((TBAllForumsCategoryTableViewCell *)[tableView cellForRowAtIndexPath:indexPath]) setExpanded:NO withAnimation:YES];
            } else {
                self.expandedForumCategories[categoryName] = @1;
                [((TBAllForumsCategoryTableViewCell *)[tableView cellForRowAtIndexPath:indexPath]) setExpanded:YES withAnimation:YES];
            }
            
            [self.forumsTableView beginUpdates];
            [self.forumsTableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.forumsTableView endUpdates];
        } else {
            TBForum *currentForum = [[TBCommunityDataManager sharedInstance] fetchForumsByCategory:categoryName][indexPath.row - 1];
            [self showWebView:YES withName:@"COMMUNITY" andUrlString:currentForum.forumUrl];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section < 3) {
        return 60.0f;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    TBAllForumsTableHeaderView *tableHeader = [tableView dequeueReusableHeaderFooterViewWithIdentifier:TBAllForumsTableHeaderView.defaultReuseIdentifier];
    
    switch (section) {
        case 0:
            [tableHeader setupHeaderWithTitle:@"MY FAVORITE FORUMS"
                               andButtonTitle:@""];
            break;
            
        case 1:
            if ([[TBMemberDataManager sharedInstance] isTTCSelected]) {
                [tableHeader setupHeaderWithTitle:@"GETTING PREGNANT"
                                   andButtonTitle:@""];
            } else {
                [tableHeader setupHeaderWithTitle:@"MY BIRTH CLUB"
                                   andButtonTitle:@"change"];
                [tableHeader.headerButton addTarget:self
                                             action:@selector(swapToSelectableBirthClub)
                                   forControlEvents:UIControlEventTouchUpInside];
            }
            break;
            
        case 2:
            [tableHeader setupHeaderWithTitle:@"ALL FORUMS"
                               andButtonTitle:@""];
            break;
            
        default:
            [tableHeader setupHeaderWithTitle:@""
                               andButtonTitle:@""];
            break;
    }
    
    
    return tableHeader;
}

- (void)favoriteButtonPressed:(UIButton *)favoriteButton {
    NSInteger favoriteSection = favoriteButton.tag / kFavoriteButtonSectionOffset;
    NSInteger favoriteRow = favoriteButton.tag % kFavoriteButtonSectionOffset;
    
    NSNumber *favoriteId = @0;
    NSString *forumName = @"";
    
    if (favoriteSection == 0) {
        TBForumFavorite *favoriteForum = [[TBCommunityDataManager sharedInstance] fetchUserForumFavorites][favoriteRow];
        favoriteId = favoriteForum.forumId;
        forumName = favoriteForum.communityForumName;
    } else if (favoriteSection == 1) {
        NSNumber *birthClubId = [TBMemberDataManager sharedInstance].memberDataObject.selectedBirthClubId;
        favoriteId = favoriteButton.selected ? [[TBCommunityDataManager sharedInstance] forumFavoriteIdFromForumId:birthClubId] : birthClubId;
        forumName = [TBMemberDataManager sharedInstance].memberDataObject.selectedBirthClubName;
    } else {
        NSString *categoryName = [TBCommunityDataManager sharedInstance].forumCategoryList[favoriteSection - 2];
        TBForum *tappedForum = [[TBCommunityDataManager sharedInstance] fetchForumsByCategory:categoryName][favoriteRow - 1];
        favoriteId = favoriteButton.selected ? [[TBCommunityDataManager sharedInstance] forumFavoriteIdFromForumId:tappedForum.forumId] : tappedForum.forumId;
        forumName = tappedForum.forumName;
    }
    
    if ([favoriteId intValue] <= 0) return;
    
    favoriteButton.enabled = NO;
    
    KSPromise *favoriteModificationPromise = nil;
    if (favoriteButton.selected) {
        // Analytics
        [TBAnalyticsManager logEventNamed:kAnalyticsEventForumBoardUnfavorited withProperties:@{kAnalyticsKeyBoardName: forumName}];
        
        favoriteModificationPromise = [[TBAPIHelper sharedInstance] removeCommunityFavoriteWithCommunityForumId:favoriteId
                                                                                                   andAuthToken:[[TBMemberDataManager sharedInstance] authenticationToken]];
    } else {
        // Analytics
        [TBAnalyticsManager logEventNamed:kAnalyticsEventForumBoardFavorited withProperties:@{kAnalyticsKeyBoardName: forumName}];
        
        favoriteModificationPromise = [[TBAPIHelper sharedInstance] addCommunityFavoriteWithCommunityForumId:favoriteId
                                                                                                andAuthToken:[[TBMemberDataManager sharedInstance] authenticationToken]];
    }
    
    [favoriteModificationPromise then:^id(id value) {
        favoriteButton.enabled = YES;
        [self.forumsTableView reloadData];
        
        return value;
    } error:^id(NSError *error) {
        [[TBAPIHelper sharedInstance] handleApiError:error
                                                from:self];
        favoriteButton.enabled = YES;
        return error;
    }];
}

#pragma mark - Web View Navigation Methods

- (void)showWebView:(BOOL)show withName:(NSString *)name andUrlString:(NSString *)urlString {
    if (show) {
        [self.forumCookieWebView resetUrlWith: [NSURL URLWithString: urlString]];
        [self.forumCookieWebView loadUrlWith: [NSURL URLWithString: urlString]];
    }

    [UIView animateWithDuration:0.3
                     animations:^{
                         self.parentViewController.navigationItem.title = show ? [name capitalizedWithoutPrepositionObjc] : [@"COMMUNITY" capitalizedWithoutPrepositionObjc];
                         self.webViewLeftConstraint.constant = show ? 0.0f : CGRectGetWidth([[UIScreen mainScreen] bounds]);
                         [self.view setNeedsLayout];
                         [self.view layoutIfNeeded];
                     } completion:^(BOOL finished) {
                         self.isShowingWebView = show;
                         self.parentViewController.navigationItem.rightBarButtonItem = show ? self.refreshBarButton : nil;
                     }];
}

- (void)backBarButtonPressed:(id)sender {
    if (!self.isShowingWebView) {
        TBCommunityViewController *communityViewController = (TBCommunityViewController *)self.communityNavigationDelegate;
        if ([communityViewController.childViewControllers.firstObject isKindOfClass:TBBirthClubSelectionViewController.self]
            && [self.communityNavigationDelegate respondsToSelector:@selector(presentAllForumsViewAndHasBirthClubSelectionChanged:)]) {
            [self.communityNavigationDelegate presentAllForumsViewAndHasBirthClubSelectionChanged:false];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
        return;
    }

    if (self.forumCookieWebView.webContentView.webView.canGoBack) {
        [self.forumCookieWebView.webContentView.webView goBack];
    } else {
        [self showWebView:NO withName:@"" andUrlString:@""];
    }
}

- (void)refreshButtonPressed {
    if (!self.isShowingWebView) return;
    [self.forumCookieWebView.webContentView.webView reload];
}

#pragma mark - External Controls

- (void)navigateToForumURLString:(NSString *)url withName:(NSString *)name {
    if (self.isShowingWebView) {
        [self showWebView:NO withName:@"" andUrlString:@""];
    }
    
    [self showWebView:YES withName:name andUrlString:url];
}

#pragma mark - Properties

- (NSMutableDictionary *)expandedForumCategories {
    if (!_expandedForumCategories) {
        _expandedForumCategories = [NSMutableDictionary dictionary];
    }
    return _expandedForumCategories;
}

- (UIBarButtonItem *)backBarButton {
    if (!_backBarButton) {
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 44.0f, 44.0f)];
        [backButton addTarget:self action:@selector(backBarButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [backButton setImage:NavigationBarStyle.backButtonImage forState:UIControlStateNormal];
        backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -30.0, 0, 0);
        _backBarButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    }
    return _backBarButton;
}

- (UIBarButtonItem *)refreshBarButton {
    if (!_refreshBarButton) {
        UIButton *refreshButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 50.0f, 50.0f)];
        [refreshButton setImage:[UIImage imageNamed:@"AppIcon_RefreshArrow"] forState:UIControlStateNormal];
        [refreshButton sizeToFit];
        [refreshButton addTarget:self action:@selector(refreshButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        _refreshBarButton = [[UIBarButtonItem alloc] initWithCustomView:refreshButton];
    }
    return _refreshBarButton;
}

#pragma mark- Utility methods

- (void)fetchAllForums {
    if ([[TBCommunityDataManager sharedInstance].forumCategoryList count] == 0
        || [TBStaleTimeDataManager isAllForumsListStale]) {
        [[[TBAPIHelper sharedInstance] fetchAllForums] then:^id(NSDictionary *value) {
            [self.forumsTableView reloadData];
            
            return value;
        } error:^id(NSError *error) {
            [[TBAPIHelper sharedInstance] handleApiError:error
                                                    from:self];
            return error;
        }];
    }
}

- (void)fetchExistingFavoriteForums {
    [[TBCommunityDataManager sharedInstance] fetchUserForumFavorites];
    
    if ([[TBCommunityDataManager sharedInstance] isFavoritesDataStoredStale]
        || [TBStaleTimeDataManager isUserForumFavoritesStale]) {
        [[[TBAPIHelper sharedInstance] fetchAllFavoritesWithAuthToken:[[TBMemberDataManager sharedInstance] authenticationToken]] then:^id(NSDictionary *value) {
            [self.forumsTableView reloadData];
            
            return value;
        } error:^id(NSError *error) {
            [[TBAPIHelper sharedInstance] handleApiError:error
                                                    from:self];
            return error;
        }];
    }
}

- (void)fetchBirthClubs {
    if ([[[TBCommunityDataManager sharedInstance] fetchForumsByCategory:kCommunityBirthClubsKey] count] == 0
        || [TBStaleTimeDataManager isBirthClubListStale]) {
        [[[TBAPIHelper sharedInstance] fetchBirthClubs] then:^id(NSDictionary *value) {
            [self generateDefaultBirthClubIdForDueDate:[[TBMemberDataManager sharedInstance].memberDataObject eventDate]
                                fromBirthClubForumList:[[TBCommunityDataManager sharedInstance] fetchForumsByCategory:kCommunityBirthClubsKey]];
            
            [self.forumsTableView reloadData];
            
            return value;
        } error:^id(NSError *error) {
            [[TBAPIHelper sharedInstance] handleApiError:error
                                                    from:self];
            return error;
        }];
    } else {
        [self generateDefaultBirthClubIdForDueDate:[[TBMemberDataManager sharedInstance].memberDataObject eventDate]
                            fromBirthClubForumList:[[TBCommunityDataManager sharedInstance] fetchForumsByCategory:kCommunityBirthClubsKey]];
        
        [self.forumsTableView reloadData];
    }
}

- (void)generateDefaultBirthClubIdForDueDate:(NSDate *)dueDate
                      fromBirthClubForumList:(NSArray *)birthClubForumList {
    if ([[TBMemberDataManager sharedInstance] isTTCSelected]
        || [[TBMemberDataManager sharedInstance].memberDataObject isUserNoStatus]) {
        self.suggestedBirthClubId = nil;
        self.suggestedBirthClubName = nil;
        self.suggestedBirthClubUrl = nil;
        return;
    }
    
    if (self.suggestedBirthClubId) {
        return;
    }
    
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSDateComponents *dueDateComponents = [currentCalendar components:NSCalendarUnitYear | NSCalendarUnitMonth
                                                             fromDate:dueDate];
    NSUInteger dueDateMonth = [dueDateComponents month];
    NSUInteger dueDateYear = [dueDateComponents year];
    
    NSDateComponents *forumDateComponents = nil;
    
    for (TBForum *birthClubForum in birthClubForumList) {
        forumDateComponents = [currentCalendar components:NSCalendarUnitYear | NSCalendarUnitMonth
                                                 fromDate:[birthClubForum.forumBirthClubDate
                                                           dateByAddingTimeInterval:86400]];
        if ([forumDateComponents year] == dueDateYear) {
            if ([forumDateComponents month] == dueDateMonth) {
                self.suggestedBirthClubId = birthClubForum.forumId;
                self.suggestedBirthClubName = birthClubForum.forumName;
                self.suggestedBirthClubUrl = birthClubForum.forumUrl;
                break;
            }
        }
    }
}

@end
