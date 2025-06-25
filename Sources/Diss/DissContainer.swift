import Foundation
import Logging

private let logger = Logger(label: "diss")

internal class DissContainer: @unchecked Sendable {
  internal static let instance = DissContainer()
  private var instances: [ObjectIdentifier: Any] = [ObjectIdentifier: Any]()
  private var scopes: [ObjectIdentifier: () -> Any] = [ObjectIdentifier: () -> Any]()

  private init() {}

  internal func addInstance<T>(type: T.Type, object: T) throws {
    let key = ObjectIdentifier(type)
    guard instances[key] == nil else {
      throw DissError.multipleSet(type: "\(T.self)")
    }
    instances[key] = object
  }

  internal func addScope<T>(type: T.Type, initializer: @escaping () -> T) throws {
    let key = ObjectIdentifier(type)
    guard instances[key] == nil && scopes[key] == nil else {
      throw DissError.multipleSet(type: "\(T.self)")
    }
    scopes[key] = initializer
  }

  internal func getByType<T>(type: T.Type) -> T? {
    let key = ObjectIdentifier(type)
    logger.debug("TYPE in getByType: '\(key)'")
    var findedObject = instances[key] as? T
    logger.debug("Finded in instances: \(String(describing: findedObject))")
    
    if findedObject == nil {
      let initializer = scopes[key]
      findedObject = initializer?() as? T
      if findedObject != nil {
        logger.debug("Scope object created: \(String(describing: findedObject!))")
      }
    }
    return findedObject
  }

  internal func reset() {
    instances.removeAll()
  }

  internal func show() {
    print("instances: \(instances)")
    print("scopes: \(scopes)")
  }

  deinit {
    logger.debug("DissContainer destroyed")
  }
}

internal func dissReset() {
  DissContainer.instance.reset()
}

internal func show() {
  DissContainer.instance.show()
}

internal enum DissError: Error, Equatable {
  case notFound
  case structSingleton
  case multipleSet(type: String)
}

internal class SingletonWrapper<T> {
  private let object: T?
  init(object: T?) {
    self.object = object
  }
}
