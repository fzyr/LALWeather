//
//  LALConfigureLocationsTableViewController.m
//  LALWeather
//
//  Created by LAL on 15/12/28.
//  Copyright © 2015年 LAL. All rights reserved.
//

#import "LALConfigureLocationsTableViewController.h"
#import "Climacons.h"
#import <HPReorderTableView.h>
@interface LALConfigureLocationsTableViewController ()

@end

@implementation LALConfigureLocationsTableViewController

-(void)loadView{

    UITableView *tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
    self.tableView = tableView;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    

    UIColor *myColor = [UIColor colorWithRed:75/255.0 green:126/255.0 blue:227/255.0 alpha:1];
    self.tableView.backgroundColor = myColor;
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.weatherData.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LocationCell"];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"LocationCell"];
    };
    cell.backgroundColor = [UIColor clearColor];
    
    LALWeatherData *weatherData = [self.weatherData objectAtIndex:indexPath.row];
    NSString *tempCity = weatherData.placemark.locality;
    NSString *city = [tempCity stringByReplacingOccurrencesOfString:@"市" withString:@""];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.text = city;
    
    cell.detailTextLabel.textColor = [UIColor clearColor];
// set the detailTextLabel frame;
    cell.detailTextLabel.text = @"                ";
    [cell.detailTextLabel sizeToFit];
    NSLog(@"detailTextLabel : %@", cell.detailTextLabel);
    
    UILabel *conditionIconLabel = [cell.detailTextLabel viewWithTag:1];
    if(!conditionIconLabel){
        conditionIconLabel= [[UILabel alloc] initWithFrame:CGRectMake(50, -12, 50, cell.bounds.size.height)];
        conditionIconLabel.font = [UIFont fontWithName:CLIMACONS_FONT size:40];
        conditionIconLabel.textColor = [UIColor whiteColor];
        conditionIconLabel.backgroundColor = [UIColor clearColor];
        conditionIconLabel.tag = 1;
        conditionIconLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [cell.detailTextLabel addSubview:conditionIconLabel];
    }
    
    UILabel *currentTemperatureLabel = [cell.detailTextLabel viewWithTag:2];
    if(!currentTemperatureLabel){
        currentTemperatureLabel= [[UILabel alloc] initWithFrame:CGRectMake(-10, -12, 50, cell.bounds.size.height)];
        currentTemperatureLabel.font = [UIFont fontWithName:LIGHT_FONT size:25];
        currentTemperatureLabel.textColor = [UIColor whiteColor];
        currentTemperatureLabel.backgroundColor = [UIColor clearColor];
        currentTemperatureLabel.tag = 2;
        currentTemperatureLabel.textAlignment = NSTextAlignmentRight;
        currentTemperatureLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [cell.detailTextLabel addSubview:currentTemperatureLabel];
    }
    
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    
    NSString *temperatureString = [weatherData.currentSnapshot.currentTemperature stringValue];
    NSString *temperatureFinalString = [NSString stringWithFormat:@"%@℃",temperatureString];
    NSMutableAttributedString *abs = [[NSMutableAttributedString alloc] initWithString:temperatureFinalString];
    
    NSRange range1 = [temperatureFinalString rangeOfString:@"℃"];
    [abs addAttributes:@{NSFontAttributeName: [UIFont fontWithName:LIGHT_FONT size:12], NSBaselineOffsetAttributeName: @10} range:range1];
    
    currentTemperatureLabel.attributedText = abs;
    conditionIconLabel.text = weatherData.currentSnapshot.iconText;
    
    NSLog(@"detailTextLabel: %@",cell.detailTextLabel);
    NSLog(@"currentTemperatureLabel: %@",currentTemperatureLabel);
    NSLog(@"conditionIconLabel: %@",currentTemperatureLabel);
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.delegate dismissConfigureLocationsTableViewController:self withWeatherData:self.weatherData];
    [self.delegate selectWeatherDataWithTag:indexPath.row];
}


-(void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath{
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 0) return NO;
    else return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        [self.weatherData removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView reloadData];
    }
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    LALWeatherData *sourceWeatherData = [self.weatherData objectAtIndex:sourceIndexPath.row];
    [self.weatherData removeObject:sourceWeatherData];
    [self.weatherData insertObject:sourceWeatherData atIndex:destinationIndexPath.row];
//    [self.nonlocalWeatherData exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];

}


@end
