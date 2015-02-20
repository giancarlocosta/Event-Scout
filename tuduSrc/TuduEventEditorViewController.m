//
//  TuduEventEditorViewController.m
//  tudu
//
//  Created by Gian Costa on 9/20/14.
//
//

#import "TuduEventEditorViewController.h"

@interface TuduEventEditorViewController ()

@end

@implementation TuduEventEditorViewController

- (id)initWithEvent:(PFObject *)aEvent {
    self = [super init];
    if (self) {
        self.event = aEvent;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Update!" style:UIBarButtonItemStyleBordered target:self action:@selector(updateButtonAction:)];
    
    // Done button on keyboard
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStyleBordered target:self
                                                                  action:@selector(dismissKeyboard)];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
    
    self.scroll.delegate = self;
    self.scroll = [[UIScrollView alloc]
                   initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.scroll.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height * 2);
    [self.scroll setBackgroundColor:[ThemeAndStyle blueGrayColor]];
    
	self.titleTextField.text = self.event[kTuduEventTitleKey];
    self.dateTextField.text = self.event[kTuduEventDateKey];
    self.locationTextField.text = self.event[kTuduEventLocationKey];
    self.eventTypeTextField.text = self.event[kTuduEventTypeKey];
    self.privacyTypeTextField.text = self.event[kTuduEventPrivacyTypeKey];
    
    
    
    /*
     * Setup the Description sections
     *
     */
    
    self.descriptionContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                         self.privacyTypeTextField.frame.origin.y + self.privacyTypeTextField.frame.size.height + 40,
                                                                         self.view.frame.size.width,
                                                                         60.f)];
    
    self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.descriptionContainer.frame.size.width, 20)];
    self.descriptionLabel.text = @"Description";
    self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
    self.descriptionLabel.textColor = [ThemeAndStyle salmonColor];
    
    self.descriptionContentTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 25, self.descriptionContainer.frame.size.width - 2 * 10, 400)];
    self.descriptionContentTextView.text = self.event[kTuduEventDescriptionKey];
    self.descriptionContentTextView.inputAccessoryView = keyboardDoneButtonView;
    self.descriptionContentTextView.font = [UIFont fontWithName:@"Arial" size:14.0f];
    self.descriptionContentTextView.backgroundColor = [UIColor colorWithRed:0.41 green:0.49f blue:0.59f alpha:0.5f];
    self.descriptionContentTextView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    self.descriptionContentTextView.spellCheckingType = UITextSpellCheckingTypeYes;
    self.descriptionContentTextView.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    self.descriptionContentTextView.delegate = self;
    self.descriptionContentTextView.textColor = [UIColor lightGrayColor];
    //[self.descriptionContentTextView setLineBreakMode:UILineBreakModeWordWrap];
    //self.descriptionContentTextView.numberOfLines = 0;

    
    //[self resizeLabel:self.descriptionContentLabel];
    
    [self.descriptionContainer addSubview:self.descriptionLabel];
    [self.descriptionContainer addSubview:self.descriptionContentTextView];
    
    self.containerView.frame = CGRectMake(0, 0, self.containerView.frame.size.width, self.containerView.frame.size.height);
    [self.scroll addSubview:self.containerView];
    [self.scroll addSubview:self.descriptionContainer];
    
    // Readjust scroll view size
    //self.scroll.contentSize = CGSizeMake(self.view.frame.size.width, self.descriptionContainer.frame.origin.y + self.descriptionContainer.frame.size.height);
    
    [self.view addSubview:self.scroll];
}


-(void)updateButtonAction:(id)sender
{
    NSLog(@"Update");
    
    NSDictionary *eventDetails = @{ @"eventTitle" : self.titleTextField.text,
                                    @"eventLocation" : self.locationTextField.text,
                                    @"eventDate" : self.dateTextField.text,
                                    @"eventType" : self.eventTypeTextField.text,
                                    @"eventPrivacyType" : self.privacyTypeTextField.text,
                                    @"eventDescription" : self.descriptionContentTextView.text,
                                    //@"eventInviteList" : (NSArray *)self.inviteList,
                                    //@"userList" : (NSArray *)self.inviteObjects,
                                    };
    
    [Utility updateEventInBackground:eventDetails event:self.event block:^(BOOL succeeded, NSError *error) {
        if (!error) {
            
        } else {
        }
    }];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}


-(void)dismissKeyboard {
    NSLog(@"dismissKeyboardMethod");
    [self.descriptionContentTextView resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
