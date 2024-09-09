#import <UIKit/UIKit.h>

@interface TBAllForumsIndividualForumTableViewCell : UITableViewCell

@property (nonatomic, strong) UIButton *favoriteButton;
@property (nonatomic, strong) UILabel *forumTitleLabel;
@property (nonatomic, strong) UIImageView *openForumImage;

- (void)setupCellWithName:(NSString *)name
       favoriteVisibility:(BOOL)favoriteVisible
        andFavoriteStatus:(BOOL)isFavorited;

- (void)setupCellWithName:(NSString *)name;

@end
