//
//  TuduEventCreatorViewController.h
//  Tudu
//
//

//Fore postioning and sizing of UIViews to be placed on screen
#define X 10
#define LABEL_HEIGHT 20
#define LABEL_WIDTH 200
#define TF_HEIGHT 20
#define TF_WIDTH 200
#define LABEL_TF_GAP 5
#define SECTION_GAP 15

#define TITLE_LBL_Y_POS 20
#define TITLE_TF_Y_POS (TITLE_LBL_Y_POS + LABEL_HEIGHT + LABEL_TF_GAP)

#define DATE_LBL_Y_POS (TITLE_TF_Y_POS + TF_HEIGHT + SECTION_GAP)
#define DATE_TF_Y_POS (DATE_LBL_Y_POS + LABEL_HEIGHT + LABEL_TF_GAP)

#define LOC_LBL_Y_POS (DATE_TF_Y_POS + TF_HEIGHT + SECTION_GAP)
#define LOC_TF_Y_POS (LOC_LBL_Y_POS + LABEL_HEIGHT + LABEL_TF_GAP)

#define EVTYPE_LBL_Y_POS (LOC_TF_Y_POS + TF_HEIGHT + SECTION_GAP)
#define EVTYPE_TF_Y_POS (EVTYPE_LBL_Y_POS + LABEL_HEIGHT + LABEL_TF_GAP)

#define PRTYPE_LBL_Y_POS (EVTYPE_TF_Y_POS + TF_HEIGHT + SECTION_GAP)
#define PRTYPE_TF_Y_POS (PRTYPE_LBL_Y_POS + LABEL_HEIGHT + LABEL_TF_GAP)



@interface TuduEventCreatorViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>

@property (nonatomic, assign, getter = isFirstLaunch) BOOL firstLaunch;

@property (nonatomic, strong) NSArray *eventTypeOptions;
@property (nonatomic, strong) NSArray *privacyTypeOptions;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *locationLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *eventTypeLabel;
@property (nonatomic, strong) UILabel *privacyTypeLabel;

@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) UITextField *titleTextField;
@property (nonatomic, strong) UITextField *locationTextField;
@property (nonatomic, strong) UITextField *dateTextField;
@property (nonatomic, strong) UITextField *eventTypeTextField;
@property (nonatomic, strong) UITextField *privacyTypeTextField;

@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UIPickerView *eventTypePicker;
@property (nonatomic, strong) UIPickerView *privacyTypePicker;

-(void)setupLabelsAndTextFields;
//- (void) dismissKeyboard;

@end
