@propertyWrapper
public class DissGet<T> {
  private var backingValue: T? = DissContainer.instance.getByType(type: T.self)

  public var wrappedValue: T? {
    get { backingValue }
    set { backingValue = newValue }
  }
  public init() {}
}

public func dissSet<T>(policy: DissPolicy, initializer: @escaping () -> T) throws {
  try dissBind(type: T.self, policy: policy, initializer: initializer)
}

public func dissBind<T>(type: T.Type, policy: DissPolicy, initializer: @escaping () -> T) throws {
  switch policy {

  case .singleton:
    let object = initializer()
    guard Mirror(reflecting: object).displayStyle == .class else {
      throw DissError.structSingleton
    }
    try DissContainer.instance.addInstance(type: T.self, object: object)

  case .unique:
    try DissContainer.instance.addUnique(type: T.self, initializer: initializer)

  case .factory:
    try DissContainer.instance.addFactory(type: T.self, initializer: initializer)

  }

}

public enum DissPolicy: Equatable {
  case singleton, unique, factory
}
