//
//  ViewController.swift
//  screenescape
//
//  Created by Douwe Osinga on 12/12/16.
//  Copyright © 2016 Douwe Osinga. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKScriptMessageHandler {
    
    var touchView : UIView?;
    var webView: WKWebView?;

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let contentController = WKUserContentController();
        contentController.addScriptMessageHandler(
            self,
            name: "levelSolved"
        )
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        
        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height),
                                configuration: config)
        view.addSubview(webView)
        
        self.webView = webView;
        loadLevel();
        
        let touchView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        view.addSubview(touchView)
        self.touchView = touchView;

        let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.touchHappened (_:)))
        gesture.numberOfTapsRequired = 1;
        touchView.addGestureRecognizer(gesture)
        
    }
    
    func loadLevel() {
        let defaults = NSUserDefaults.standardUserDefaults()
        let level = defaults.integerForKey("level") == 0 ? 1 : defaults.integerForKey("level");
        
        if let index = NSBundle.mainBundle().URLForResource(String(format: "%03d", level), withExtension: "html") {
            self.webView!.loadFileURL(index, allowingReadAccessToURL: index);
        } else {
            let done = NSBundle.mainBundle().URLForResource("done", withExtension: "html")!;
            self.webView!.loadFileURL(done, allowingReadAccessToURL: done);
        }
    }
    
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        if(message.name == "levelSolved") {
            let defaults = NSUserDefaults.standardUserDefaults()
            let level = defaults.integerForKey("level") == 0 ? 1 : defaults.integerForKey("level");
            defaults.setInteger(level + 1, forKey: "level");
            loadLevel();
        }
    }
    
    func callJs(eventName: String, params: NSDictionary) {
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(params, options: .PrettyPrinted)
            let jsCall = String(format: "onEvent('%@', %@)", eventName, String(data: jsonData, encoding: NSUTF8StringEncoding)!)
            self.webView!.evaluateJavaScript(jsCall) { (result, error) in
                print(result)
            }
        } catch let error as NSError {
            print(error)
        }
    }

    func touchHappened(sender:UITapGestureRecognizer){
        let coo = sender.locationInView(self.touchView);
        callJs("touch", params: ["x": coo.x, "y": coo.y])
    }
}

