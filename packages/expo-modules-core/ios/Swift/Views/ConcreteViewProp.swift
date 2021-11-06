// Copyright 2021-present 650 Industries. All rights reserved.

import UIKit

/**
 Specialized class for the view prop. Specifies the prop name and its setter.
 */
public final class ConcreteViewProp<Args>: AnyViewProp {
  public typealias SetterType = (Args) -> Void

  public let name: String

  let propType: AnyArgumentType
  let setter: SetterType

  init(_ name: String, propType: [AnyArgumentType], _ setter: @escaping SetterType) {
    self.name = name
    self.propType = propType.first!
    self.setter = setter
  }

  public func set(value: Any, onView view: UIView) {
    // Method's signature must be type-erased for `AnyViewProp` protocol,
    // so we have to get UIView and cast it to the generic type.
    // TODO: (@tsapeta) Throw an error instead of crashing the app.
//    guard let view = view as? ViewType else {
//      fatalError("Given view must subclass UIView")
//    }
//    guard let value = value as? PropType else {
//      fatalError("Given value `\(String(describing: value))` cannot be casted to `\(String(describing: PropType.self))`")
//    }
    if let castedValue = try? propType.cast(value) {
      setter((view, castedValue) as! Args)
    }
  }
}
