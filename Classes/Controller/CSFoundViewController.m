//
//  CSFoundViewController.m
//  CollegeChef
//
//  Created by Sahil Diwan.
//

#import "CSSearchViewController.h"

#import "CSFoundViewController.h"
#import "CSFoundViewControllerDelegate.h"

#import "Ingredients.h"
#import "Recipe.h"
#import "Picture.h"

#import "CSCoreDataService.h"

@interface CSFoundViewController ()
@property(nonatomic, weak) IBOutlet UIImageView* pictureImageView;
@end

@implementation CSFoundViewController {
    Recipe* _selectedRecipeItem;
    Ingredients* _selectedIngredientItem;
}

#pragma mark IBActions
- (IBAction)save:(id)sender {
	[self _updateRecipeForSave];
}

#pragma mark Public
- (void)setSelectedRecipe:(Recipe*)selectedRecipe {
	_selectedRecipeItem = selectedRecipe;
}

#pragma mark Private (UI)
- (void)_updateUIForRecipe {
    _name.text = [_recipeName description];
    NSLog(@"Recipe Name: %@", _name.text);
    _ingredients.text = [_recipeIngredients description];
    NSLog(@"Recipe Ingredients: %@", _ingredients.text);
    _directions.text = [_recipeDirections description];
    NSLog(@"Recipe Directions: %@", _directions.text);
}
    
#pragma mark Private (Object Management)
- (void)_updateRecipeForSave {
    if(_selectedRecipeItem == nil) {
        _selectedRecipeItem = [NSEntityDescription insertNewObjectForEntityForName:@"Recipe" inManagedObjectContext:[CSCoreDataService sharedCoreDataService].mainQueueContext];
    }
    if([_name.text length] > 0) {
        _selectedRecipeItem.name = _name.text;
    }
    if([_ingredients.text length] > 0) {
        _selectedRecipeItem.ingredient = _ingredients.text;
        _selectedIngredientItem.ingredient = _ingredients.text;
    }
    if([_directions.text length] > 0) {
        _selectedRecipeItem.directions = _directions.text;
	}
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
            NSLog(@"Save was successful!");
        }
        else {
            NSLog(@"Save failed :^(");
        }
    }];
}

#pragma mark View Management
- (void)viewWillAppear:(BOOL)animated {
    [self _updateUIForRecipe];
}

#pragma mark View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

@end
