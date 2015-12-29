//
//  LALAddLocationTableViewController.m
//  LALWeather
//
//  Created by LAL on 15/12/26.
//  Copyright © 2015年 LAL. All rights reserved.
//

#import "LALAddLocationTableViewController.h"
#import <CoreLocation/CoreLocation.h>
@interface LALAddLocationTableViewController ()<UISearchBarDelegate>
@property (nonatomic, strong) NSArray *searchedResults;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) CLGeocoder *geocoder;
@end

@implementation LALAddLocationTableViewController

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIColor *myColor = [UIColor colorWithRed:75/255.0 green:126/255.0 blue:227/255.0 alpha:1];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 80)];
    self.tableView.backgroundColor = myColor;
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width-40, 40)];
    [headerView addSubview:searchBar];
    self.tableView.tableHeaderView = headerView;
    self.searchBar = searchBar;
    searchBar.delegate = self;
    searchBar.backgroundColor = myColor;
    
    searchBar.searchBarStyle = UISearchBarStyleDefault;
    searchBar.placeholder = @"search location here";
    searchBar.showsCancelButton = YES;
    [self __enableCancelButton];
    self.tableView.tableHeaderView = searchBar;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    self.geocoder = [[CLGeocoder alloc] init];
    
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.searchedResults count];
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor clearColor];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    CLPlacemark *placemark = (CLPlacemark *)self.searchedResults[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@, %@", placemark.locality, placemark.administrativeArea];
    
    return cell;
}



-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.geocoder geocodeAddressString:self.searchBar.text completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if(!error){
            CLPlacemark *placemark = [placemarks lastObject];
            if (placemark.locality) {
                self.searchedResults = @[placemark];
            }else{
                self.searchedResults = nil;
            }
        }else{
            self.searchedResults = nil;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.searchBar resignFirstResponder];
            [self.tableView reloadData];
        });
    }];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self.searchBar resignFirstResponder];
    [self.delegate dismissAddLocationTableViewController];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CLPlacemark *placemark = self.searchedResults[indexPath.row];
    if(placemark){
        [self.delegate dismissAddLocationTableViewController];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            
//        });
        [self.delegate addLocationDidSuccessWithPlacemark:placemark];
    }
}


//set searchBar's cancel button enabled in normal case;
-(void)__enableCancelButton{
    for(UIView *view in self.searchBar.subviews){
        for(UIView *subview in view.subviews){
            if([subview isKindOfClass:[UIButton class]]){
                UIButton *cancelButton = (UIButton *)subview;
                [cancelButton setEnabled:YES];
                break;
            }
        }
    }
}

@end
