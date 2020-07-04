import UIKit
import Flutter
import RxSwift


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let METHODCHANNEL = "sample.test.platform/text"
    let EVENTCHANNEL = "sample.test.platform/number"
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let methodChannel = FlutterMethodChannel(name: METHODCHANNEL,
                                              binaryMessenger: controller.binaryMessenger)
    
    
    methodChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      // Note: this method is invoked on the UI thread.
        switch call.method {
        case "sendtext":
            let argument: [String: String] = call.arguments as! [String: String]
            let returntext = self.getStringReturnToDart(text: argument["message"]!)
            NSLog("from iOS: send text back")
            result(returntext)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    })
    
    let eventChannel = FlutterEventChannel(name: EVENTCHANNEL, binaryMessenger: controller.binaryMessenger)
    let handler = TimerStreamHandler()
    eventChannel.setStreamHandler(handler)
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    private func getStringReturnToDart(text: String) -> String {
      return text + " <- from iOS"
    }
    
    class TimerStreamHandler: NSObject, FlutterStreamHandler {
        var timerSubscription : Disposable?
    
        func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
            NSLog("on iOS: onListen")
            timerSubscription = Observable<Int>.timer(0, period: 1, scheduler: MainScheduler.instance)
            .subscribe(onNext: { value in
                NSLog("onNext: iOS timer event \(value)")
                events(value)
            })
            return nil
        }
    
        func onCancel(withArguments arguments: Any?) -> FlutterError? {
            NSLog("on iOS: cancelling listener")
            timerSubscription?.dispose()
            return nil
        }
        
        
    }
}
