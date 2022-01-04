import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController.init()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    GoogleSignInMacOSPlugin.register(with: flutterViewController.registrar(forPlugin: "GoogleSignInMacOSPlugin"))

    super.awakeFromNib()
  }
}
