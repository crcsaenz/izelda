//
//  ZeldaHeroViewController.m
//  Zelda
//
//  Created by Cassidy Saenz on 6/9/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "ZeldaHeroViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>


#define HERO_DATA_NAME_KEY @"Hero Name"
#define HERO_DATA_IMAGE_PATH_KEY @"ImagePath"
#define HERO_DATA_HIGH_SCORE_KEY @"High Score"
#define HERO_DATA_QUEST_NUM_KEY @"Quest Number"

#define DEFAULT_HERO_IMAGE_FILE @"DefaultHero.png"


@interface ZeldaHeroViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *heroNameTextField;
@property (weak, nonatomic) IBOutlet UIImageView *heroImageView;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSURL *imageUrl;

@end


@implementation ZeldaHeroViewController

@synthesize questNumber = _questNumber;
@synthesize delegate = _delegate;
@synthesize heroNameTextField = _heroNameTextField;
@synthesize heroImageView = _heroImageView;
@synthesize name = _name;
@synthesize imageUrl = _imageUrl;

#pragma mark - Target/Action

- (IBAction)pickImage
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        if ([availableMediaTypes containsObject:(NSString *)kUTTypeImage]) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            picker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
            picker.allowsEditing = YES;
            picker.delegate = self;
            [self presentModalViewController:picker animated:YES];
        }
    }
}

- (IBAction)cancel
{
    [self.delegate zeldaHeroViewControllerDidCancel:self];
}

- (IBAction)saveHero
{
    // at least a name MUST be given
    NSString *name = ([self.name length]) ? self.name : @"NoName";
    NSURL *imageUrl = (self.imageUrl) ? self.imageUrl : [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"DefaultHero" ofType:@"png"]];
    [self.delegate zeldaHeroViewController:self
                             didChooseName:name
                               andImageUrl:imageUrl
                            forQuestNumber:self.questNumber];
}

#pragma mark - UIImagePickerControllerDelegate Methods

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.heroImageView.image = [info objectForKey:UIImagePickerControllerEditedImage];
    self.imageUrl = [info objectForKey:UIImagePickerControllerReferenceURL];
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate Methods

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.name = self.heroNameTextField.text;
    [self.heroNameTextField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.heroNameTextField resignFirstResponder];
    return YES;
}

#pragma mark - View Controller Lifecycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.heroImageView.image = [UIImage imageNamed:DEFAULT_HERO_IMAGE_FILE];
    self.heroNameTextField.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidUnload
{
    [self setHeroImageView:nil];
    [self setHeroNameTextField:nil];
    [super viewDidUnload];
}

#pragma mark - Autorotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
