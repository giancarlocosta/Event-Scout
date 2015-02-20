//
//  TuduEventEditorViewController.h
//  tudu
//
//  Created by Gian Costa on 9/20/14.
//
//

#import "TuduEventCreatorViewController.h"

@interface TuduEventEditorViewController : TuduEventCreatorViewController < UIScrollViewDelegate >

@property (nonatomic, strong) PFObject *event;
@property (nonatomic, strong) UIScrollView *scroll;
@property (nonatomic, strong) UIView *descriptionContainer;
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UITextView *descriptionContentTextView;
@property (nonatomic, strong) UIButton *editDescriptionButton;

- (id)initWithEvent:(PFObject *)aEvent;

@end
