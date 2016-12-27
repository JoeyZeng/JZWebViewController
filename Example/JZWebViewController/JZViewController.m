//
//  JZViewController.m
//  JZWebViewController
//
//  Created by Joey on 12/26/2016.
//  Copyright (c) 2016 Joey. All rights reserved.
//

#import "JZViewController.h"
#import "JZWebViewController.h"

@interface JZViewController ()
@property (weak, nonatomic) IBOutlet UITextField *urlTextField;

@end

@implementation JZViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1) {
        JZWebViewController *vc = [[JZWebViewController alloc] initWithUrl:self.urlTextField.text];
        vc.showNavRefresh = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
