//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport
import AppFramework

class MyViewController : UIViewController {

    var label: UILabel!

    var count = 1

    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white

        let button = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
        button.backgroundColor = .green
        button.setTitle("Test Button", for: .normal)
        button.addTarget(self, action: #selector(bruninha), for: .touchUpInside)

        view.addSubview(button)

        label = UILabel()
        label.frame = CGRect(x: 150, y: 200, width: 200, height: 20)
        label.text = "Hello World!"
        label.textColor = .black
        
        view.addSubview(label)
        self.view = view
    }

    @objc func bruninha() {
        label.text = "A bruna é \(count) muito linda"
        count += 1
    }


}
// Present the view controller in the Live View window
for i in 1...5 {
    var l = i * 2
}


PlaygroundPage.current.liveView = MyViewController()
