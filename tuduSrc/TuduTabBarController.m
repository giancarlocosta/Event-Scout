//
//  TuduTabBarController.m
//  tudu
//
//  Created by Gian Costa on 9/1/14.
//
//

#import "TuduTabBarController.h"

@interface TuduTabBarController ()
@property (nonatomic,strong) UINavigationController *navController;
@end

@implementation TuduTabBarController
@synthesize navController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.tabBar.tintColor = [UIColor colorWithRed:139.0f/255.0f green:111.0f/255.0f blue:95.0f/255.0f alpha:1.0f];
    self.navController = [[UINavigationController alloc] init];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - UITabBarController

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
    [super setViewControllers:viewControllers animated:animated];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        // Do stuff based on buttons clicked
    } else if (buttonIndex == 1) {
        // Do stuff based on buttons clicked
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
