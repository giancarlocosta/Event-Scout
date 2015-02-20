//
//  TuduEventCreatorViewController.m
//  tudu
//
//  Created by Gian Costa on 9/1/14.
//
//

#import "TuduEventCreatorViewController.h"
#import "TuduFriendsListViewController.h"
#import "TuduFollowFriendsListViewController.h"
#import "TuduInviteFriendsListViewController.h"
#import "TuduNextButtonItem.h"
#import "TuduAppDelegate.h"
#import "TuduReviewEventCreationViewController.h"
#import "TuduInviteDescriptionViewController.h"
#import "GlassView.h"
#import "ThemeAndStyle.h"

@interface TuduEventCreatorViewController ()
@end

@implementation TuduEventCreatorViewController
@synthesize containerView;
@synthesize titleLabel;
@synthesize locationLabel;
@synthesize dateLabel;
@synthesize eventTypeLabel;
@synthesize privacyTypeLabel;

@synthesize titleTextField;
@synthesize locationTextField;
@synthesize dateTextField;
@synthesize eventTypeTextField;
@synthesize privacyTypeTextField;

@synthesize datePicker;
@synthesize eventTypePicker;
@synthesize privacyTypePicker;

- (void)viewDidLoad
{
	[super viewDidLoad];
    
    // Removes keyboard upon touching outside of it
	[self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
    
    // Add the Next button/Title to the navigation bar of the navigation controller that this controller is in
    [self.navigationItem setTitle:@"Event Details"];
	self.navigationItem.rightBarButtonItem = [[TuduNextButtonItem alloc] initWithTarget:self action:@selector(nextButtonAction:)];
    
    // Configure/layout all of the labels and user input controls
    [self setupLabelsAndTextFields];
    
    // Place all controls in a container view
    self.containerView = [[UIView alloc]
                          initWithFrame:CGRectMake(0,
                                                   64, // StatusBar height + 44 of the navbar height?
                                                   self.view.frame.size.width,
                                                   self.view.frame.size.height
                                                   - (self.tabBarController.tabBar.frame.size.height
                                                      + 64))];
    [self.containerView setBackgroundColor:[ThemeAndStyle blueGrayColor]];
    
    [[self containerView] addSubview:self.titleLabel];
    [[self containerView] addSubview:self.titleTextField];
    [[self containerView] addSubview:self.locationLabel];
    [[self containerView] addSubview:self.locationTextField];
    [[self containerView] addSubview:self.dateLabel];
    [[self containerView] addSubview:self.dateTextField];
    [[self containerView] addSubview:self.eventTypeLabel];
    [[self containerView] addSubview:self.eventTypeTextField];
    [[self containerView] addSubview:self.privacyTypeLabel];
    [[self containerView] addSubview:self.privacyTypeTextField];
    
    [self.view addSubview:self.containerView];
}



/*//////////////////////////////////////////////////////////////////////////////////////////
 *
 * Setup/Layout all lables & user input controls
 *
 */
-(void)setupLabelsAndTextFields
{
    float labelWidth = self.view.frame.size.width;
    
	//Initialize Event Type Options
	self.eventTypeOptions = @[kTuduEventTypeKickBack,
                              kTuduEventTypeOutdoor,
                              kTuduEventTypeDine,
                              kTuduEventTypeProfessional,
                              kTuduEventTypePickup];
    
	//Initialize Privacy Type Options
	self.privacyTypeOptions = @[kTuduEventPrivacyTypePublic, kTuduEventPrivacyTypeHostInvite, kTuduEventPrivacyTypeHostGuestInvite];
    
    
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStyleBordered target:self
                                                                  action:@selector(doneClicked:)];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
    
	// Create Controls
    // Title
	self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, TITLE_LBL_Y_POS, labelWidth, LABEL_HEIGHT)];
	[self.titleLabel setText:@"Event Title"];
    [self.titleLabel setTextColor:[ThemeAndStyle lightTurquoiseColor]];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    self.titleTextField = [[UITextField alloc]initWithFrame:CGRectMake(60, TITLE_TF_Y_POS, TF_WIDTH, TF_HEIGHT)];
    self.titleTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.titleTextField.autocapitalizationType = UITextAutocapitalizationTypeWords; // capitalize beginnings of words
    self.titleTextField.spellCheckingType = UITextSpellCheckingTypeYes;
    self.titleTextField.inputAccessoryView = keyboardDoneButtonView;
    
    // Location
    self.locationLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, LOC_LBL_Y_POS, labelWidth, LABEL_HEIGHT)];
	[self.locationLabel setText:@"Location"];
    [self.locationLabel setTextColor:[ThemeAndStyle lightTurquoiseColor]];
    self.locationLabel.textAlignment = NSTextAlignmentCenter;
    
    self.locationTextField = [[UITextField alloc]initWithFrame:CGRectMake(60, LOC_TF_Y_POS, TF_WIDTH, TF_HEIGHT)];
    self.locationTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.locationTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    self.locationTextField.inputAccessoryView = keyboardDoneButtonView;
    
    // Date
    self.dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, DATE_LBL_Y_POS, labelWidth, LABEL_HEIGHT)];
	[self.dateLabel setText:@"Date & Time"];
    [self.dateLabel setTextColor:[ThemeAndStyle lightTurquoiseColor]];
    self.dateLabel.textAlignment = NSTextAlignmentCenter;
	
	self.dateTextField = [[UITextField alloc]initWithFrame:CGRectMake(60, DATE_TF_Y_POS, TF_WIDTH, TF_HEIGHT)];
    self.dateTextField.borderStyle = UITextBorderStyleRoundedRect;
    
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(60, 120, labelWidth, LABEL_HEIGHT)];
	self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
	self.datePicker.minimumDate = [[ NSDate alloc ] initWithTimeIntervalSinceNow: (NSTimeInterval) 0 ];
	self.datePicker.hidden = NO;
	self.datePicker.date = [NSDate date];
	[self.datePicker addTarget:self action:@selector(getSelection:) forControlEvents:UIControlEventValueChanged];
    self.dateTextField.inputView = self.datePicker;
    self.dateTextField.inputAccessoryView = keyboardDoneButtonView;
    
    // Description
    /*
    self.descriptionLabel= [[UILabel alloc]initWithFrame:CGRectMake(0, DESC_LBL_Y_POS, labelWidth, LABEL_HEIGHT)];
	[self.descriptionLabel setText:@"Description"];
    self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
    
    self.descriptionTextView = [[UITextView alloc]initWithFrame:CGRectMake(60, DESC_TF_Y_POS, TF_WIDTH, TF_HEIGHT)];
    self.descriptionTextView.backgroundColor = [UIColor clearColor];
    self.descriptionTextView.spellCheckingType = UITextSpellCheckingTypeYes;
    self.descriptionTextView.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    self.descriptionTextView.delegate = self;
    self.descriptionTextView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    self.descriptionTextView.inputAccessoryView = keyboardDoneButtonView;
     */
    
    // Event Type
    self.eventTypeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, EVTYPE_LBL_Y_POS, labelWidth, LABEL_HEIGHT)];
	[self.eventTypeLabel setText:@"Event Type"];
    [self.eventTypeLabel setTextColor:[ThemeAndStyle lightTurquoiseColor]];
    self.eventTypeLabel.textAlignment = NSTextAlignmentCenter;
    
    self.eventTypeTextField = [[UITextField alloc]initWithFrame:CGRectMake(60, EVTYPE_TF_Y_POS, TF_WIDTH, TF_HEIGHT)];
    [self.eventTypeTextField setText:@"Choose.."];
    self.eventTypeTextField.textColor = [UIColor lightGrayColor];
    self.eventTypeTextField.textAlignment = NSTextAlignmentCenter;
    self.eventTypeTextField.borderStyle = UITextBorderStyleRoundedRect;
    
    self.eventTypePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(60, 240, labelWidth, LABEL_HEIGHT)];
	self.eventTypePicker.dataSource = self;
    self.eventTypePicker.delegate = self;
    self.eventTypePicker.showsSelectionIndicator = YES;
    self.eventTypeTextField.inputView = self.eventTypePicker;
    self.eventTypeTextField.inputAccessoryView = keyboardDoneButtonView;
    //[self.eventTypeTextField becomeFirstResponder];
    
    // Privacy Type
    self.privacyTypeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, PRTYPE_LBL_Y_POS, labelWidth, LABEL_HEIGHT)];
	[self.privacyTypeLabel setText:@"Privacy Type"];
    [self.privacyTypeLabel setTextColor:[ThemeAndStyle lightTurquoiseColor]];
    self.privacyTypeLabel.textAlignment = NSTextAlignmentCenter;
    
    self.privacyTypeTextField = [[UITextField alloc]initWithFrame:CGRectMake(60, PRTYPE_TF_Y_POS, TF_WIDTH, TF_HEIGHT)];
    [self.privacyTypeTextField setText:kTuduEventPrivacyTypeHostInvite];
    self.privacyTypeTextField.textColor = [UIColor lightGrayColor];
    self.privacyTypeTextField.textAlignment = NSTextAlignmentCenter;
    self.privacyTypeTextField.borderStyle = UITextBorderStyleRoundedRect;
    
    self.privacyTypePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(60, 300, labelWidth, LABEL_HEIGHT)];
	self.privacyTypePicker.dataSource = self;
	self.privacyTypePicker.delegate = self;
    self.privacyTypePicker.showsSelectionIndicator = YES;
    self.privacyTypeTextField.inputView = self.privacyTypePicker;
    self.privacyTypeTextField.inputAccessoryView = keyboardDoneButtonView;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*//////////////////////////////////////////////////////////////////////////////////////////
 *
 * UIPickerViewDelegate
 *
 */
// The number of columns of data
- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (int)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	if(pickerView == self.eventTypePicker){
		return self.eventTypeOptions.count;
	}
	else if(pickerView == self.privacyTypePicker){
		return self.privacyTypeOptions.count;
	}
    else
        return 10;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(pickerView == self.eventTypePicker){
		return self.eventTypeOptions[row];
	}
	else if(pickerView == self.privacyTypePicker){
		return self.privacyTypeOptions[row];
	}
    else
        return @"tuduError";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(pickerView == self.eventTypePicker)
        [self.eventTypeTextField setText:self.eventTypeOptions[row]];
    else if(pickerView == self.privacyTypePicker)
        [self.privacyTypeTextField setText:self.privacyTypeOptions[row]];
}



/*//////////////////////////////////////////////////////////////////////////////////////////
 *
 * When datePicker value is changed
 *
 */
-(void)getSelection:(id)sender
{
    NSLocale *usLocale = [[NSLocale alloc]
                          initWithLocaleIdentifier:@"en_US"];
    
    NSDate *pickerDate = [self.datePicker date];
    NSString *selectionString = [[NSString alloc]
                                 initWithFormat:@"%@",
                                 [pickerDate descriptionWithLocale:usLocale]];
    [self.dateTextField setText:selectionString];
}

- (void)doneClicked:(id)sender
{
    NSLog(@"Done Clicked.");
    [self.view endEditing:YES];
}



/*//////////////////////////////////////////////////////////////////////////////////////////
 *
 * When NEXT button is clicked
 *
 */
-(void)nextButtonAction:(id)sender
{
    /*
    // Force user to fill all fields
    if([self.privacyTypeTextField.text  isEqual: @"Choose.."] ||
       [self.eventTypeTextField.text    isEqual: @"Choose.."] ||
       [self.titleTextField.text        isEqual: @""] ||
       [self.dateTextField.text         isEqual: @""] ||
       [self.locationTextField.text     isEqual: @""])
    {
        UIView *notifyView = [[UIView alloc] initWithFrame:CGRectMake(50, 50, self.view.frame.size.width/2, self.view.frame.size.width/2)];
        
        return;
    }
     */
    
    BOOL isPublic = NO;
    // Skip to Review View Controller if event is Public
    if([self.privacyTypeTextField.text isEqual:kTuduEventPrivacyTypePublic]) {
        NSLog(@"--Public");
        isPublic = YES;
    }
    
    TuduInviteDescriptionViewController *inviteDescriptionViewController = [[TuduInviteDescriptionViewController alloc] init];
    inviteDescriptionViewController.inviteList = nil;
    [self.navigationController pushViewController:inviteDescriptionViewController animated:YES];

}



/*//////////////////////////////////////////////////////////////////////////////////////////
 *
 * When LOGOUT button is clicked
 *
 */
- (void) logoutButtonAction:(id)sender  {
    [PFUser logOut]; // Log out
    
    // Return to Login view controller
    [(TuduAppDelegate*)[[UIApplication sharedApplication] delegate] presentLoginViewControllerAnimated:NO];

}

@end