//
//  CSDetailsViewController.h
//  CollegeChef
//
//  Created by Sahil Diwan.
//

@class Recipe;

@protocol CSFoundVieControllerDelegate;

@interface CSDetailsViewController : UIViewController
- (void)setSelectedRecipe:(Recipe*)selectedRecipe;

@property(nonatomic, weak) id <CSFoundVieControllerDelegate> delegate;

@end
