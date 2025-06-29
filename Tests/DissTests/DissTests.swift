import Foundation
import Logging
import Testing

@testable import Diss

@Suite(.serialized) class DissTests {

  @Test func testDissBindSuccess() {
    do {
      try dissBind(type: Service.self, policy: .singleton) { ServiceImpl() }
    } catch {
      print(error)
    }

    @DissGet
    var service: Service?
    #expect(service?.number == 1)
  }

  @Test func testDissBindFailure() {
    #expect(
      throws: DissError.multipleSet(type: "UseCase"),
      performing: {
        try dissBind(type: UseCase.self, policy: .singleton, ) { UseCase1() }
        try dissBind(type: UseCase.self, policy: .singleton) { UseCase2() }
      }
    )
  }

  @Test func testSetSingletonSuccess() {
    do {
      try dissSet(policy: .singleton) { Converter.init(number: 2.12345) }
    } catch {
      print(error)
    }

    @DissGet
    var converter: Converter?
    #expect(converter?.convert() == 2.123)
  }

  @Test func testSetSingletonFailure() {
    #expect(
      throws: DissError.structSingleton,
      performing: { try dissSet(policy: .singleton) { BadSingleton() } }
    )
  }

  @Test func testSetUniqueSuccess() {
    do {
      try dissSet(policy: .unique) { UniqueClass(number: 1) }
    } catch {
      print(error)
    }
    @DissGet
    var uniqueObject1: UniqueClass?
    uniqueObject1?.number = 2
    @DissGet
    var uniqueObject2: UniqueClass?
    uniqueObject2?.number = 3
    #expect(uniqueObject1?.number == 2)
    #expect(uniqueObject2?.number == 3)
  }

  @Test func testSetUniqueFailure() {
  #expect(
      throws: DissError.multipleSet(type: "UniqueClass"),
      performing: {
        try dissSet(policy: .unique) { UniqueClass(number: 1) }
        try dissSet(policy: .singleton) { UniqueClass(number: 1) }
      }
    )

  }

  @Test func testSetFactorySuccess() {
    do {
      try dissSet(policy: .factory) { ServiceImpl() }
    } catch {
      print(error)
    }

    @DissGet
    var service1: ServiceImpl?
    service1?.number = 2
    @DissGet
    var service2: ServiceImpl?
    #expect(service2?.number == 2)
  }

  @Test func testAssistSuccess() {
    do {
      try dissAssist(policy: .unique) { (args: [Any]) in
          ThreeArgs(first: try dissCast(args[0]), second: try dissCast(args[1]), third: try dissCast(args[2])
        )
      }
      try dissAssist(policy: .unique) { (args: [Any]) in Converter(number: try dissCast(args[0])) }
    } catch {
      print(error)
    }

    @DissGetAssisted(arguments: [0.3339])
    var converter: Converter?
    #expect(converter?.convert() == 0.334)

    @DissGetAssisted(arguments: [1, 2.1, "Hello"])
    var threeArgs: ThreeArgs?
    #expect(threeArgs?.first == 1)
    #expect(threeArgs?.second == 2.1)
    #expect(threeArgs?.third == "Hello")

  }

  @Test func testAssistFailure() {
  do {
    try dissAssist(policy: .unique) { (args: [Any]) in Converter(number: try dissCast(args[0])) }
  } catch {
    print(error)
  }

  @DissGetAssisted(arguments: ["String"])
  var converter: Converter?

  #expect(converter == nil)
  #expect(throws: DissError.assistedNotUnique) {
    try dissAssist(policy: .singleton) { (args: [Any]) in Converter(number: try dissCast(args[0])) }
  }

  }

  @Test func testSingleWrapperSuccess() {
    do {
      try dissSet(policy: .singleton) { DissSingle(BadSingleton()) }
    } catch {
      print(error)
    }

    @DissGet
    var singleton1: DissSingle<BadSingleton>?
    @DissGet
    var singleton2: DissSingle<BadSingleton>?
    singleton1?.object.number = 10
    #expect(singleton2?.object.number == 10)
  }

  deinit {
    dissReset()
  }

}

class ServiceImpl: Service {
  var number: Int
  init() {
    number = 1
  }
}

protocol Service {
  var number: Int { get }
}

class Converter {
  var number: Double

  init(number: Double) {
    self.number = number
  }

  func convert() -> Double {
    return Double(round(1000 * number) / 1000)
  }
}

struct BadSingleton { var number = 3 }
protocol UseCase {}
class UseCase1: UseCase {}
class UseCase2: UseCase {}

class UniqueClass {
  var number: Int
  init(number: Int) {
    self.number = number
  }
}

struct ThreeArgs {
  let first: Int
  let second: Double
  let third: String
}
