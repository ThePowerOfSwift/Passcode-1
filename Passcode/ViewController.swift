//
//  ViewController.swift
//  Passcode
//

import UIKit

class ViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    @IBOutlet weak var topCenterYConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var titleIndentYConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var pinsIndentYConstraint: NSLayoutConstraint!
    @IBOutlet weak var pinDiameterConstraint: NSLayoutConstraint!
    @IBOutlet weak var distanceBetweenPinsXConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var keyDiameterConstraint: NSLayoutConstraint!
    @IBOutlet weak var distanceBetweenKeysXConstraint: NSLayoutConstraint!
    @IBOutlet weak var distanceBetweenKeysYConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bottomButtonsIndentCenterYConstraint: NSLayoutConstraint!

    @IBOutlet weak var pinsViewCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var pin1View: UIView!
    @IBOutlet weak var pin2View: UIView!
    @IBOutlet weak var pin3View: UIView!
    @IBOutlet weak var pin4View: UIView!
    
    @IBOutlet weak var key1BackgroundView: UIView!
    @IBOutlet weak var key2BackgroundView: UIView!
    @IBOutlet weak var key3BackgroundView: UIView!
    @IBOutlet weak var key4BackgroundView: UIView!
    @IBOutlet weak var key5BackgroundView: UIView!
    @IBOutlet weak var key6BackgroundView: UIView!
    @IBOutlet weak var key7BackgroundView: UIView!
    @IBOutlet weak var key8BackgroundView: UIView!
    @IBOutlet weak var key9BackgroundView: UIView!
    @IBOutlet weak var key0BackgroundView: UIView!
    
    @IBOutlet weak var key1Button: UIButton!
    @IBOutlet weak var key2Button: UIButton!
    @IBOutlet weak var key3Button: UIButton!
    @IBOutlet weak var key4Button: UIButton!
    @IBOutlet weak var key5Button: UIButton!
    @IBOutlet weak var key6Button: UIButton!
    @IBOutlet weak var key7Button: UIButton!
    @IBOutlet weak var key8Button: UIButton!
    @IBOutlet weak var key9Button: UIButton!
    @IBOutlet weak var key0Button: UIButton!
    
    @IBOutlet weak var deleteButton: UIButton!
    
    let pinActiveColor: UIColor = .white
    let pinInactiveColor: UIColor = .clear
    let keyTouchDownAlpha: CGFloat = 0.6
    let keyTouchUpAlpha: CGFloat = 0.2
    
    var pinViews: [UIView] = []
    var keyBackgroundViews: [UIView] = []
    var keyButtons: [UIButton] = []

    let keyAnimateDuration: TimeInterval = 0.4
    let timerStep: TimeInterval = 0.01
    var keyAlphaStep: CGFloat = 0
    var keyTimers: [Timer?] = Array(repeating: nil, count: 10)
    
    var pinCode: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let keyboard = Keyboard()
        
        topCenterYConstraint.constant = keyboard.topCenterY

        titleIndentYConstraint.constant = keyboard.titleIndentY
        titleLabel.font = keyboard.titleFont
        
        pinsIndentYConstraint.constant = keyboard.pinsIndentY
        pinDiameterConstraint.constant = keyboard.pinDiameter
        distanceBetweenPinsXConstraint.constant = keyboard.distanceBetweenPinsX
        
        keyDiameterConstraint.constant = keyboard.keyDiameter
        distanceBetweenKeysXConstraint.constant = keyboard.distanceBetweenKeysX
        distanceBetweenKeysYConstraint.constant = keyboard.distanceBetweenKeysY
        
        bottomButtonsIndentCenterYConstraint.constant = keyboard.bottomButtonsIndentCenterY
        
        pinViews = [pin1View, pin2View, pin3View, pin4View]
        
        keyBackgroundViews = [key0BackgroundView, key1BackgroundView, key2BackgroundView, key3BackgroundView, key4BackgroundView, key5BackgroundView, key6BackgroundView, key7BackgroundView, key8BackgroundView, key9BackgroundView]
        
        keyButtons = [key0Button, key1Button, key2Button, key3Button, key4Button, key5Button, key6Button, key7Button, key8Button, key9Button]
        
        for item in pinViews {
            item.layer.cornerRadius = keyboard.pinDiameter / 2
            item.layer.borderWidth  = 1.2
            item.layer.borderColor = pinActiveColor.cgColor
            item.backgroundColor = .clear
        }

        for item in keyBackgroundViews {
            item.layer.cornerRadius = keyboard.keyDiameter / 2
            item.alpha = keyTouchUpAlpha
            item.backgroundColor = .white
        }
        
        keyAlphaStep = (keyTouchDownAlpha - keyTouchUpAlpha) / CGFloat(keyAnimateDuration / timerStep)
    }
    
    // MARK: - Action

    @IBAction func keyButtonTouchDown(_ sender: UIButton) { addKey(keyIndex(sender)) }
    @IBAction func keyButtonTouchUpInside(_ sender: UIButton) { startTimer(keyIndex(sender)) }
    @IBAction func keyButtonTouchUpOutside(_ sender: UIButton) { cancelKey(keyIndex(sender)) }
    @IBAction func clickDeleteButton(_ sender: UIButton) { cancelKey() }
    
    func keyIndex(_ button: UIButton) -> Int { return keyButtons.index(of: button) ?? 0 }
    
    func addKey(_ index: Int) {
        if pinCode.count < 4 {
            pinCode += String(index)
            drawPinCode()
        }
        
        stopTimer(index)
        keyBackgroundViews[index].alpha = keyTouchDownAlpha
    }
    
    func cancelKey(_ index: Int? = nil) {
        if !pinCode.isEmpty {
            pinCode.removeLast()
            drawPinCode()
        }
        
        if let index = index { keyBackgroundViews[index].alpha = keyTouchUpAlpha }
    }

    func drawPinCode() {
        let count = pinCode.count
        
        var title = "Delete"
        if count == 0 { title = "Cancel" }
        
        if deleteButton.currentTitle != title {
            deleteButton.titleLabel?.text = title
            deleteButton.setTitle(title, for: .normal)
        }
        
        for i in 0...3 {
            if count >= i+1 { pinViews[i].backgroundColor = pinActiveColor   }
            else            { pinViews[i].backgroundColor = pinInactiveColor }
        }
        
        if count >= 4 {
            // pinCode verification
            
            // If the pinCode is incorrect, then
            pinViewsAnimation()
        }
    }
    
    func keyboardUserInteractionEnabled(_ isUserInteractionEnabled: Bool) {
        for item in keyButtons { item.isUserInteractionEnabled = isUserInteractionEnabled }
    }
    
    func pinViewsAnimation() {
        keyboardUserInteractionEnabled(false)
        
        let duration = 0.1
        let steps: [CGFloat] = [-50, 100, -80, 60, -40, 20, -10]
        
        UIView.animateKeyframes(withDuration: duration * Double(steps.count), delay: 0, options: [], animations: {
            var startTime = 0.0
            
            for step in steps {
                UIView.addKeyframe(withRelativeStartTime: startTime, relativeDuration: duration, animations: {
                    self.pinsViewCenterXConstraint.constant += step
                    self.view.layoutIfNeeded()
                })
                
                startTime += duration
            }
        }, completion: { (finished: Bool) in
            self.pinCode = ""
            self.drawPinCode()
            self.keyboardUserInteractionEnabled(true)
        })
    }
    
    // MARK: - Timer
    
    func startTimer(_ index: Int) {
        keyTimers[index] = Timer.scheduledTimer(timeInterval: timerStep, target: self, selector: #selector(keyAnimation), userInfo: index, repeats: true)
    }
    
    func stopTimer(_ index: Int) {
        keyTimers[index]?.invalidate()
        keyTimers[index] = nil
    }
    
    @objc func keyAnimation(timer: Timer) {
        guard let index = timer.userInfo as? Int else { return }
        
        let alpha = keyBackgroundViews[index].alpha - keyAlphaStep
        
        if alpha > keyTouchUpAlpha {
            keyBackgroundViews[index].alpha = alpha
        } else {
            keyBackgroundViews[index].alpha = keyTouchUpAlpha
            stopTimer(index)
        }
    }

}

class Keyboard {
    
    let topCenterY: CGFloat
    
    let titleIndentY: CGFloat
    let titleFont: UIFont
    
    let pinsIndentY: CGFloat
    let pinDiameter: CGFloat
    let distanceBetweenPinsX: CGFloat
    
    let keyDiameter: CGFloat
    let distanceBetweenKeysX: CGFloat
    let distanceBetweenKeysY: CGFloat
    
    let bottomButtonsIndentCenterY: CGFloat
    
    init() {
        switch UIScreen.maxSize {
            
        case UIScreen.maxSizeIPhone4:
            topCenterY = -132
            
            titleIndentY = 11
            titleFont = .systemFont(ofSize: 18)
            
            pinsIndentY = 18
            pinDiameter = 14
            distanceBetweenPinsX = 23
            
            keyDiameter = 76
            distanceBetweenKeysX = 19
            distanceBetweenKeysY = 12
            
            bottomButtonsIndentCenterY = 45
            
        case UIScreen.maxSizeIPhone5:
            topCenterY = -122
            
            titleIndentY = 11
            titleFont = .systemFont(ofSize: 18)
            
            pinsIndentY = 38
            pinDiameter = 14
            distanceBetweenPinsX = 23
            
            keyDiameter = 76
            distanceBetweenKeysX = 19
            distanceBetweenKeysY = 12
            
            bottomButtonsIndentCenterY = 73

        case UIScreen.maxSizeIPhone6:
            topCenterY = -128
            
            titleIndentY = 24
            titleFont = .systemFont(ofSize: 19)
            
            pinsIndentY = 52
            pinDiameter = 14
            distanceBetweenPinsX = 24
            
            keyDiameter = 76
            distanceBetweenKeysX = 27
            distanceBetweenKeysY = 14
            
            bottomButtonsIndentCenterY = 111

        case UIScreen.maxSizeIPhoneX:
            topCenterY = -111
            
            titleIndentY = 21
            titleFont = .systemFont(ofSize: 22)
            
            pinsIndentY = 52
            pinDiameter = 14
            distanceBetweenPinsX = 24
            
            keyDiameter = 76
            distanceBetweenKeysX = 27
            distanceBetweenKeysY = 14
            
            bottomButtonsIndentCenterY = 148

        case UIScreen.maxSizeIPhonePlus:
            topCenterY = -138
            
            titleIndentY = 28
            titleFont = .systemFont(ofSize: 22)
            
            pinsIndentY = 60
            pinDiameter = 14
            distanceBetweenPinsX = 28
            
            keyDiameter = 82
            distanceBetweenKeysX = 32
            distanceBetweenKeysY = 17
            
            bottomButtonsIndentCenterY = 123
            
        case UIScreen.maxSizeIPad_9_7:
            topCenterY = -142
            
            titleIndentY = 18
            titleFont = .systemFont(ofSize: 22)
            
            pinsIndentY = 61
            pinDiameter = 16
            distanceBetweenPinsX = 30
            
            keyDiameter = 82
            distanceBetweenKeysX = 32
            distanceBetweenKeysY = 19
            
            bottomButtonsIndentCenterY = 0

        case UIScreen.maxSizeIPad_10_5:
            topCenterY = -142
            
            titleIndentY = 18
            titleFont = .systemFont(ofSize: 22)
            
            pinsIndentY = 61
            pinDiameter = 16
            distanceBetweenPinsX = 30
            
            keyDiameter = 82
            distanceBetweenKeysX = 32
            distanceBetweenKeysY = 19
            
            bottomButtonsIndentCenterY = 0

        case UIScreen.maxSizeIPad_12_9:
            topCenterY = -142
            
            titleIndentY = 18
            titleFont = .systemFont(ofSize: 22)
            
            pinsIndentY = 61
            pinDiameter = 16
            distanceBetweenPinsX = 30
            
            keyDiameter = 82
            distanceBetweenKeysX = 32
            distanceBetweenKeysY = 19
            
            bottomButtonsIndentCenterY = 0

        default:
            topCenterY = -132
            
            titleIndentY = 11
            titleFont = .systemFont(ofSize: 18)
            
            pinsIndentY = 18
            pinDiameter = 14
            distanceBetweenPinsX = 23
            
            keyDiameter = 76
            distanceBetweenKeysX = 19
            distanceBetweenKeysY = 12
            
            bottomButtonsIndentCenterY = 45
        }
    }

}

extension UIScreen {
    
    static let maxSize: CGFloat = { return max(main.bounds.size.width, main.bounds.size.height) }()
    
    static let maxSizeIPhone4:    CGFloat = { return  480 }()
    static let maxSizeIPhone5:    CGFloat = { return  568 }()
    static let maxSizeIPhone6:    CGFloat = { return  667 }()
    static let maxSizeIPhonePlus: CGFloat = { return  736 }()
    static let maxSizeIPhoneX:    CGFloat = { return  812 }()
    static let maxSizeIPad_9_7:   CGFloat = { return 1024 }()
    static let maxSizeIPad_10_5:  CGFloat = { return 1112 }()
    static let maxSizeIPad_12_9:  CGFloat = { return 1366 }()
    
}
