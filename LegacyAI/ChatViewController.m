#import "ChatViewController.h"
#import "SettingsViewController.h"
#import "APIManager.h"
#import "ChatCell.h"

@interface ChatViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *inputContainer;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *messages;
@property (nonatomic, assign) CGFloat keyboardHeight;
@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Legacy AI";
    // Macintosh Beige Background
    self.view.backgroundColor = [UIColor colorWithRed:0.89 green:0.87 blue:0.82 alpha:1.0]; 
    self.messages = [NSMutableArray array];
    
    UIBarButtonItem *settingsBtn = [[UIBarButtonItem alloc] initWithTitle:@"Ayarlar" style:UIBarButtonItemStyleDone target:self action:@selector(openSettings)];
    self.navigationItem.rightBarButtonItem = settingsBtn;
    
    [self setupUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self.messages addObject:@{@"role": @"ai", @"text": @"Merhaba! Ben Legacy AI. Lütfen sağ üstteki Ayarlar menüsünden Groq API anahtarınızı girerek sohbete başlayın."}];
}

- (void)setupUI {
    // We use manual frame calculations for zero autolayout overhead = absolute peak performance on iPhone 5s
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    self.inputContainer = [[UIView alloc] initWithFrame:CGRectZero];
    // iOS 6 metallic linen/gray keyboard top bar texture simulation
    self.inputContainer.backgroundColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.87 alpha:1.0];
    self.inputContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    self.inputContainer.layer.shadowOffset = CGSizeMake(0, -1);
    self.inputContainer.layer.shadowOpacity = 0.3;
    [self.view addSubview:self.inputContainer];
    
    self.textField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.textField.borderStyle = UITextBorderStyleRoundedRect;
    self.textField.placeholder = @"Mesaj yaz...";
    self.textField.delegate = self;
    [self.inputContainer addSubview:self.textField];
    
    self.sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.sendButton setTitle:@"Gönder" forState:UIControlStateNormal];
    [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    // Glossy send button
    self.sendButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.47 blue:1.0 alpha:1.0];
    self.sendButton.layer.cornerRadius = 6;
    self.sendButton.layer.borderColor = [UIColor colorWithRed:0.0 green:0.3 blue:0.8 alpha:1.0].CGColor;
    self.sendButton.layer.borderWidth = 1.0;
    self.sendButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.sendButton.layer.shadowOffset = CGSizeMake(0, 1);
    self.sendButton.layer.shadowOpacity = 0.5;
    
    [self.sendButton addTarget:self action:@selector(sendTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.inputContainer addSubview:self.sendButton];
    
    [self updateLayout];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self updateLayout];
}

- (void)updateLayout {
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    CGFloat inputHeight = 50.0;
    
    self.inputContainer.frame = CGRectMake(0, height - self.keyboardHeight - inputHeight, width, inputHeight);
    self.tableView.frame = CGRectMake(0, 0, width, height - self.keyboardHeight - inputHeight);
    
    self.textField.frame = CGRectMake(10, 8, width - 90, 34);
    self.sendButton.frame = CGRectMake(width - 75, 8, 65, 34);
}

- (void)openSettings {
    SettingsViewController *svc = [[SettingsViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:svc];
    // Keep the glossy nav bar in settings too
    nav.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
    nav.navigationBar.tintColor = [UIColor whiteColor];
    nav.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    nav.navigationBar.translucent = NO;
    
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)sendTapped {
    NSString *text = [self.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (text.length == 0) return;
    
    NSString *apiKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"GroqAPIKey"];
    if (!apiKey || apiKey.length == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Hata" message:@"Lütfen Ayarlar'dan API anahtarınızı girin." preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Tamam" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    [self.messages addObject:@{@"role": @"user", @"text": text}];
    self.textField.text = @"";
    [self.tableView reloadData];
    [self scrollToBottom];
    
    self.sendButton.enabled = NO;
    self.sendButton.alpha = 0.5;
    
    [APIManager sendMessage:text apiKey:apiKey completion:^(NSString *response, NSError *error) {
        self.sendButton.enabled = YES;
        self.sendButton.alpha = 1.0;
        if (error) {
            [self.messages addObject:@{@"role": @"ai", @"text": [NSString stringWithFormat:@"Hata: %@", error.localizedDescription]}];
        } else {
            [self.messages addObject:@{@"role": @"ai", @"text": response}];
        }
        [self.tableView reloadData];
        [self scrollToBottom];
    }];
}

- (void)scrollToBottom {
    if (self.messages.count > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

#pragma mark - Keyboard
- (void)keyboardWillShow:(NSNotification *)notif {
    CGRect kbFrame = [notif.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval duration = [notif.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    self.keyboardHeight = kbFrame.size.height;
    
    [UIView animateWithDuration:duration animations:^{
        [self updateLayout];
        [self scrollToBottom];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notif {
    NSTimeInterval duration = [notif.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    self.keyboardHeight = 0;
    
    [UIView animateWithDuration:duration animations:^{
        [self updateLayout];
    }];
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text = self.messages[indexPath.row][@"text"];
    CGSize maxSize = CGSizeMake([UIScreen mainScreen].bounds.size.width * 0.75, CGFLOAT_MAX);
    CGRect textRect = [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]} context:nil];
    return textRect.size.height + 40; // Extra padding for shadows
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[ChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    NSDictionary *msg = self.messages[indexPath.row];
    BOOL isUser = [msg[@"role"] isEqualToString:@"user"];
    [cell configureWithMessage:msg[@"text"] isUser:isUser];
    return cell;
}

@end
