//
//  ViewController.swift
//  DisPlay
//
//  Created by Daniel Bonates on 25/11/21.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var takeLbl: UILabel!
    
    var fonts = ["TrimPosterWebCondensed", "Bebas Neue"]
    var currentFont = 0
    
    var takeNumber: Int {
        return UserDefaults.standard.integer(forKey: "currentTakeNumber")
    }

    var darkMode: Bool {
        return UserDefaults.standard.bool(forKey: "currentTheme")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupDisplay()
        setupGestures()
        navigationController?.navigationBar.barStyle = .default

        NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(orientationChanged),
                    name: UIDevice.orientationDidChangeNotification,
                    object: nil
                );
    }
    
    
    func setupDisplay(_ changingTakeOnly: Bool = false) {
        
        let duration = changingTakeOnly ? 0 : 0.25
        UIView.transition(with: takeLbl, duration: duration,
                          options: .transitionCrossDissolve,
                          animations: {
            if self.darkMode {
                self.takeLbl.textColor = .cyan
                self.view.backgroundColor = .black
                self.takeLbl.layer.shadowColor = UIColor.cyan.cgColor
                
            } else {
                self.takeLbl.textColor = .black
                self.view.backgroundColor = .white
                self.takeLbl.layer.shadowColor = UIColor.lightGray.cgColor
            }
        }, completion: nil)
        
        
        
        takeLbl.layer.shadowRadius = 4.0
        takeLbl.layer.shadowOpacity = 0.9
        takeLbl.layer.shadowOffset = .zero
        takeLbl.layer.masksToBounds = false
        setNeedsStatusBarAppearanceUpdate()
        guard let customFont = UIFont(name: fonts[currentFont], size: UIFont.labelFontSize) else {
            fatalError("""
                Failed to load font.
                Make sure the font file is included in the project and the font name is spelled correctly.
                """
            )
        }

        takeLbl.font = UIFontMetrics.default.scaledFont(for: customFont)
        takeLbl.adjustsFontSizeToFitWidth = true
        takeLbl.text = "\(takeNumber)"
        takeLbl.font = takeLbl.font.withSize(takeLbl.frame.height * 2.5/3)
        takeLbl.isUserInteractionEnabled = false
    }
    
    func setupGestures() {
        let tappedGest = UITapGestureRecognizer(target: self, action: #selector(addTake))
        view.addGestureRecognizer(tappedGest)

        let swipeDownGest = UISwipeGestureRecognizer(target: self, action: #selector(switchTheme))
        swipeDownGest.direction = .down
        view.addGestureRecognizer(swipeDownGest)
        
        let swipeTopGest = UISwipeGestureRecognizer(target: self, action: #selector(switchTheme))
        swipeTopGest.direction = .up
        view.addGestureRecognizer(swipeTopGest)
        
        let longPressGest = UILongPressGestureRecognizer(target: self, action: #selector(reset))
        longPressGest.minimumPressDuration = 1
        view.addGestureRecognizer(longPressGest)
    }

    
    @objc func switchTheme(_ swipeTopGest: UISwipeGestureRecognizer) {
        UserDefaults.standard.set(!darkMode, forKey: "currentTheme")
        UserDefaults.standard.synchronize()
        setupDisplay()
    }
    
    @objc func reset(_ longPressGest: UILongPressGestureRecognizer) {
        UserDefaults.standard.set(0, forKey: "currentTakeNumber")
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 1
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: takeLbl.center.x - 10, y: takeLbl.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: takeLbl.center.x + 10, y: takeLbl.center.y))

        takeLbl.layer.add(animation, forKey: "position")
        setupDisplay()
    }
    
    @objc func addTake(_ tapGest: UITapGestureRecognizer) {

        let point = tapGest.location(in: view)
        let increment = point.x > view.bounds.width/2 ? 1 : -1
        var result = takeNumber + increment
        if result < 0 {
            result = 0
        }
        UserDefaults.standard.set(result, forKey: "currentTakeNumber")
        UserDefaults.standard.synchronize()
        setupDisplay(true)
    }

    @objc func orientationChanged(_ notification: NSNotification) {
        setupDisplay()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if darkMode {
            return .lightContent
        } else {
            return .darkContent
        }
    }
}

