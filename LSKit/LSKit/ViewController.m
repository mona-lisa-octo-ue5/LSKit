//
//  ViewController.m
//  LSKit
//
//  Created by 石玉龙 on 2021/8/26.
//

#import "ViewController.h"
#import "LSTools.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    LSLog(YES, @"safashfhsalkjhfaskhfkajshf");
    LSLog(YES, @"%@", NSStringFromCGSize(ls_image_scale(CGSizeMake(10, 10))));
}


@end
