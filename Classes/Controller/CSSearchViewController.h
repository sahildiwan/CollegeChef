//
//  CSSearchViewController.h
//  CollegeChef
//
//  Created by Sahil Diwan.
//

@interface CSSearchViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
    NSMutableArray* _objects;
    NSMutableArray* _textCells;
    NSMutableArray* _recipes;
}

@property(nonatomic, strong) NSMutableArray* recipeTitle;
@property(nonatomic, strong) NSMutableArray* recipeImageUrl;
@property(nonatomic, strong) NSMutableArray* recipeDirections;
@property(nonatomic, strong) NSMutableArray* recipeIngredients;

@property(nonatomic, weak) IBOutlet UIBarButtonItem* doneButton;
@property(nonatomic, weak) IBOutlet UIBarButtonItem* editButton;
@property(nonatomic, weak) IBOutlet UITableView* ingredientsTable;

@end
