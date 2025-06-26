import Foundation
import Logging

private let logger = Logger(label: "diss")

internal class DissContainer {
  internal static let instance = DissContainer()
  private var instances: [ObjectIdentifier: Any] = [ObjectIdentifier: Any]()
  private var uniques: [ObjectIdentifier: () -> Any] = [ObjectIdentifier: () -> Any]()
  private var factories: [ObjectIdentifier: () -> Any] = [ObjectIdentifier: () -> Any]()

  private init() {}

  internal func addInstance<T>(type: T.Type, object: T) throws {
    let key = ObjectIdentifier(type)
    guard instances[key] == nil else {
      throw DissError.multipleSet(type: "\(T.self)")
    }
    instances[key] = object
  }

  internal func addUnique<T>(type: T.Type, initializer: @escaping () -> T) throws {
    let key = ObjectIdentifier(type)
    guard instances[key] == nil && uniques[key] == nil else {
      throw DissError.multipleSet(type: "\(T.self)")
    }
    uniques[key] = initializer
  }

  internal func addFactory<T>(type: T.Type, initializer: @escaping () -> T) throws {
    let key = ObjectIdentifier(type)
    guard instances[key] == nil && uniques[key] == nil else {
      throw DissError.multipleSet(type: "\(T.self)")
    }
    factories[key] = initializer
  }

  internal func getByType<T>(type: T.Type) -> T? {
    let key = ObjectIdentifier(type)
    logger.debug("TYPE in getByType: '\(key)'")
    let findedObject: T? = getSingleton(key) ?? getFactory(key) ?? getUnique(key)
    return findedObject
  }

  private func getSingleton<T>(_ key: ObjectIdentifier) -> T? {
    let findedObject = instances[key] as? T
    logger.debug("Finded in instances: \(String(describing: findedObject))")
    return findedObject
  }

  private func getUnique<T>(_ key: ObjectIdentifier) -> T? {
    let findedObject = uniques[key]?() as? T
    if findedObject != nil {
      logger.debug("Scope object created: \(String(describing: findedObject!))")
    }
    return findedObject
  }

  private func getFactory<T>(_ key: ObjectIdentifier) -> T? {
    let findedObject = factories[key]?() as? T
    if findedObject != nil {
      logger.debug("Factory object created: \(String(describing: findedObject!))")
      instances[key] = findedObject
    }
    return findedObject
  }

  internal func reset() {
    instances.removeAll()
  }

  internal func show() {
    print("instances: \(instances)")
    print("uniques: \(uniques)")
  }

  deinit {
    logger.debug("DissContainer destroyed")
  }
}

extension DissContainer: @unchecked Sendable {}

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
