@propertyWrapper
public class DissGet<T> {
  private var backingValue: T? = DissContainer.instance.getByType(type: T.self)

  public var wrappedValue: T? {
    get { backingValue }
    set { backingValue = newValue }
  }
  public init() {}
}

public func dissSet<T>(policy: DissPolicy, initializer: () -> T) throws {
  try dissBind(type: T.self, policy: policy, initializer: initializer)
}

public func dissBind<T>(type: T.Type, policy: DissPolicy, initializer: () -> T) throws {
  let object = initializer()
  switch policy {

  case .singleton:
    guard Mirror(reflecting: object).displayStyle == .class else {
      throw DissError.structSingleton
    }
    try DissContainer.instance.addSingleton(type: T.self, object: initializer())

  case .scope:
    throw DissError.notFound

  }

}

public enum DissPolicy: Equatable {
  case singleton, scope
}