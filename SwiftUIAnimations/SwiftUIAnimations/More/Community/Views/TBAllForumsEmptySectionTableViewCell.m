#import "TBAllForumsEmptySectionTableViewCell.h"
#import <TheBump-Swift.h>

@interface TBAllForumsEmptySectionTableViewCell ()

@property (nonatomic, strong) UIImageView *emptySectionImage;
@property (nonatomic, strong) UILabel *emptySectionLabel;

@end

@implementation TBAllForumsEmptySectionTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = UIColor.OffWhite;

        _emptySectionImage = [[UIImageView alloc] init];
        _emptySectionImage.translatesAutoresizingMaskIntoConstraints = NO;
        _emptySectionImage.tintColor = [UIColor tb_lines];
        _emptySectionImage.contentMode = UIViewContentModeCenter;
        [self.contentView addSubview:_emptySectionImage];
        
        _emptySectionLabel = [[UILabel alloc] init];
        _emptySectionLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _emptySectionLabel.numberOfLines = 0;
        [self.contentView addSubview:_emptySectionLabel];
        
        [self setupAllForumsEmptySectionCellConstraints];
    }
    return self;
}

- (void)setupEmtpySectionCellWithImage:(UIImage *)image
                    andDescriptionText:(NSString *)descriptionText {
    self.emptySectionImage.image = image;
    
    self.emptySectionLabel.attributedText = [NSMutableAttributedString tb_tbVoiceWithText:descriptionText
                                                                             andAlignment:NSTextAlignmentCenter];
}

- (void)setupAllForumsEmptySectionCellConstraints {
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_emptySectionImage, _emptySectionLabel);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_emptySectionImage]-(>=0)-[_emptySectionLabel]-10-|"
                                                                             options:NSLayoutFormatAlignAllCenterX
                                                                             metrics:nil
                                                                               views:viewsDictionary]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-25-[_emptySectionLabel]-25-|"
                                                                             options:NSLayoutFormatAlignAllCenterX
                                                                             metrics:nil
                                                                               views:viewsDictionary]];
}

@end
