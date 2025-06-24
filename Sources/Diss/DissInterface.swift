@propertyWrapper
public class DissGet<T> {
  private var backingValue: T? = DissContainer.instance.getByType()

  public var wrappedValue: T? {
    get { backingValue }
    set { backingValue = newValue }
  }
  public init() {}
}
public func dissSetSingleton<T>(initializer: () -> T) throws {
  let object = initializer()
  guard Mirror(reflecting: object).displayStyle == .class else {
    throw DissError.structSingleton
  }
  try DissContainer.instance.addSingleton(object: initializer())
}
public func dissSetBind<T>(type: T.Type, initializer: () -> T) throws {
  try DissContainer.instance.addBind(type: T.self, object: initializer())
}
