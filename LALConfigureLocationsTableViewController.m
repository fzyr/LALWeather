//
//  LALConfigureLocationsTableViewController.m
//  LALWeather
//
//  Created by LAL on 15/12/28.
//  Copyright © 2015年 LAL. All rights reserved.
//

#import "LALConfigureLocationsTableViewController.h"
#import "Climacons.h"

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
        currentTemperatureLabel= [[UILabel alloc] initWithFrame:CGRectMake(-17, -12, 57, cell.bounds.size.height)];
        currentTemperatureLabel.font = [UIFont fontWithName:LIGHT_FONT size:25];
        currentTemperatureLabel.textColor = [UIColor whiteColor];
        currentTemperatureLabel.backgroundColor = [UIColor clearColor];
        currentTemperatureLabel.tag = 2;
        currentTemperatureLabel.textAlignment = NSTextAlignmentRight;
        currentTemperatureLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [cell.detailTextLabel addSubview:currentTemperatureLabel];
    }
    
    if(indexPath.row == 0){
        UIImageView *locationTagView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LALLocation_H_40"]];
        locationTagView.center = CGPointMake(cell.contentView.center.x * 0.5, cell.contentView.center.y);
        [cell.contentView addSubview:locationTagView];
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

    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.delegate dismissConfigureLocationsTableViewController:self withWeatherData:self.weatherData];
    [self.delegate selectWeatherDataWithTag:indexPath.row];
}


-(void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%@",NSStringFromSelector(_cmd));
}

//0.  When editing button is pressed
//0.1.1 Which indexPath enters editting mode
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
        NSLog(@"%@",NSStringFromSelector(_cmd));
    if(indexPath.row == 0) return NO;
    else return YES;
}

//0.1.2 What happens when you press delete or add
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
        NSLog(@"%@",NSStringFromSelector(_cmd));
    if(editingStyle == UITableViewCellEditingStyleDelete){
        [self.weatherData removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView reloadData];
    }
}

//0.2.1  which row movable as the sourceIndexPath
-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%@",NSStringFromSelector(_cmd));
    return YES;
}

//0.2.2  First row not movable as the destinationIndexPath
-(NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath{
    NSLog(@"%@",NSStringFromSelector(_cmd));
    if(proposedDestinationIndexPath.row == 0){
        return sourceIndexPath;
    }else{
        return proposedDestinationIndexPath;
    }
}

//0.2.3   When rows reorder, how you handle the data
-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    NSLog(@"%@",NSStringFromSelector(_cmd));
    LALWeatherData *sourceWeatherData = [self.weatherData objectAtIndex:sourceIndexPath.row];
    [self.weatherData removeObject:sourceWeatherData];
    [self.weatherData insertObject:sourceWeatherData atIndex:destinationIndexPath.row];
}



@end
