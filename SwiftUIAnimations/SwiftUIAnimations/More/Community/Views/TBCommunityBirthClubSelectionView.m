#import "TBCommunityBirthClubSelectionView.h"
#import <TheBump-Swift.h>

@interface TBCommunityBirthClubSelectionView ()

@property (nonatomic, strong) UILabel *topSelectionLabel;
@property (nonatomic, strong) UILabel *bottomSelectionLabel;

@end

@implementation TBCommunityBirthClubSelectionView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = UIColor.OffWhite;
        
        _topSelectionLabel = [[UILabel alloc] init];
        _topSelectionLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _topSelectionLabel.numberOfLines = 0;
        _topSelectionLabel.attributedText = [NSMutableAttributedString tb_tbVoiceWithText:@"Please choose your birth month:"
                                                                             andAlignment:NSTextAlignmentCenter];
        [self addSubview:_topSelectionLabel];
        
        UICollectionViewFlowLayout *birthClubCollectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
        birthClubCollectionViewLayout.minimumInteritemSpacing = 10.0f;
        birthClubCollectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _birthClubSelectionCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:birthClubCollectionViewLayout];
        _birthClubSelectionCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
        _birthClubSelectionCollectionView.backgroundColor = UIColor.OffWhite;
        _birthClubSelectionCollectionView.layer.masksToBounds = NO;
        _birthClubSelectionCollectionView.contentInset = UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f);
        _birthClubSelectionCollectionView.showsHorizontalScrollIndicator = NO;
        [self addSubview:_birthClubSelectionCollectionView];
        
        _bottomSelectionLabel = [[UILabel alloc] init];
        _bottomSelectionLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _bottomSelectionLabel.numberOfLines = 0;
        _bottomSelectionLabel.attributedText = [NSMutableAttributedString tb_tbVoiceWithText:@"We'll show you this forum first.\n(you can change it later)"
                                                                                andAlignment:NSTextAlignmentCenter];
        [self addSubview:_bottomSelectionLabel];
        
        [self communityBirthClubSelectionConstraints];
    }
    return self;
}

- (void)communityBirthClubSelectionConstraints {
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_topSelectionLabel, _birthClubSelectionCollectionView, _bottomSelectionLabel);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_topSelectionLabel]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:viewsDictionary]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_birthClubSelectionCollectionView]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:viewsDictionary]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_bottomSelectionLabel]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:viewsDictionary]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_birthClubSelectionCollectionView
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0f
                                                      constant:0.0f]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_topSelectionLabel]-25-[_birthClubSelectionCollectionView(==90)]-25-[_bottomSelectionLabel]"
                                                                 options:NSLayoutFormatAlignAllCenterX
                                                                 metrics:nil
                                                                   views:viewsDictionary]];
}

@end
