#import "TBCommunityBirthClubSelectionCollectionViewCell.h"

@interface TBCommunityBirthClubSelectionCollectionViewCell ()

@property (nonatomic, strong) UIView *backgroundCircle;
@property (nonatomic, strong) UILabel *birthClubLabel;
@property (nonatomic, strong) NSMutableString *birthClubMonth;
@property (nonatomic, strong) NSMutableString *birthClubYear;

@end

@implementation TBCommunityBirthClubSelectionCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _birthClubMonth = [NSMutableString string];
        _birthClubYear = [NSMutableString string];
        
        _backgroundCircle = [[UIView alloc] init];
        _backgroundCircle.translatesAutoresizingMaskIntoConstraints = NO;
        _backgroundCircle.backgroundColor = [UIColor tb_alertsAndTimestamps];
        [self.contentView addSubview:_backgroundCircle];
        
        _birthClubLabel = [[UILabel alloc] init];
        _birthClubLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _birthClubLabel.backgroundColor = [UIColor clearColor];
        _birthClubLabel.numberOfLines = 0;
        _birthClubLabel.textColor = [UIColor whiteColor];
        _birthClubLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_birthClubLabel];
        
        [self setupBirthClubSelectionCellConstraints];
    }
    return self;
}

- (void)setupWithBirthClubName:(NSString *)birthClubName {
    NSArray *birthClubNameComponents = [birthClubName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    self.birthClubMonth = [NSMutableString string];
    self.birthClubYear = [NSMutableString string];
    
    if ([birthClubNameComponents count] > 0) {
        NSString *monthString = birthClubNameComponents[0];
        if ([monthString length] > 3) {
            monthString = [monthString substringToIndex:3];
            [self.birthClubMonth appendString:[monthString uppercaseString]];
        } else {
            [self.birthClubMonth appendString:monthString];
        }
    }

    if ([birthClubNameComponents count] > 1) {
        [self.birthClubMonth appendString:@"\n"];
        [self.birthClubYear appendString:birthClubNameComponents[1]];
    }

    self.birthClubLabel.attributedText = [self labelStringForSelectedState:self.selected];
}

- (NSMutableAttributedString *)labelStringForSelectedState:(BOOL)selected {
    NSString *birthClubString = [NSString stringWithFormat:@"%@%@", self.birthClubMonth, self.birthClubYear];
    
    NSMutableAttributedString *birthClubAttributedString;
    
    if (selected) {
        birthClubAttributedString = [NSMutableAttributedString tb_header2WithText:birthClubString
                                                                     andAlignment:NSTextAlignmentCenter];
    } else {
        birthClubAttributedString = [NSMutableAttributedString tb_header4WithText:birthClubString
                                                                     andAlignment:NSTextAlignmentCenter];
    }

    [birthClubAttributedString addAttribute:NSForegroundColorAttributeName
                                      value:[UIColor whiteColor]
                                      range:NSMakeRange(0, [birthClubAttributedString length])];
    
    return birthClubAttributedString;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    self.birthClubLabel.attributedText = [self labelStringForSelectedState:self.selected];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.backgroundCircle.layer.cornerRadius = CGRectGetWidth(self.frame) / 2.0f;
}

- (void)setupBirthClubSelectionCellConstraints {
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_backgroundCircle, _birthClubLabel);

    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_backgroundCircle]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDictionary]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_backgroundCircle]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDictionary]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_birthClubLabel
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1.0f
                                                                  constant:0.0f]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_birthClubLabel]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDictionary]];
}

@end
