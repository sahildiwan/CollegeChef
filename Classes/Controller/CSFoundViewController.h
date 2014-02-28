//
//  CSFoundViewController.h
//  CollegeChef
//
//  Created by Sahil Diwan.
//

@class Recipe;
@protocol CSFoundViewControllerDelegate;

@interface CSFoundViewController : UIViewController
- (void)setSelectedRecipe:(Recipe*)selectedRecipe;

@property(nonatomic, weak) NSString* recipeName;
@property(nonatomic, weak) NSString* recipeIngredients;
@property(nonatomic, weak) NSString* recipeDirections;

@property(nonatomic, weak) IBOutlet UILabel* name;
@property(nonatomic, weak) IBOutlet UILabel* ingredients;
@property(nonatomic, weak) IBOutlet UILabel* directions;

@property(nonatomic, weak) id <CSFoundViewControllerDelegate> delegate;

@end

