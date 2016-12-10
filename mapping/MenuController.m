//
//  MenuController.m
//  mapping
//
//  Created by Richard on 2016/12/6.
//  Copyright © 2016年 sailstech. All rights reserved.
//

#import "MenuController.h"
#import "CommonDefine.h"
#import "UIViewController+REFrostedViewController.h"
#import "REFrostedViewController.h"
#import "HomeController.h"
#import <SDWebImage/UIImageView+WebCache.h>
@interface MenuController ()
@property (weak, nonatomic) IBOutlet UILabel *labelUsername;
@property (weak, nonatomic) IBOutlet UILabel *labelEmail;
@property (weak, nonatomic) IBOutlet UIImageView *titleBackground;
@property (weak, nonatomic) IBOutlet UIImageView *titleIcon;

@end

@implementation MenuController

- (void)viewDidLoad {
    [super viewDidLoad];
    _titleIcon.layer.cornerRadius = _titleIcon.frame.size.width / 2;
    _titleIcon.clipsToBounds = YES;
    _titleIcon.layer.borderWidth = 3.0f;
    _titleIcon.layer.borderColor = [UIColor whiteColor].CGColor;
//    [_titleBackground sd_setImageWithURL:@"https://s3.amazonaws.com/sailstechapi/projects/ntmofa_background.png"];
//    [_titleIcon sd_setImageWithURL:@"https://s3.amazonaws.com/sailstechapi/projects/ntmofa_icon.png"];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


-(void) setUserName:(NSString*)username
              Email:(NSString*)email
            IconURL:(NSString*)iconURL
      backgroundURL:(NSString*)backgroundURL
{
    [_titleBackground sd_setImageWithURL:backgroundURL];
    [_titleIcon sd_setImageWithURL:iconURL];
    _labelUsername.text=username;
    _labelEmail.text=email;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)sectionIndex
{
    if (sectionIndex == 0)
        return nil;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 34)];
    view.backgroundColor = [UIColor colorWithRed:167/255.0f green:167/255.0f blue:167/255.0f alpha:0.6f];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, 0, 0)];

    if(sectionIndex==1) {
        label.text = ZpLocalizedString(@"_account");
        
    }
    if(sectionIndex==2) {
        
        label.text = [NSString stringWithFormat:@"%@ %@",ZpLocalizedString(@"_version"), [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
        
    }
    label.font = [UIFont systemFontOfSize:15];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    [label sizeToFit];

    [view addSubview:label];

    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectionIndex
{
    if (sectionIndex == 0)
        return 0;

    return 34;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    HomeController * homeController=(HomeController *)(((UINavigationController *)[self frostedViewController].contentViewController).topViewController);
//    DEMONavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentController"];
//
    if (indexPath.section == 0 && indexPath.row == 0) {
        [homeController runAccVerify];

    }

    if (indexPath.section == 1 && indexPath.row == 0) {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"projectId"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        [homeController selectProjectProcedure];
    }
    if (indexPath.section == 1 && indexPath.row == 1) {
        [homeController logoutProcedure];

    }
//
//    self.frostedViewController.contentViewController = navigationController;
    [self.frostedViewController hideMenuViewController];
}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    if(sectionIndex==0)
        return 1;
    else if(sectionIndex==1)
        return 2;
    else if(sectionIndex==2)
        return 0;
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    if (indexPath.section == 0) {
        NSArray *titles = @[ZpLocalizedString(@"accuracy_verification")];
        NSArray *images = @[[UIImage imageNamed:@"menu_acc_verify"]];

        cell.textLabel.text = titles[indexPath.row];
        [cell.imageView setImage:images[indexPath.row]];

    } else {
        NSArray *titles = @[ZpLocalizedString(@"switch_project"),ZpLocalizedString(@"_logout")];
        NSArray *images = @[[UIImage imageNamed:@"menu_switch_project"],[UIImage imageNamed:@"menu_logout"]];
        cell.textLabel.text = titles[indexPath.row];
        [cell.imageView setImage:images[indexPath.row]];
    }

    return cell;
}

@end
