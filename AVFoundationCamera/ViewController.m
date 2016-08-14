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

@implementation ViewController {
    AVCaptureDeviceInput *_input;
    AVCaptureStillImageOutput *_output;
//    AVCaptureSession *self.session;
    AVCaptureDevice *_camera;
}


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
    [self setupDisplay];
}



- (void)setupDisplay {
    // スクリーンの幅
    CGFloat screeWidth = [UIScreen mainScreen].bounds.size.width;
    // スクリーンの高さ
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    //プレビュー用のビューを生成
    _preView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, screeWidth, screenHeight)];
}


- (void)setupCamera {
    
//    // セッション初期化
    self.session = [AVCaptureSession new];
    // カメラデバイスの初期化
    _camera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];

    
    for ( AVCaptureDevice *device in [AVCaptureDevice devices] ) {
        //背面カメラを取得
        if (device.position == AVCaptureDevicePositionBack) {
            _camera = device;
        }
//        if (captureDevice.position == AVCaptureDevicePositionFront) {
//            _camera = captureDevice;
//        }
    }
    
    
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (status == AVAuthorizationStatusAuthorized) { // プライバシー設定でカメラ使用が許可されている
        
    } else if (status == AVAuthorizationStatusDenied) { // 　不許可になっている
        status = AVAuthorizationStatusAuthorized;
    } else if (status == AVAuthorizationStatusRestricted) { // 制限されている
        status = AVAuthorizationStatusAuthorized;
    } else if (status == AVAuthorizationStatusNotDetermined) { // アプリで初めてカメラ機能を使用する場合
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            
            if (granted) { // 使用が許可された場合
//                status = AVAuthorizationStatusAuthorized;
            } else {       // 使用が不許可になった場合
                NSLog(@"不許可");
            }
            
        }];
        
    }
    
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
   
    previewLayer.frame = _preView.bounds;
    
//        previewLayer.videoGravity = AVLayerVideoGravityResize
//        previewLayer.videoGravity = AVLayerVideoGravityResizeAspect
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    // レイヤーをViewに設定
    // これを外すとプレビューが無くなる、けれど撮影はできる
    CALayer *layer = self.view.layer;
    layer.masksToBounds = YES;
    [self.view.layer addSublayer:previewLayer];
    
    [self.session startRunning];
    
}


// タップイベント.
- (void)tapped:(UITapGestureRecognizer *)sender {
    NSLog(@"タップ");
    [self takeStillPhoto];
}



- (void)takeStillPhoto {
    //ビデオ出力に接続
    AVCaptureConnection *connection = [_output connectionWithMediaType:AVMediaTypeVideo];
    
    if (connection) {
        // ビデオ出力から画像を非同期で取得
        
//        [_output captureStillImageAsynchronouslyFromConnection:connection
//                                             completionHandler:(void(^)(id *imageDataBuffer)){
//                                             
//                                                 // 取得画像のDataBufferをJpegに変換
//                                                 NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataBuffer];
//                                                 // JpegからUIImageを作成.
//                                                 UIImage *image = [UIImage imageWithData:imageData];
//                                                 // アルバムに追加.
//                                                 UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
//                                                
//                                             }];
        
    }

}



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

@end
