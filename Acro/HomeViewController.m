//
//  HomeViewController.m
//  Acro
//
//  Created by Mostafijur Rahaman on 3/14/16.
//  Copyright © 2017 Mostafijur Rahaman. All rights reserved.
//

#import "HomeViewController.h"
#import "Constants.h"
#import "NetworkClient.h"
#import "MBProgressHUD.h"
#import "Acronym.h"
#import "Meaning.h"
#import "VariationsViewController.h"

@interface HomeViewController ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) Acronym *acronym;
@property (nonatomic, weak) IBOutlet UITableView *acronymTableView;
@property (nonatomic, weak) IBOutlet UITextField *textField;
@property (nonatomic, strong) NSCharacterSet *disallowedCharacters;;

@end

@implementation HomeViewController

#pragma mark- Life cycle methods
- (void)viewDidLoad {
    [super viewDidLoad];

    [self resetContent];
    
    // Only alpha-numeric characters are allowed.
    self.disallowedCharacters = [[NSCharacterSet alphanumericCharacterSet] invertedSet];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - UITextField delegate methods
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    // reset All content on screen
    [self resetContent];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // Textfield is disabled till user enters atleast one character.
    // Dismiss Keyboard on return
    [textField resignFirstResponder];
    if(![textField.text isEqualToString:@""]){
        
        [self fetchMeaningsForAcronym:textField.text];
    }
   
    return YES;
    
}

/*
 *delegate checks if there is any text and checks
  *  if text less than 30(MAXLENGTH), accept return key, accepts aonly alphabets and numeric charecters.
 
*/

-(BOOL)textField:(UITextField *) textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    
    
    return (newLength <= MAXLENGTH || ([string rangeOfString: @"\n"].location != NSNotFound)) && ([string rangeOfCharacterFromSet:self.disallowedCharacters].location == NSNotFound);
}

#pragma mark- UITableView Datasource methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.acronym.meanings.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *reuseIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    Meaning *meaning = [self.acronym.meanings objectAtIndex:indexPath.row];
    cell.textLabel.text = meaning.meaning;
    cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"MeaningsSubtitleText", @""),(long)meaning.since, (long)meaning.frequency];

    return cell;
}

#pragma mark- UITableView Delegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44.0;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    static NSString *headerIdentifier = @"HeaderIdentifier";
    UITableViewCell *headerView = [tableView dequeueReusableCellWithIdentifier:headerIdentifier];
    
    headerView.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"HeaderText", @""),self.textField.text];
    
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
   
    // Calculate height required for title text and subtitle text. Then add padding above and below.
    Meaning *meaning = [self.acronym.meanings objectAtIndex:indexPath.row];
    
    CGFloat titleHeight = [self heightForText:[meaning meaning] withFont:labelBoldTextFont];
    
     NSString *subTitleText = [NSString stringWithFormat:NSLocalizedString(@"MeaningsSubtitleText", @""),(long)meaning.since, (long)meaning.frequency];
    CGFloat subtitleHeight = [self heightForText:subTitleText withFont:descriptionTextFont];
   
    return titleHeight + subtitleHeight + 2 * cellVerticalPadding;
    
}


#pragma mark - Web service
-(void) fetchMeaningsForAcronym: (NSString *) acronym {
  
    NSDictionary *parameters = @{@"sf": acronym};
    
    // show loading indicator when web service is made
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[NetworkClient sharedManager] getResponseForURLString:BaseURL
                                                  Parameters:parameters
                                                     success:^(NSURLSessionDataTask *task, Acronym *acronym) {
                                                         
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.acronym = acronym;
        if (self.acronym && self.acronym.meanings.count > 0) {
            [self.acronymTableView setHidden:NO];
            [self.acronymTableView setContentOffset:CGPointZero animated:NO];
            [self.acronymTableView reloadData];
        }
        else{
            // showing no result alart
            [self showErrorAlertWithTitle:NSLocalizedString(@"NoResultsTitle", @"") message:[NSString stringWithFormat:NSLocalizedString(@"NoResultsMessage", @""),self.textField.text]];
        }
        
    }
    failure:^(NSURLSessionDataTask *task, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        // Showing the error alart
        [self showErrorAlertWithTitle:nil message:error.localizedDescription];
        
    }];
    
}

#pragma mark - Helper methods

-(void) resetContent{
    [self.acronymTableView setHidden:YES];
    self.acronym = nil;
}

-(CGFloat) heightForText:(NSString *) text withFont:(UIFont *) font {
    NSDictionary *attributes = @{NSFontAttributeName: font};
    
    CGRect rect = [text boundingRectWithSize:CGSizeMake(self.acronymTableView.frame.size.width - cellHorizontalWaste, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    return rect.size.height;
}

#pragma mark - Error handling

-(void)showErrorAlertWithTitle:(NSString *) title message:(NSString *) message{
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    
    [alertView show];
}


#pragma mark - Navigation

// preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller
    // Pass the selected object to the new view controller.

    if ([segue.identifier isEqualToString:@"VariationsIdentifier"]) {
        NSIndexPath *indexPath = [self.acronymTableView indexPathForSelectedRow];
        VariationsViewController *destinationViewController = [segue destinationViewController];
        destinationViewController.meaning = [self.acronym.meanings objectAtIndex:indexPath.row];
    }
    
}


@end
