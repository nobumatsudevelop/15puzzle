//
//  Piece.h
//  15puzzle
//
//  Created by 松井延佳 on 2014/01/19.
//  Copyright (c) 2014年 trisoft-house. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Piece : NSObject {
    UIImage* _pieceImage;
    int _num;
}
@property (nonatomic) UIImage* pieceImage;
@property (nonatomic) int num;
@end
