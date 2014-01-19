//
//  Puzzle.h
//  15puzzle
//
//  Created by 松井延佳 on 2014/01/19.
//  Copyright (c) 2014年 trisoft-house. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Piece.h"

#define kPieceCol (4)
#define kPieceRow (4)
#define kPieceCount (kPieceCol * kPieceRow)

#define kPieceWidth (60)
#define kPieceHeight (60)

#define kShuffleCount (100)

@interface Puzzle : UIViewController {
    UIImageView* _boardView;
    NSMutableArray* _pieces;
    
    UILabel* _label;
    UIButton* _button;
    
    BOOL _clearFlg;
}

@end
