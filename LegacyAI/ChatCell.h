#import <UIKit/UIKit.h>

@interface ChatCell : UITableViewCell
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIView *bubbleView;
- (void)configureWithMessage:(NSString *)message isUser:(BOOL)isUser;
@end
