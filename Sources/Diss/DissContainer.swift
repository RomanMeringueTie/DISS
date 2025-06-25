import Foundation
import Logging

private let logger = Logger(label: "diss")

internal class DissContainer: @unchecked Sendable {
  internal static let instance = DissContainer()
  private var singletons: [ObjectIdentifier: Any] = [ObjectIdentifier: Any]()

  private init() {}

  internal func addSingleton<T>(type: T.Type, object: T) throws {
    let key = ObjectIdentifier(type)
    let findedObject = singletons[key]
    guard findedObject == nil else {
      throw DissError.multipleSet(type: "\(T.self)")
    }
    singletons[key] = object
  }

  internal func getByType<T>(type: T.Type) -> T? {
    logger.debug("TYPE in getByType: '\(ObjectIdentifier(type))'")
    let findedObject = singletons[ObjectIdentifier(T.self)] as? T
    logger.debug("Finded in singletons: \(String(describing: findedObject))")
    return findedObject
  }

  internal func reset() {
    singletons.removeAll()
  }

  internal func show() {
    logger.debug("singletons: \(singletons)")
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