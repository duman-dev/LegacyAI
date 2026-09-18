#import "SettingsViewController.h"

@interface SettingsViewController () <UITextFieldDelegate>
@property (nonatomic, strong) UITextField *apiKeyField;
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Ayarlar (Groq API)";
    // Classic Macintosh Beige Background
    self.view.backgroundColor = [UIColor colorWithRed:0.89 green:0.87 blue:0.82 alpha:1.0]; 
    
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, self.view.bounds.size.width - 40, 60)];
    infoLabel.text = @"Tamamen ücretsiz Groq API anahtarınızı (gsk_...) girerek Llama 3.3 modelini kullanabilirsiniz.";
    infoLabel.numberOfLines = 0;
    infoLabel.font = [UIFont systemFontOfSize:14];
    infoLabel.textColor = [UIColor darkGrayColor];
    [self.view addSubview:infoLabel];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, self.view.bounds.size.width - 40, 30)];
    label.text = @"API Anahtarı:";
    label.font = [UIFont boldSystemFontOfSize:16];
    label.textColor = [UIColor blackColor];
    // Add subtle text shadow
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0, 1);
    [self.view addSubview:label];
    
    self.apiKeyField = [[UITextField alloc] initWithFrame:CGRectMake(20, 135, self.view.bounds.size.width - 40, 44)];
    self.apiKeyField.borderStyle = UITextBorderStyleRoundedRect;
    self.apiKeyField.placeholder = @"gsk_...";
    self.apiKeyField.secureTextEntry = YES;
    self.apiKeyField.delegate = self;
    self.apiKeyField.layer.shadowColor = [UIColor blackColor].CGColor;
    self.apiKeyField.layer.shadowOffset = CGSizeMake(0, 1);
    self.apiKeyField.layer.shadowOpacity = 0.2;
    self.apiKeyField.layer.shadowRadius = 1;
    
    NSString *savedKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"GroqAPIKey"];
    if (savedKey) {
        self.apiKeyField.text = savedKey;
    }
    [self.view addSubview:self.apiKeyField];
    
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    saveBtn.frame = CGRectMake(20, 200, self.view.bounds.size.width - 40, 50);
    [saveBtn setTitle:@"Kaydet ve Kapat" forState:UIControlStateNormal];
    
    // Skeuomorphic Glassy Button
    saveBtn.backgroundColor = [UIColor colorWithRed:0.2 green:0.6 blue:0.9 alpha:1.0];
    saveBtn.layer.cornerRadius = 8;
    saveBtn.layer.borderColor = [UIColor colorWithRed:0.1 green:0.4 blue:0.7 alpha:1.0].CGColor;
    saveBtn.layer.borderWidth = 1.0;
    saveBtn.layer.shadowColor = [UIColor blackColor].CGColor;
    saveBtn.layer.shadowOffset = CGSizeMake(0, 3);
    saveBtn.layer.shadowOpacity = 0.6;
    saveBtn.layer.shadowRadius = 3;
    
    [saveBtn addTarget:self action:@selector(saveKey) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveBtn];
}

- (void)saveKey {
    [[NSUserDefaults standardUserDefaults] setObject:self.apiKeyField.text forKey:@"GroqAPIKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
