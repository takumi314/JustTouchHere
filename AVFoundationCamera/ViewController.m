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

@end

@implementation ViewController {
    AVCaptureDeviceInput *_input;
    AVCaptureStillImageOutput *_output;
    AVCaptureSession *_session;
    AVCaptureDevice *_camera;
    UIView *_preView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // カメラデバイスの初期化
    _camera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];

   

    if (_input) {
        
        
        // プレビュー表示
        AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
        AVCaptureConnection *connection = [AVCaptureConnection connectionWithInputPort:nil
                                                                     videoPreviewLayer:previewLayer];
        
        connection.automaticallyAdjustsVideoMirroring = NO;
        
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        previewLayer.frame = self.view.bounds;
        
        
        
        [previewCtr.view.layer insertSublayer:previewLayer atIndex:0];
        
        // 出力の初期化
//        self.imageOutput = [AVCaptureStillImageOutput new];
        [_session addOutput:self.imageOutput];

        
        // セッション開始
        [_session startRunning];
    }
    // エラー
    else {
        NSLog(@"ERROR:%@", error);
    }
    
}


- (void)setupCamera {
    
    // セッション初期化
    _session = [AVCaptureSession new];
    [_session addInput:_input];
    [_session beginConfiguration];
    //セッションの設定
    _session.sessionPreset = AVCaptureSessionPresetPhoto;
    [_session commitConfiguration];

//    
//    for ( AVCaptureDevice  in  ) {
//        if (_camera.position == AVCaptureDevicePositionBack) {
//            
//        }
//    }
    
    // 入力の初期化
    NSError *error = nil;
    _input = [AVCaptureDeviceInput deviceInputWithDevice:_camera error:&error];


    if ([_session canAddInput:_input]) {
        [_session addInput:_input];
    }
    
    _output = [AVCaptureStillImageOutput new];
    
    if ([_session canAddOutput:_output]) {
        [_session addOutput:_output];
    }

    
    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    previewLayer.frame = _preView.frame;
    
//        previewLayer.videoGravity = AVLayerVideoGravityResize
//        previewLayer.videoGravity = AVLayerVideoGravityResizeAspect
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;

    [self.view.layer addSublayer:previewLayer];
    
    [_session startRunning];
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // setup display
    
    // setup camera

}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_session stopRunning];
    
    for (_output in _session.outputs) {
        [_session removeOutput:_output];
    }
    
    for (_input in _session.inputs) {
        [_session removeInput:_input];
    }

    _session = nil;
    _camera = nil;
}


    
    
    
    
    
    


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
