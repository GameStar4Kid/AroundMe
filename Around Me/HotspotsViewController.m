//
//  HotspotsViewController.m
//  Around Me
//
//  Created by Nguyen Tran on 11/27/14.
//  Copyright (c) 2014 Jean-Pierre Distler. All rights reserved.
//

#import "HotspotsViewController.h"
#import "PlaceAnnotation.h"
#import "Place.h"
@interface HotspotsViewController ()

@end

@implementation HotspotsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self refreshList:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const kReuseIdentifier = @"imageCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kReuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleSubtitle)
                                      reuseIdentifier:kReuseIdentifier];
    }
    PlaceAnnotation*data = [self.dataList objectAtIndex:indexPath.row];
    NSString*placeName=@"Unknown";
    NSString*placeAddress=@"";
    NSString*distance=@"";
    if([data isKindOfClass:[PlaceAnnotation class]] && data.place.placeName)
    {
        placeName=data.place.placeName;
    }
    if([data isKindOfClass:[PlaceAnnotation class]]&&data.place.address)
    {
        placeAddress=data.place.address;
    }
    if([data isKindOfClass:[PlaceAnnotation class]]&&data.place.distance)
    {
        distance=[NSString stringWithFormat:@"%.1fkm",data.place.distance/1000.f];
    }
    cell.textLabel.text = placeName;
    cell.detailTextLabel.text = placeAddress;
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    UIButton *syncIcon = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 64, 24)];
    syncIcon.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    syncIcon.contentMode = UIViewContentModeScaleAspectFit;
    [syncIcon setTitle:distance forState:UIControlStateNormal];
    [syncIcon setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    cell.accessoryView = syncIcon;
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataList.count;
}

- (IBAction)btnCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)refreshList:(BOOL)free
{
    if(free && _freeList &&_freeList.count>0)
    {
        self.dataList=_freeList;
        [self.tableView reloadData];
        return;
    }
    if(!free && _paidList && _paidList.count>0)
    {
        self.dataList=_paidList;
        [self.tableView reloadData];
        return;
    }
    _paidList =[NSMutableArray arrayWithCapacity:0];
    _freeList =[NSMutableArray arrayWithCapacity:0];
    for(PlaceAnnotation* item in _allData)
    {
        if([item isKindOfClass:[PlaceAnnotation class]])
        {
//            NSLog(@"refer==%@",item.place.reference);
            if([item.place.reference isEqualToString:@"Free"])
            {
                [_freeList addObject:item];
            }
            else
            {
                [_paidList addObject:item];
            }
        }
    }
    if(free && _freeList)
    {
        self.dataList=_freeList;
        [self.tableView reloadData];
        return;
    }
    if(!free && _paidList)
    {
        self.dataList=_paidList;
        [self.tableView reloadData];
        return;
    }

}
- (IBAction)valueChanged:(id)sender {
    switch ( ((UISegmentedControl*)sender).selectedSegmentIndex ) {
        case 0:
            [self refreshList:YES];
            break;
        case 1:
           [self refreshList:NO];
            break;
            
        default:
            break;
    }
}
@end
