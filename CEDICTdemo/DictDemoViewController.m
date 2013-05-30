//
//  DictDemoViewController.m
//  CEDICTdemo
//
//  Created by B.H.Liu on 13-5-28.
//  Copyright (c) 2013年 Appublisher. All rights reserved.
//

#import "DictDemoViewController.h"
#import "DictDemoDatabaseManager.h"

@interface DictDemoViewController () <UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>

@property(nonatomic, strong) UITableView * tableView;
@property(nonatomic, strong) UILabel * timeLabel;
@property(nonatomic, strong) NSMutableArray * matchWords;


@end

@implementation DictDemoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.matchWords = [NSMutableArray array];
    
    UISearchBar * searchbar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 44, self.view.frame.size.width*2/3, 40)];
    searchbar.center = CGPointMake(CGRectGetMidX(self.view.frame), 64);
    [[searchbar.subviews objectAtIndex:0] removeFromSuperview];
    [self.view addSubview:searchbar];
    searchbar.delegate = self;
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 84, self.view.frame.size.width, 40)];
    self.timeLabel.center = CGPointMake(CGRectGetMidX(self.view.frame), 104);
    [self.view addSubview:self.timeLabel];
    self.timeLabel.backgroundColor = [UIColor clearColor];
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 124, self.view.frame.size.width - 20, self.view.frame.size.height - 124)];
    self.tableView.backgroundView = nil;
    self.tableView.opaque = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    NSLog(@"%@",[[DictDemoDatabaseManager sharedDataManager] segmentSentence:@"中关村E世界数码广场A839写字间" withMaxWordlength:4]);
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    searchText = [searchText lowercaseString];
    if ([searchText length] > 0)
    {
        [self.matchWords removeAllObjects];
        
        NSTimeInterval start_time = [NSDate timeIntervalSinceReferenceDate];
        NSArray *array = [[DictDemoDatabaseManager sharedDataManager] selectWordWithPrefix:searchText];
        NSTimeInterval end_time = [NSDate timeIntervalSinceReferenceDate];
        
        [self.matchWords addObjectsFromArray:array];
        [self.tableView reloadData];
        
        self.timeLabel.text = [NSString stringWithFormat:@"search out %d results in %f seconds",array.count,end_time-start_time];
    }
}

#pragma mark- UITableDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.matchWords count];
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"Cell_Identifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell.textLabel setText:[NSString stringWithFormat:@"%@ %@",self.matchWords[indexPath.row][@"simplified"],[[DictDemoDatabaseManager sharedDataManager] transferPinyinSyllable:self.matchWords[indexPath.row][@"pinyin"]]]];
    
    return cell;
}


@end
