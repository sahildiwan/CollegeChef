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
@property(nonatomic, strong) NSString* recipeIngredients;
@property(nonatomic, strong) NSString* recipeDirections;

@property(nonatomic, weak) IBOutlet UILabel* name;
@property(nonatomic, strong) IBOutlet UILabel* ingredients;
@property(nonatomic, strong) IBOutlet UILabel* directions;

@property(nonatomic, weak) id <CSFoundViewControllerDelegate> delegate;

@end

