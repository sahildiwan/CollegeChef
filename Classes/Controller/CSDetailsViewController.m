//
//  CSDetailsViewController.m
//  CollegeChef
//
//  Created by Sahil Diwan.
//

#import <MessageUI/MessageUI.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "CSDetailsViewController.h"

#import "Recipe.h"
#import "Picture.h"

#import "CSCoreDataService.h"

@interface CSDetailsViewController (/*Private*/) <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate, NSFetchedResultsControllerDelegate>
@property(nonatomic, weak) IBOutlet UIImageView* pictureImageView;
@property(nonatomic, weak) IBOutlet UIButton* pickPictureButton;
@property(nonatomic, weak) IBOutlet UIButton* clearPictureButton;

@property(nonatomic, weak) IBOutlet UILabel* name;
@property(nonatomic, weak) IBOutlet UILabel* ingredients;
@property(nonatomic, weak) IBOutlet UILabel* directions;
@end

@implementation CSDetailsViewController {
    NSMutableDictionary* _imageSourceMap;
    UIActionSheet* _addImageActionSheet;
    
    Recipe* _selectedRecipeItem;
}

#pragma mark IBActions
- (IBAction)openMail:(id)sender {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController* mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        [mailer setSubject:[NSString stringWithFormat:@"%@ recipe from CollegeChef", _selectedRecipeItem.name]];
        NSString* emailBody = [NSString stringWithFormat:@"<b>Ingredients:</b> %@ <br /> <br/> <b>Directions:</b> %@", _selectedRecipeItem.ingredient, _selectedRecipeItem.directions];
        [mailer setMessageBody:emailBody isHTML:YES];
        [self presentModalViewController:mailer animated:YES];
    }
    else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Failure" message:@"Your device does not support the composer sheet" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)pickPicture:(id)sender {
	//if(_clearPictureButton.hidden) {
		_addImageActionSheet = [[UIActionSheet alloc] initWithTitle:@"Pick Image Source" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
		_addImageActionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        
		// Determine what image sources are available
		BOOL isCameraAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
		BOOL isPhotoLibraryAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
		BOOL isSavedPhotosAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
		
		// Create a dictionary of available sources
		_imageSourceMap = [[NSMutableDictionary alloc] initWithCapacity:3];
		if(isCameraAvailable) {
			NSInteger buttonIndex = [_addImageActionSheet addButtonWithTitle:@"Camera"];
			[_imageSourceMap setValue:[NSNumber numberWithInt:UIImagePickerControllerSourceTypeCamera] forKey:[NSString stringWithFormat:@"%d", buttonIndex]];
		}
		if(isPhotoLibraryAvailable) {
			NSInteger buttonIndex = [_addImageActionSheet addButtonWithTitle:@"Photo Library"];
			[_imageSourceMap setValue:[NSNumber numberWithInt:UIImagePickerControllerSourceTypePhotoLibrary] forKey:[NSString stringWithFormat:@"%d", buttonIndex]];
		}
		if(isSavedPhotosAvailable) {
			NSInteger buttonIndex = [_addImageActionSheet addButtonWithTitle:@"Saved Photos"];
			[_imageSourceMap setValue:[NSNumber numberWithInt:UIImagePickerControllerSourceTypeSavedPhotosAlbum] forKey:[NSString stringWithFormat:@"%d", buttonIndex]];
		}
		if([_imageSourceMap count] > 0) {
			NSInteger cancelButtonIndex = [_addImageActionSheet addButtonWithTitle:@"Cancel"];
			[_addImageActionSheet setCancelButtonIndex:cancelButtonIndex];
			[_addImageActionSheet showInView:self.view];
		}
	//}
}

- (IBAction)clearPicture:(id)sender {
	UIActionSheet* clearPictureConfirmationSheet = [[UIActionSheet alloc] initWithTitle:@"Delete picture?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Picture" otherButtonTitles:nil];
	clearPictureConfirmationSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	
	[clearPictureConfirmationSheet showInView:self.view];
}

#pragma mark Public
- (void)setSelectedRecipe:(Recipe*)selectedRecipe {
	_selectedRecipeItem = selectedRecipe;
	
	if(self.isViewLoaded) {
		[self _updateUIForRecipe];
	}
}

#pragma mark Private (UI)
- (void)_updateUIForRecipe {
    _name.text = _selectedRecipeItem.name;
    _ingredients.text = _selectedRecipeItem.ingredient;
    _directions.text = _selectedRecipeItem.directions;
    
	if(_selectedRecipeItem.picture != nil) {
		_pictureImageView.image = [UIImage imageWithData:_selectedRecipeItem.picture.data];
		_clearPictureButton.hidden = NO;
	}
	else {
		_pictureImageView.image = nil;
		_clearPictureButton.hidden = YES;
	}
}

#pragma mark Private (Object Management)
- (void)_updateRecipeItemForSave {
	if(_pictureImageView.image == nil && _selectedRecipeItem.picture != nil) {
		[[_selectedRecipeItem managedObjectContext] deleteObject:_selectedRecipeItem.picture];
		_selectedRecipeItem.picture = nil;
	}
	else if(_pictureImageView.image != nil) {
		if(_selectedRecipeItem.picture == nil) {
			Picture* picture = [NSEntityDescription insertNewObjectForEntityForName:@"Picture" inManagedObjectContext:[_selectedRecipeItem managedObjectContext]];
			_selectedRecipeItem.picture = picture;
		}
		_selectedRecipeItem.picture.data = UIImagePNGRepresentation(_pictureImageView.image);
	}
    [[CSCoreDataService sharedCoreDataService] saveMainQueueContextWithCompletionHandler:^(BOOL success) {
        if(success) {
            NSLog(@"Picture save was successful!");
        }
        else {
            NSLog(@"Picture save failed :^(");
        }
    }];
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if(actionSheet == _addImageActionSheet) {
		if(buttonIndex != actionSheet.cancelButtonIndex) {
			UIImagePickerController* imagePickerController = [[UIImagePickerController alloc] init];
			imagePickerController.delegate = self;
			imagePickerController.sourceType = [[_imageSourceMap objectForKey:[NSString stringWithFormat:@"%d", buttonIndex]] intValue];
			_imageSourceMap = nil;
			imagePickerController.mediaTypes = [NSArray arrayWithObject:(NSString*)kUTTypeImage];
			imagePickerController.allowsEditing = YES;
            
			[self presentViewController:imagePickerController animated:YES completion:nil];
		}
		_addImageActionSheet = nil;
	}
	else {
		// This is the clear picture confirmation action sheet
		if(buttonIndex != actionSheet.cancelButtonIndex) {
			[UIView animateWithDuration:0.25f animations:^{
				_pictureImageView.transform = CGAffineTransformRotate(CGAffineTransformMakeScale(0.01f, 0.01f), M_PI);
			} completion:^(BOOL finished) {
				_pictureImageView.image = nil;
				_pictureImageView.transform = CGAffineTransformIdentity;
				_clearPictureButton.hidden = YES;
			}];
		}
	}
}

#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	// First check for an edited image
	UIImage* image = [info objectForKey:UIImagePickerControllerEditedImage];
	if(image == nil) {
		// If no edited image, get the original image
		image = [info objectForKey:UIImagePickerControllerOriginalImage];
	}
	_pictureImageView.image = image;
	_clearPictureButton.hidden = NO;
    
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    switch (result) {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
            break;
        default:
            break;
    }
    // Remove the mail view
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark View Management
- (void)viewWillDisappear:(BOOL)animated {
	[self _updateRecipeItemForSave];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark View Life Cycle
- (void)viewDidLoad {
	[super viewDidLoad];
	
	if(_selectedRecipeItem != nil) {
		[self _updateUIForRecipe];
	}
}

@end
