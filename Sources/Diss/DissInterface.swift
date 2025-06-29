@propertyWrapper
public class DissGet<T> {
  private var backingValue: T? = DissContainer.instance.getByType(T.self)

  public var wrappedValue: T? {
    get { backingValue }
    set { backingValue = newValue }
  }
  public init() {}
}

@propertyWrapper
public class DissGetAssisted<T> {
  private var backingValue: T?
  private let arguments: [Any]

  public var wrappedValue: T? {
    get { backingValue }
    set { backingValue = newValue }
  }

  public init(arguments: [Any]) {
    self.arguments = arguments
    self.backingValue = DissContainer.instance.getAssist(T.self, arguments)
  }
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

public func dissAssist<R>(policy: DissPolicy, initializer: @escaping ([Any]) throws -> R) throws {
  switch policy {

  case .unique:
    let key = ObjectIdentifier(R.self)
    guard DissContainer.instance.assists[key] == nil else {
      throw DissError.multipleSet(type: "\(R.self)")
    }
    DissContainer.instance.assists[key] = initializer

  default:
    throw DissError.assistedNotUnique
  }
}

public enum DissPolicy: Equatable {
  case singleton, unique, factory
}

public func dissCast<T>(_ value: Any) throws -> T {
  let result: T? = value as? T
  guard result != nil else {
    throw DissError.unexpectedType(expected: "\(T.self)", actual: "\(type(of: value))")
  }
  return result!
}

public class DissSingle<T> {
  public var object: T
  init(_ object: T) {
    self.object = object
  }
}
