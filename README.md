# ZB_AddWaterImageToVideo
先说下思路：

首先我们要知道我们能看到的视频实际上是由一个叫做videoLayer负责显示的，和他同级的有个layer叫做animationLayer，我们能够控制的其实就是这个东西，他可以由我们自己创建，他们有一个共同的父类叫做parentLayer。

添加图片水印的代码：
CALayer *imgLayer = [CALayer layer];

    imgLayer.contents = (id)img.CGImage;
    
    imgLayer.frame = CGRectMake(0, 0, size.width, size.height);
    
创建好了图片layer后，就需要创建videoLayer
//把文字和图标都添加到layer
   CALayer *overlayLayer = [CALayer layer];
    [overlayLayer addSublayer:imgLayer];
    overlayLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [overlayLayer setMasksToBounds:YES];
    [overlayLayer addSublayer:imgLayer];
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, size.width, size.height);
    parentLayer.backgroundColor = [UIColor redColor].CGColor;
    videoLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:overlayLayer];
    
    composition.animationTool = [AVVideoCompositionCoreAnimationTool
                                 videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
这里主要是告诉系统我们的layer层时parentLayer，在parentLayer里负责video显示的是我们的videoLayer。

详细说明尽在博客，地址：https://juejin.im/post/5b9b12b1e51d450e4369290f
