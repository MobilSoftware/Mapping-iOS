//
//  ViewController.m
//  mapping
//
//  Created by Richard on 2016/12/6.
//  Copyright © 2016年 sailstech. All rights reserved.
//

#import "ViewController.h"
#import <ParseUI/ParseUI.h>

@interface ViewController () 

@end

@implementation ViewController
- (void)awakeFromNib
{
    [super awakeFromNib];
    self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentController"];
    self.menuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"menuController"];
}

@end
