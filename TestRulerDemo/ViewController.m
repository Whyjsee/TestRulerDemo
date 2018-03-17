//
//  ViewController.m
//  TestRulerDemo
//
//  Created by yjc on 14/03/2018.
//  Copyright © 2018 test. All rights reserved.
//

#import "ViewController.h"
#import "RulerScrollView.h"

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UITextField* numField;
@property (nonatomic, weak) IBOutlet UITextField* numField2;

@property (nonatomic, strong) RulerScrollView* rulerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.rulerView = [[RulerScrollView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/2, self.view.frame.size.width, 300)];
    
    [self.view addSubview:self.rulerView];
    self.rulerView.center = self.view.center;
    
    
    //tmp a
    UIView* redMidLine = [[UIView alloc] init];
    [redMidLine setBackgroundColor:[UIColor colorWithRed:248.f/255.f green:57.f/255.f blue:66.f/255.f alpha:0.5]];
    [redMidLine setFrame:CGRectMake(0, 0, 10, self.rulerView.frame.size.height)];
    redMidLine.center = self.view.center;
    [self.view addSubview:redMidLine];
}

- (IBAction)confirm{
    
    
}

- (IBAction)confirm2{
 
    NSInteger num = [self.numField2.text intValue];
    
    [self.rulerView jumpToDegree:num];
}


@end
