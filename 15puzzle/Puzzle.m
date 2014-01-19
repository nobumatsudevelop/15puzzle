//
//  Puzzle.m
//  15puzzle
//
//  Created by 松井延佳 on 2014/01/19.
//  Copyright (c) 2014年 trisoft-house. All rights reserved.
//

#import "Puzzle.h"

#define BTN_START 0

@interface Puzzle ()

@end

@implementation Puzzle

//ラベルの作成
- (UILabel*)makeLabel:(CGPoint)pos text:(NSString*)text font:(UIFont*)font {
    UILabel* label=[[UILabel alloc] init];
#ifdef IS_OS_7_OR_LATER
    CGSize size=[text sizeWithAttributes:@{NSFontAttributeName:font}];
#else
    CGSize size=[text sizeWithFont:font];
#endif
    CGRect rect=CGRectMake(pos.x, pos.y, size.width, size.height);
    
    [label setText:text];
    [label setFont:font];
    [label setFrame:rect];
    [label setTextColor:[UIColor blackColor]];
    
    return label;
}
//文字列のサイズにラベルを合わせる
- (UILabel*)resizeLabel:(UILabel*)label {
    CGRect frame=label.frame;
#ifdef IS_OS_7_OR_LATER
    frame.size=[label.text sizeWithAttributes:@{NSFontAttributeName:[label font]}];
#else
    frame.size=[label.text sizeWithFont:[label font]];
#endif
    [label setFrame:frame];
    
    return label;
}

//ボタンの作成
- (UIButton*)makeButton:(CGRect)rect text:(NSString*)text tag:(int)tag{
    UIButton* button=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setFrame:rect];
    [button setTitle:text forState:UIControlStateNormal];
    [button setTag:tag];
    [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

//ボタンイベント処理
- (IBAction)clickButton:(UIButton*)sender {
    if (sender.tag==BTN_START) {
        [_label setText:@""];
        [self resizeLabel:_label];
        
        [_button setTitle:@"" forState:UIControlStateNormal];
        [_button setEnabled:NO];
        
        _clearFlg=NO;
        [self initPieces];
        [self dispPieces];
    }
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //ラベル表示
    _label=[self makeLabel:CGPointMake(0, 40) text:@"" font:[UIFont systemFontOfSize:16]];
    [self.view addSubview:_label];

    //ボタン表示
    _button=[self makeButton:CGRectMake(0, 60, 90, 40) text:@"" tag:BTN_START];
    [self.view addSubview:_button];
    [_button setTitle:@"" forState:UIControlStateNormal];
    [_button setEnabled:NO];
    
    //パズルボードの表示
    int posX,posY;
    _boardView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"board.png"]];

    posX=(int)(self.view.frame.size.width/2-_boardView.frame.size.width/2);
    posY=(int)(self.view.frame.size.height/2-_boardView.frame.size.height/2);

    [_boardView setFrame:CGRectMake(posX, posY, 240, 240)];
    [self.view addSubview:_boardView];
    
    //パズルピース表示データの読み込み
    _pieces=[NSMutableArray array];
    
    UIImage* image=[UIImage imageNamed:@"pazzle15.png"];
    CGRect rectIdx;
    CGImageRef clipRef;
    
    for (int i=0; i<kPieceCount; i++) {
        posX=(i%4)*kPieceWidth;
        posY=((int)(i/4))*kPieceHeight;
        
        rectIdx=CGRectMake(posX, posY, kPieceWidth, kPieceHeight);
        clipRef=CGImageCreateWithImageInRect([image CGImage], rectIdx);
        
        Piece* piece=[[Piece alloc] init];
        piece.pieceImage=[UIImage imageWithCGImage:clipRef];
        piece.num=i;
        [_pieces addObject:piece];
    }

    _clearFlg=NO;
    //ピースのシャッフル
    [self initPieces];
    //パズルピースの表示
    [self dispPieces];
}

//ピースのシャッフル
- (void)initPieces {
    for (int i=0; i<kShuffleCount; i++) {
        int index1=arc4random()%kPieceCount;
        int index2=arc4random()%kPieceCount;
        NSObject* tmp=_pieces[index1];
        _pieces[index1]=_pieces[index2];
        _pieces[index2]=tmp;
    }
}

//パズルピースの表示
- (void)dispPieces {
    int posX, posY;
    CGRect rect;
    for (int i=0; i<kPieceCount; i++) {
        posX=(i%4)*kPieceWidth;
        posY=((int)(i/4))*kPieceHeight;
        
        rect=CGRectMake(posX, posY, kPieceWidth, kPieceHeight);
        UIImage* image=[[_pieces objectAtIndex:i] pieceImage];
        UIImageView* imageView=[[UIImageView alloc] initWithImage:image];
        [imageView setFrame:rect];
        
        [_boardView addSubview:imageView];
    }
    [_boardView setNeedsDisplay];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//タッチ開始の処理
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    int touchIdx=-1;
    int posX,posY;
    CGPoint touchPos;
    CGRect rect;
    bool moveFlg=NO;
    
    if (_clearFlg==YES) {
        //クリア済み　ピースを動かさない
        return;
    }
    
    NSArray* objects=[touches allObjects];
    touchPos=[[objects firstObject] locationInView:_boardView];
    
    //何番目をクリックしたのかチェック
    for (int i=0; i<kPieceCount; i++) {
        posX=(i%kPieceCol)*kPieceWidth;
        posY=((int)(i/kPieceRow))*kPieceHeight;
        rect=CGRectMake(posX, posY, kPieceWidth, kPieceHeight);
        
        if (CGRectContainsPoint(rect, touchPos)) {
            touchIdx=i;
        }
        
    }
    
    //動かせるかチェック
    if (touchIdx!=-1) {
        int numUp=((int)touchIdx/kPieceRow==0) ? -1 : (touchIdx - kPieceCol);
        int numLeft=(touchIdx%kPieceCol==0) ? -1 : (touchIdx - 1);
        int numRight=(touchIdx%kPieceCol==kPieceRow-1) ? -1 : (touchIdx + 1);
        int numDown=((int)touchIdx/kPieceRow==kPieceCol-1) ? -1 : (touchIdx + kPieceCol);
        
        if (numUp!=-1 && moveFlg==NO) {
            if ([[_pieces objectAtIndex:numUp] num]==kPieceCount-1) {
                [self swapNum:_pieces idx1:touchIdx idx2:numUp];
                moveFlg=YES;
            }
        }
        
        if (numLeft!=-1 && moveFlg==NO) {
            if ([[_pieces objectAtIndex:numLeft] num]==kPieceCount-1) {
                [self swapNum:_pieces idx1:touchIdx idx2:numLeft];
                moveFlg=YES;
            }
        }
        
        if (numRight!=-1 && moveFlg==NO) {
            if ([[_pieces objectAtIndex:numRight] num]==kPieceCount-1) {
                [self swapNum:_pieces idx1:touchIdx idx2:numRight];
                moveFlg=YES;
            }
        }

        if (numDown!=-1 && moveFlg==NO) {
            if ([[_pieces objectAtIndex:numDown] num]==kPieceCount-1) {
                [self swapNum:_pieces idx1:touchIdx idx2:numDown];
                moveFlg=YES;
            }
        }
    }
    
    //動かした場合のみ再描画
    if (moveFlg) {
        [self dispPieces];
    }

    //クリア判定
    if ([self isClear]) {
        _clearFlg=YES;
        [_label setText:@"Clear!"];
        [self resizeLabel:_label];
        [_button setTitle:@"RESTART" forState:UIControlStateNormal];
        [_button setEnabled:YES];
    }
    
}

//ピースの順番を入れ替え
- (void)swapNum:(NSMutableArray*)objs idx1:(int)idx1 idx2:(int)idx2 {
//    NSObject* tmp=[objs objectAtIndex:idx1];
//    [objs replaceObjectAtIndex:idx1 withObject:[objs objectAtIndex:idx2]];
//    [objs replaceObjectAtIndex:idx2 withObject:tmp];
    [objs exchangeObjectAtIndex:idx1 withObjectAtIndex:idx2];
}

//クリアしてるかどうか判定
- (BOOL)isClear {
    BOOL clear=YES;
    for (int i=0; i<[_pieces count]; i++) {
        Piece* obj=[_pieces objectAtIndex:i];
        if ([obj num]!=i) {
            clear=NO;
            break;
        }
    }
    return clear;
}
@end
