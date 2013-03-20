//
//  FormViewController.m
//  DropboxSampleApp
//
//  Created by Graham Cruse on 10/08/2012.
//  Copyright (c) 2012 Zendesk All rights reserved.
//

#import "FormViewController.h"

NSString *const emailLabel = @"Email:";
NSString *const emailSample = @"test@test.com";
NSString *const subjectLabel = @"Subject:";
NSString *const sendLabel = @"Send";
NSString *const successLabel = @"Ticket sent to server successfully";
NSString *const okLabel = @"OK";


@implementation FormViewController


#pragma mark prepare view


- (void) viewDidLoad
{
    email = [[UITextField alloc] initWithFrame:CGRectMake(0.0, 0.0, 230.0, 20.0)];
    email.font = [UIFont systemFontOfSize:16.0];
    email.keyboardType = UIKeyboardTypeEmailAddress;
    email.autocorrectionType = UITextAutocorrectionTypeNo;
    email.borderStyle = UITextBorderStyleNone;

    subject = [[UITextField alloc] initWithFrame:CGRectMake(0.0, 0.0, 230.0, 20.0)];
    subject.font = [UIFont systemFontOfSize:16.0];
    subject.borderStyle = UITextBorderStyleNone;
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init]  autorelease];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterLongStyle];
    subject.text = [dateFormatter stringFromDate:[NSDate date]];
    
    description = [[UITextView alloc] initWithFrame:CGRectMake(0.0, 0.0, 300.0, 140.0)];
    description.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    description.scrollEnabled = NO;
    description.delegate = self;
    
    // table cells are finite so declare here
    emailCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:nil];
    emailCell.textLabel.font = [UIFont systemFontOfSize:16];
    emailCell.textLabel.text = emailLabel;
    emailCell.textLabel.textColor = [UIColor darkGrayColor];
    emailCell.selectionStyle = UITableViewCellSelectionStyleNone;
    email.text = emailSample;
    emailCell.accessoryView = email;
    
    
    subjectCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                         reuseIdentifier:nil];
    subjectCell.textLabel.font = [UIFont systemFontOfSize:16];
    subjectCell.textLabel.text = subjectLabel;
    subjectCell.textLabel.textColor = [UIColor darkGrayColor];
    subjectCell.selectionStyle = UITableViewCellSelectionStyleNone;
    subjectCell.accessoryView = subject;
    
    
    descriptionCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                             reuseIdentifier:nil];
    descriptionCell.selectionStyle = UITableViewCellSelectionStyleNone;
    [descriptionCell.contentView addSubview:description];
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    UIBarButtonItem *b = [[UIBarButtonItem alloc] initWithTitle:sendLabel
                                                          style:(UIBarButtonItemStyleDone) 
                                                         target:self action:@selector(submitTicket)];
    self.navigationItem.rightBarButtonItem = b;
    [b release];
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [email becomeFirstResponder];
}


#pragma mark description resize delegate


- (void) textViewDidChange:(UITextView *)textView
{
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}


#pragma mark ticket submission

- (void) submitTicket
{
    [dropbox cancelRequest];
    [dropbox release];
    self.navigationItem.rightBarButtonItem.enabled = NO;
	dropbox = [[ZendeskDropbox alloc] initWithDelegate:self];
    [dropbox submitWithEmail:email.text subject:subject.text andDescription:description.text];
}


- (void) submissionDidFinishLoading:(ZendeskDropbox *)connection
{
	self.navigationItem.rightBarButtonItem.enabled = YES;
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil 
                                                    message:successLabel
                                                   delegate:nil 
                                          cancelButtonTitle:okLabel
                                          otherButtonTitles:nil];
	[alert show];
	[alert release];
    [dropbox release];
    dropbox = nil;
}


- (void) submission:(ZendeskDropbox *)connection didFailWithError:(NSError *)error
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[[error userInfo] valueForKey:NSLocalizedDescriptionKey] 
                                                    message:nil 
                                                   delegate:self 
                                          cancelButtonTitle:okLabel 
                                          otherButtonTitles:nil];
	[alert show];
	[alert release];
	self.navigationItem.rightBarButtonItem.enabled = YES;
    [dropbox release];
    dropbox = nil;
}


#pragma mark Table view methods


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 3;
}


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
            
        case 0: {
            return emailCell;
        }
        case 1: {
            
            return subjectCell;
            break;
        }
        case 2: {
            return descriptionCell;
        }
        default: {
            return nil;
        }
    }
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row > 1) {
        
        CGSize s = [description sizeThatFits:CGSizeMake(description.frame.size.width, 10000)];
        float dh = MAX(s.height, 115);
        description.frame = CGRectMake(description.frame.origin.x, 
                                       description.frame.origin.y, 
                                       description.frame.size.width, 
                                       dh);
        return dh;
    }
	return 44.0;
}


#pragma mark misc

- (void) viewWillDisappear:(BOOL)animated
{
    if (![self.navigationController.viewControllers containsObject:self]) {
        // view is being removed from the navigation stack, cancel any requests in progress
        [dropbox cancelRequest];
    }
    [super viewWillDisappear:animated];
}


- (void) dealloc
{
    [dropbox release];
	[description release];
	[email release];
	[subject release];
    [emailCell release];
    [subjectCell release];
    [descriptionCell release];
    [super dealloc];
}


@end
