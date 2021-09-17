
#import "GuideViewController.h"

@interface GuideViewController ()
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UITextView *textView;


@end

@implementation GuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.textView.text = @"SDK使用流程：\n\nApp启动\n\n1.配置sdk功能（可选）\n\n⇩\n\n2.配置未成年日常可玩时间（可选）\n\n⇩\n\n3.初始化sdk（必选！！！）\n\n⇩\n\n4.登录用户login\n\n⇩\n\n5.其他操作\n\n\n\n";
    
    [self.closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
