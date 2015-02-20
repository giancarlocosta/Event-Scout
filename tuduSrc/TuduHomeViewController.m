//
//  TuduHomeViewController.m
//  tudu
//
//  Created by Gian Costa on 9/1/14.
//
//

#import "TuduHomeViewController.h"
#import "TuduAppDelegate.h"

@interface TuduHomeViewController ()

@end

@implementation TuduHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navigationItem.title = @"Event Scout";
    //self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TuduLogo.png"]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleBordered target:self action:@selector(logoutButtonAction:)];
}


- (void) logoutButtonAction:(id)sender  {
    [PFUser logOut]; // Log out
    
    // Return to Login view controller
    [(TuduAppDelegate*)[[UIApplication sharedApplication] delegate] presentLoginViewControllerAnimated:NO];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
