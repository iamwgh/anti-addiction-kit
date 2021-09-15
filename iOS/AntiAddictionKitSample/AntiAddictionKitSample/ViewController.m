

#import "ViewController.h"
#import "ButtonViewCell.h"
#import "NetworkHelper.h"
@import AntiAddictionKit;
//#import "AntiAddictionKit/AntiAddictionKit-Swift.h"
//#import "AntiAddictionKit/AntiAddictionKit.h"

static NSString *const cellReuseIdentifier = @"buttonCollectionViewCell";

static NSString *const onlineTimeNotificationName = @"NSNotification.Name.totalOnlineTime";

@interface ViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, AntiAddictionCallback>
@property (strong, nonatomic) UICollectionView *actionsView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *guideButton;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *callbackLabel;

@property (assign, nonatomic) BOOL isSdkInitialized;

@property (assign, nonatomic) BOOL isMainlandUser;
@property (weak, nonatomic) IBOutlet UISegmentedControl *userSegment;

@property (assign, nonatomic) BOOL isSdkServerEnabled;

@end

@implementation ViewController

// MARK: - Life Cycle, UI Settings
- (BOOL)isLandscape {
    return UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication.statusBarOrientation);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isSdkServerEnabled = NO;
    
    [self setupUI];
    
    [self addNotificationListener];
    
    self.isSdkInitialized = NO;
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupUI {
    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
    flowLayout.minimumLineSpacing = 10;
    flowLayout.minimumInteritemSpacing = 10;
    _actionsView = [[UICollectionView alloc] initWithFrame:[self actionsViewRect] collectionViewLayout:flowLayout];
    [self.view addSubview:_actionsView];
    _actionsView.backgroundColor = UIColor.clearColor;
    _actionsView.delegate = self;
    _actionsView.dataSource = self;
    _actionsView.alwaysBounceVertical = YES;
    _actionsView.alwaysBounceHorizontal = YES;
    _actionsView.contentInset = UIEdgeInsetsMake(20, 20, 20, 20);
    
    [_actionsView registerClass:[ButtonViewCell self] forCellWithReuseIdentifier:cellReuseIdentifier];
    
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDic objectForKey:@"CFBundleShortVersionString"];
     NSString *appBuildVersion = [infoDic objectForKey:@"CFBundleVersion"];
    _nameLabel.text = [NSString stringWithFormat:@"DEMO %@(%@)", appVersion, appBuildVersion];
}

- (CGRect)actionsViewRect {
    if ([self isLandscape]) {
        return CGRectMake(40, 40, self.view.frame.size.width-80, self.view.frame.size.height - 80);
    } else {
        return CGRectMake(0, 80, self.view.frame.size.width, self.view.frame.size.height - 160);
    }
}

- (CGSize)buttonSize {
    return CGSizeMake(310, 80);
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    _actionsView.frame = [self actionsViewRect];
    
    [super traitCollectionDidChange:previousTraitCollection];
}

// MARK: - Notification
- (void)addNotificationListener {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(showUserOnlineTimeWithNote:) name:onlineTimeNotificationName object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(showUserRegion) name:NSUserDefaultsDidChangeNotification object:nil];
}

- (void)showUserOnlineTimeWithNote:(NSNotification *)note {
     NSNumber *time = [note.userInfo objectForKey:@"totalOnlineTime"];
    NSString *userId = [note.userInfo objectForKey:@"userId"];
    if (time) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.timeLabel.text = [NSString stringWithFormat:@"用户[%@]游戏时长 %ld 秒", userId, (long)[time integerValue]];
        });
    }
}

- (void)showUserRegion {
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDic objectForKey:@"CFBundleShortVersionString"];
     NSString *appBuildVersion = [infoDic objectForKey:@"CFBundleVersion"];
    NSString *versionText = [NSString stringWithFormat:@"DEMO %@(%@)", appVersion, appBuildVersion];
    
     BOOL isMainland = [NSUserDefaults.standardUserDefaults boolForKey:@"isMainlandUser"];
    NSString *region = isMainland ? @"[大陆地区]" : @"[非大陆地区]";
     dispatch_async(dispatch_get_main_queue(), ^{
         self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", versionText, region];
     });
}



// MARK: - UICollectionView Delegate & DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self buttonArray].count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self buttonSize];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ButtonViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellReuseIdentifier forIndexPath:indexPath];
    if (![cell isKindOfClass:[ButtonViewCell class]]) {
        return [UICollectionViewCell new];
    }
    cell.textLabel.text = [[self buttonArray] objectAtIndex:indexPath.item][0];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *selectorName = (NSString *)([self buttonArray][indexPath.item][1]);
    SEL selector = NSSelectorFromString(selectorName);
    // 避免直接使用`[self performSelector:selector];`而出现的 warning
    IMP imp = [self methodForSelector:selector];
    void (*func)(id, SEL) = (void *)imp;
    func(self, selector);
}

// MARK: - AAKit Delegate
- (void)onAntiAddictionResult:(NSInteger)code :(NSString *)message {
    if (@available(iOS 10.0, *)) {
        [[UINotificationFeedbackGenerator new] notificationOccurred:UINotificationFeedbackTypeSuccess];
    }
    self.callbackLabel.text = [NSString stringWithFormat:@"[AAKit Callback]\n%@", message];
}

// MARK: - Actions
- (NSArray *)buttonArray {
    return @[
        @[@"功能配置❓可选\n(实名/付费/时长)\n不设置即默认值）", @"configSdkFunctions"],
        @[@"未成年日常可玩时间配置（非节假日） ❓可选\n 不设置即默认值（周五,周六,周日的20：00-21：00）",@"minorPlay"],
        @[@"初始化‼️\n(单机版。)", @"initSdk"],
        @[@"登录用户‼️\n(强制)\n（id，type）", @"login"],
        @[@"退出登录", @"logout"],
        @[@"更新用户类型\n（type）", @"updateUserType"],
        @[@"获取用户类型\n（id）", @"getUserType"],
        @[@"申请支付（单位分）购买前调用", @"checkPayLimit"],
        @[@"已支付（单位分）购买成功后调用", @"paySuccess"],
        @[@"检查能否聊天", @"gameCheckChatLimit"],
        @[@"打开实名登记\n(登录后可用)", @"openRealName"],
//        @[@"生成证件号，6小时有效（已复制）", @"generateIDCode"],
        @[@"杀掉应用", @"killApp"]
    ];
}

- (void)killApp {
    exit(0);
}

- (void)configSdkFunctions {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"SDK配置选项" message:@"配置防沉迷SDK\n0不开启，不填或非0默认开启" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.placeholder = @"实名开关 0=关闭";
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.placeholder = @"付费限制开关 0=关闭";
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.placeholder = @"游戏时长控制开关 0=关闭";
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        BOOL isRealnameOpen  = ![[alert.textFields objectAtIndex:0].text isEqualToString:@"0"];
         BOOL isPaymentLimitOpen  = ![[alert.textFields objectAtIndex:1].text isEqualToString:@"0"];
         BOOL isTimeLimitOpen  = ![[alert.textFields objectAtIndex:2].text isEqualToString:@"0"];
        
        [AntiAddictionKit setFunctionConfig:isRealnameOpen :isPaymentLimitOpen :isTimeLimitOpen];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:true completion:nil];
}

- (void)minorPlay{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"防沉迷未成年日常时间配置" message:@"日期格式：周五,周六,周日（英文逗号,不填即默认）\n可玩开始时间格式(小时:分)：20:00(英文冒号)\n可玩结束时间格式：21:00" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"可玩日期，默认周五,周六,周日";
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"可玩开始时间，默认20:00";
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"可玩结束时间，默认21:00";
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"111--%@--%d",[alert.textFields objectAtIndex:0].text,[[alert.textFields objectAtIndex:0].text intValue]);
        if ([[alert.textFields objectAtIndex:0].text length] > 0) {
            NSString *playDay = [alert.textFields objectAtIndex:0].text;
            NSArray *playDayArr = [playDay componentsSeparatedByString:@","];
            NSLog(@"111--%@",playDayArr);
            AntiAddictionKit.configuration.minorPlayDay = playDayArr;
        }
        if ([[alert.textFields objectAtIndex:1].text length]>0) {
            AntiAddictionKit.configuration.minorPlayStart = [alert.textFields objectAtIndex:1].text;
        }
        if ([[alert.textFields objectAtIndex:2].text length]>0) {
            AntiAddictionKit.configuration.minorPlayEnd = [alert.textFields objectAtIndex:2].text;
        }
    }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:okAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:true completion:nil];
}


- (void)initSdk {
    [AntiAddictionKit init:self];
    
    self.isSdkInitialized = YES;
    
    self.callbackLabel.text = @"游戏初始化成功";
}

- (BOOL)checkInitStatus {
    if (!self.isSdkInitialized) {
        if (@available(iOS 10.0, *)) {
            [[UINotificationFeedbackGenerator new] notificationOccurred:UINotificationFeedbackTypeWarning];
        }
        self.callbackLabel.text = @"请先初始化SDK！！！";
        return NO;
    }
    return YES;
}

- (void)login {
    if (![self checkInitStatus]) { return; }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"登录用户" message:@"\n账号ID = 任意字符串\n账号类型 = 数字\n\n0 = 未知（未实名）\n1 = 7岁及以下\n2 = 8-15岁\n3 = 16-17岁\n4 = 18岁及以上\n其他值 = 默认未知0" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeEmailAddress;
        textField.placeholder = @"账号ID";
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.placeholder = @"账号类型";
    }];
    UIAlertAction *purchaseAction = [UIAlertAction actionWithTitle:@"登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *userId  = alert.textFields.firstObject.text;
        NSInteger userType = [alert.textFields[1].text integerValue];
        if (!userId || userId.length == 0) {
            userId = @"";
        }
        
        if (self.isSdkServerEnabled) {
            [NetworkHelper getTokenWith:userId completionHandler:^(NSString * _Nullable token) {
                if ([token length] > 0) {
                    [AntiAddictionKit login:token :userType];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.callbackLabel.text = [NSString stringWithFormat:@"用户[%@]已登录", token];
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.callbackLabel.text = @"登录前获取token失败";
                    });
                     
                }
                
            }];
        } else {
             [AntiAddictionKit login:userId :userType];
        }
        
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:purchaseAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:true completion:nil];
}

- (void)updateUserType {
    if (![self checkInitStatus]) { return; }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"更新用户类型" message:@"账号类型 = 数字\n\n0 = 未知（未实名）\n1 = 7岁及以下\n2 = 8-15岁\n3 = 16-17岁\n4 = 18岁及以上\n其他值 = 默认未知0" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.placeholder = @"账号类型";
    }];
    UIAlertAction *purchaseAction = [UIAlertAction actionWithTitle:@"更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSInteger userType = [alert.textFields.firstObject.text integerValue];
        [AntiAddictionKit updateUserType:userType];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.callbackLabel.text = [NSString stringWithFormat:@"用户类型已更新为%ld", userType];
        });
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:purchaseAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:true completion:nil];
}

- (void)logout {
    if (![self checkInitStatus]) { return; }
    [AntiAddictionKit logout];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.callbackLabel.text = @"用户已退出登录";
    });
}

- (void)checkPayLimit {
    if (![self checkInitStatus]) { return; }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请求购买道具（单位分=0.01元）" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.placeholder = @"请输入支付金额（单位分）";
    }];
    UIAlertAction *purchaseAction = [UIAlertAction actionWithTitle:@"支付" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSInteger money = [alert.textFields.firstObject.text integerValue];
        [AntiAddictionKit checkPayLimit:money];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:purchaseAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:true completion:nil];
}

- (void)paySuccess {
    if (![self checkInitStatus]) { return; }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"已经购买道具（单位分=0.01元）" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.placeholder = @"请输入支付金额（单位分）";
    }];
    UIAlertAction *purchaseAction = [UIAlertAction actionWithTitle:@"支付" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSInteger money = [alert.textFields.firstObject.text integerValue];
        [AntiAddictionKit paySuccess:money];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:purchaseAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:true completion:nil];
}

- (void)gameCheckChatLimit {
    if (![self checkInitStatus]) { return; }
    [AntiAddictionKit checkChatLimit];
}

- (void)getUserType {
    if (![self checkInitStatus]) { return; }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"获取用户类型" message:@"-1：未知\n0：未实名\n1：0-7\n2：8-15\n3：16-17\n4：18+" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeURL;
        textField.placeholder = @"请输入用户id";
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *userId = alert.textFields.firstObject.text;
        NSInteger userType = [AntiAddictionKit getUserType:userId];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.callbackLabel.text = [NSString stringWithFormat:@"用户[%@]类型=%ld", userId, (long)userType];
        });
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:true completion:nil];
}

- (void)openRealName {
    if (![self checkInitStatus]) { return; }
    [AntiAddictionKit openRealName];
}

- (void)generateIDCode {
#if DEBUG
    NSString *code = [AntiAddictionKit generateIDCode];
    if (code && code.length > 0) {
        self.callbackLabel.text = code;
        UIPasteboard.generalPasteboard.string = code;
    }
#endif
}

@end
