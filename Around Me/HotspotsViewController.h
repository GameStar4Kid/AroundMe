//
//  HotspotsViewController.h
//  Around Me
//
//  Created by Nguyen Tran on 11/27/14.
//  Copyright (c) 2014 Jean-Pierre Distler. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HotspotsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)IBOutlet UITableView*tableView;
@property(nonatomic,strong)NSArray*dataList;
@property(nonatomic,strong)NSMutableArray*freeList;
@property(nonatomic,strong)NSMutableArray*paidList;
- (IBAction)valueChanged:(id)sender;
@property(nonatomic,strong)NSArray*allData;
- (IBAction)btnCancel:(id)sender;
@end
