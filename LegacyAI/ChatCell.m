#import "ChatCell.h"

@implementation ChatCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.bubbleView = [[UIView alloc] init];
        self.bubbleView.layer.cornerRadius = 16;
        // iOS 6 Skeuomorphic Drop Shadow
        self.bubbleView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.bubbleView.layer.shadowOffset = CGSizeMake(0, 2.5);
        self.bubbleView.layer.shadowOpacity = 0.45;
        self.bubbleView.layer.shadowRadius = 2.5;
        self.bubbleView.layer.borderWidth = 0.5;
        [self.contentView addSubview:self.bubbleView];
        
        self.messageLabel = [[UILabel alloc] init];
        self.messageLabel.numberOfLines = 0;
        self.messageLabel.font = [UIFont systemFontOfSize:16];
        // Classic letterpress effect
        self.messageLabel.shadowOffset = CGSizeMake(0, 1);
        [self.bubbleView addSubview:self.messageLabel];
    }
    return self;
}

- (void)configureWithMessage:(NSString *)message isUser:(BOOL)isUser {
    self.messageLabel.text = message;
    
    CGSize maxSize = CGSizeMake([UIScreen mainScreen].bounds.size.width * 0.75, CGFLOAT_MAX);
    CGRect textRect = [message boundingRectWithSize:maxSize
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName: self.messageLabel.font}
                                            context:nil];
    
    CGFloat padding = 14.0;
    CGFloat bubbleWidth = textRect.size.width + (padding * 2);
    CGFloat bubbleHeight = textRect.size.height + (padding * 2);
    
    if (isUser) {
        // iOS 6 Classic iMessage Green Glossy Bubble
        self.bubbleView.backgroundColor = [UIColor colorWithRed:0.25 green:0.8 blue:0.25 alpha:1.0];
        self.bubbleView.layer.borderColor = [UIColor colorWithRed:0.1 green:0.6 blue:0.1 alpha:1.0].CGColor;
        self.bubbleView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - bubbleWidth - 10, 8, bubbleWidth, bubbleHeight);
        self.messageLabel.textColor = [UIColor whiteColor];
        self.messageLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.4];
    } else {
        // Classic Light Gray Bubble
        self.bubbleView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
        self.bubbleView.layer.borderColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0].CGColor;
        self.bubbleView.frame = CGRectMake(10, 8, bubbleWidth, bubbleHeight);
        self.messageLabel.textColor = [UIColor blackColor];
        self.messageLabel.shadowColor = [UIColor whiteColor];
    }
    
    self.messageLabel.frame = CGRectMake(padding, padding, textRect.size.width, textRect.size.height);
}

@end
