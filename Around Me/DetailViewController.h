//
//  DetailViewController.h
//  Around Me
//
//  Created by Nguyen Tran on 11/26/14.
//  Copyright (c) 2014 Jean-Pierre Distler. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface DetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblAddress;
@property (weak, nonatomic) IBOutlet UIButton *btnPassword;
- (IBAction)btnCancelClick:(id)sender;
@property(nonatomic,strong) id annotation;
@end
