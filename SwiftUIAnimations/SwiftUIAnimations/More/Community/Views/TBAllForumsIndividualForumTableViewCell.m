#import "TBAllForumsIndividualForumTableViewCell.h"
#import "UIImage+DTFoundation.h"
#import <TheBump-Swift.h>

@implementation TBAllForumsIndividualForumTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = UIColor.OffWhite;

        _favoriteButton = [[UIButton alloc] init];
        _favoriteButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_favoriteButton setImage:[UIImage starWithColor:UIColor.DarkGray500] forState:UIControlStateNormal];
        [_favoriteButton setImage:[UIImage starWithColor:UIColor.Teal] forState:UIControlStateSelected];
        [self.contentView addSubview:_favoriteButton];
        
        _forumTitleLabel = [[UILabel alloc] init];
        _forumTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _forumTitleLabel.font = UIFont.mulishBody1;
        _forumTitleLabel.textColor = [UIColor tb_primaryCopy];
        _forumTitleLabel.numberOfLines = 0;
        [self.contentView addSubview:_forumTitleLabel];
        
        _openForumImage = [[UIImageView alloc] initWithImage:[UIImage caretRight]];
        _openForumImage.translatesAutoresizingMaskIntoConstraints = NO;
        _openForumImage.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_openForumImage];
        
        [self setupAllForumsIndividualForumCellConstraints];
    }
    return self;
}

- (void)setupCellWithName:(NSString *)name
       favoriteVisibility:(BOOL)favoriteVisible
        andFavoriteStatus:(BOOL)isFavorited {
    self.forumTitleLabel.text = name.capitalizedWithoutPrepositionObjc;
    self.favoriteButton.selected = isFavorited;
    
    self.favoriteButton.hidden = !favoriteVisible;
    [self updateFavoriteButtonWidth:self.favoriteButton.isHidden ? 0.0f : 40.0f];
}

- (void)setupCellWithName:(NSString *)name {
    NSMutableParagraphStyle *headerStyle = [[NSMutableParagraphStyle alloc] init];
    headerStyle.minimumLineHeight = [UIFont mulishBody1LineHeight];
    headerStyle.maximumLineHeight = [UIFont mulishBody1LineHeight];

    NSDictionary *titleAttributes = @{NSFontAttributeName: [UIFont mulishBody1],
                                 NSForegroundColorAttributeName: [UIColor tb_primaryCopy],
                                 NSParagraphStyleAttributeName: headerStyle};

    NSMutableAttributedString *titleText = [[NSMutableAttributedString alloc] initWithString: name
                                                                                  attributes: titleAttributes];
    self.forumTitleLabel.attributedText = titleText;
    self.favoriteButton.hidden = YES;
    [self updateFavoriteButtonWidth:0.0f];
}

@end
