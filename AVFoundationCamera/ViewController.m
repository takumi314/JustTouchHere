//
//  ViewController.m
//  AVFoundationCamera
//
//  Created by NishiokaKohei on 2016/08/14.
//  Copyright © 2016年 Kohei. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()
@property (nonatomic, strong) AVCaptureStillImageOutput *imageOutput;
@property (nonatomic, strong) IBOutlet UIView *preView;
@property (nonatomic, strong) AVCaptureSession *session;

@end

NS_ENUM(NSInteger, CameraPositon) {
    BackSide = 0,
    FrontSide
};

@implementation ViewController {
    AVCaptureDeviceInput *_input;
    AVCaptureStillImageOutput *_output;
    AVCaptureDevice *_camera;
}




#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 画面タップでシャッターを切るための設定
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    // デリゲートをセット
    tapGesture.delegate = self;
    // Viewに追加
    [self.view addGestureRecognizer:tapGesture];

}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // setup display
    [self setupCamera];
    
    // setup camera
//    [self setupDisplay];
}


/**
 *  メモリを解放する
 */
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.session stopRunning];
    
    for (_output in self.session.outputs) {
        [self.session removeOutput:_output];
    }
    
    for (_input in self.session.inputs) {
        [self.session removeInput:_input];
    }
    
    self.session = nil;
    _camera = nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Private Method


- (void)setupDisplay {
    // スクリーンの幅
    CGFloat screeWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    // スクリーンの高さ
    CGFloat screenHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
    //プレビュー用のビューを生成
    self.preView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, screeWidth, screenHeight)];
}


- (void)setupCamera {
    
    // セッション初期化
    self.session = [AVCaptureSession new];
    // カメラデバイスの初期化
    _camera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];

    [self shouldChooseCameraTypeWithFlag:YES];
    
    // プライバシー設定を確認
    [self confirmPermission];
    
    NSError *error = nil;
    _input = [[AVCaptureDeviceInput alloc] initWithDevice:_camera error:&error];
    
    //入力の初期化
    // 入力をセッションに追加
    if ([self.session canAddInput:_input]) {
        [self.session addInput:_input];
        [self.session beginConfiguration];
        //セッションの設定
        self.session.sessionPreset = AVCaptureSessionPresetPhoto;
        [self.session commitConfiguration];
    } else {
        NSLog(@"Error: %@", error);
    }

    
    // 静止画出力のインスタンス生成
    _output = [AVCaptureStillImageOutput new];
    // 出力をセッションに追加
    if ([self.session canAddOutput:_output]) {
        [self.session addOutput:_output];
    } else {
        NSLog(@"Error: %@",error);
    }

    // キャプチャーセッションから入力のプレビュー表示を作成
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
   
    previewLayer.frame = self.preView.bounds;
    
//        previewLayer.videoGravity = AVLayerVideoGravityResize;
//    previewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    // レイヤーをViewに設定
    // これを外すとプレビューが無くなるが撮影はできる
    self.preView.layer.masksToBounds = YES;
    [self.preView.layer addSublayer:previewLayer];
    
    [self.session startRunning];
    
}

- (void)shouldChooseCameraTypeWithFlag:(BOOL)device {
    for ( AVCaptureDevice *device in [AVCaptureDevice devices] ) {
        //背面カメラを取得
        if (device.position == AVCaptureDevicePositionBack) {
            _camera = device;
        }
        //        // 前面カメラを取得
        //        if (device.position == AVCaptureDevicePositionFront) {
        //            _camera = device;
        //        }
    }
}


/**
 *  アクセス設定
 */
- (void)confirmPermission {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    switch (status) {
        case AVAuthorizationStatusAuthorized:   // カメラの使用が許可されている場合
            break;
        case AVAuthorizationStatusDenied:       // カメラの使用が禁止されている場合
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) { // 使用が許可された場合
                    // statement               status = AVAuthorizationStatusAuthorized;
                } else {       // 使用が不許可になった場合
                    NSLog(@"不許可");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                        [[UIApplication sharedApplication] openURL:settingsURL];
                    });
                }
            }];
            break;
        case AVAuthorizationStatusRestricted:   // 機能制限の場合
            break;
        case AVAuthorizationStatusNotDetermined:    // 初回起動時に許可設定を促すダイアログを表示
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) { // 使用が許可された場合
                    // statement               status = AVAuthorizationStatusAuthorized;
                } else {       // 使用が不許可になった場合
                    NSLog(@"不許可");
                }
            }];
        default:
            break;
    }

}


/**
 *  タッチイベント
 *
 *  @param sender <#sender description#>
 */
- (void)tapped:(UITapGestureRecognizer *)sender {
    NSLog(@"タップ");
    [self willTakePhoto];
}


/**
 *  撮影処理
 */
- (void)willTakePhoto {
    //ビデオ出力に接続
    AVCaptureConnection *connection = [_output connectionWithMediaType:AVMediaTypeVideo];
    
    if (connection) {
        // ビデオ出力から画像を非同期で取得
        [_output captureStillImageAsynchronouslyFromConnection:connection
                                             completionHandler:^(CMSampleBufferRef imageDataBuffer, NSError *error){
                                                 NSData *imageData
                                                    = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataBuffer];
                                                 UIImage *image
                                                    = [UIImage imageWithData:imageData];
                                                 UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
                                             }];
    }

}






@end
