//
//  VariationsViewController.m
//  Acro
//
//  Created by Mostafijur Rahaman on 3/14/16.
//  Copyright © 2017 Mostafijur Rahaman. All rights reserved.
//

#import "VariationsViewController.h"
#import "Constants.h"

@interface VariationsViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic,weak) IBOutlet UITableView *variationsTableView;
@property (nonatomic,weak) IBOutlet UILabel *noResultsLabel;

@end

@implementation VariationsViewController


#pragma mark - UIViewController Lifecycle methods
- (void)viewDidLoad {
    [super viewDidLoad];
   
    if (self.meaning.variations.count) {
        [self.variationsTableView setHidden:NO];
        self.noResultsLabel = nil;        
    }
    else{
        [self.noResultsLabel setHidden:NO];
        [self.noResultsLabel setText: [NSString stringWithFormat:NSLocalizedString(@"NoVariationsLabelText", @""),self.meaning.meaning]];
        self.variationsTableView = nil;
    }
    
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- UITableView Datasource methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.meaning.variations.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *reuseIdentifier = @"VariationsCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    Meaning *meaning = [self.meaning.variations objectAtIndex:indexPath.row];
    cell.textLabel.text = meaning.meaning;
    cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"MeaningsSubtitleText", @""),(long)meaning.since, (long)meaning.frequency];
    
    
    return cell;
}

#pragma mark- UITableView Delegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44.0;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString *headerIdentifier = @"VariationsHeaderIdentifier";
    UITableViewCell *headerView = [tableView dequeueReusableCellWithIdentifier:headerIdentifier];
    
    headerView.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"VariationsHeaderText", @""),self.meaning.meaning];
    
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    Meaning *meaning = [self.meaning.variations objectAtIndex:indexPath.row];
    
    CGFloat titleHeight = [self heightForText:[meaning meaning] withFont:labelBoldTextFont];
    NSString *subTitleText = [NSString stringWithFormat:NSLocalizedString(@"MeaningsSubtitleText", @""),(long)meaning.since, (long)meaning.frequency];
    CGFloat subtitleHeight = [self heightForText:subTitleText withFont:descriptionTextFont];
    
    return titleHeight + subtitleHeight + 2*cellVerticalPadding;
    
}

#pragma mark - Helper method


-(CGFloat) heightForText:(NSString *) text withFont:(UIFont *) font {
    NSDictionary *attributes = @{NSFontAttributeName: font};
    
    CGRect rect = [text boundingRectWithSize:CGSizeMake(self.variationsTableView.frame.size.width-cellHorizontalWaste, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    return rect.size.height;
}


@end
