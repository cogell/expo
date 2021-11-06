import UIKit
import ExpoModulesCore

public class LinearGradientModule: Module {
  public func definition() -> ModuleDefinition {
    name("ExpoLinearGradient")

    viewManager {
      view {
        EXLinearGradient()
      }

      self.prop("colors") { (view: EXLinearGradient, colors: [UIColor]) in
        view.setColors(colors)
      }

      self.prop("startPoint") { (view: EXLinearGradient, startPoint: CGPoint) in
        view.setStart(startPoint)
      }

      self.prop("endPoint") { (view: EXLinearGradient, endPoint: CGPoint) in
        view.setEnd(endPoint)
      }

      self.prop("locations") { (view: EXLinearGradient, locations: [Double]) in
        view.setLocations(locations)
      }
    }
  }
}
