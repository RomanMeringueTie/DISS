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

  @Test func testSetScopeSuccess() {
    do {
      try dissSet(policy: .scope) { ScopeClass(number: 1) }
    } catch {
      print(error)
    }
    @DissGet
    var scopeObject1: ScopeClass?
    scopeObject1?.number = 2
    @DissGet
    var scopeObject2: ScopeClass?
    scopeObject2?.number = 3
    #expect(scopeObject1?.number == 2)
    #expect(scopeObject2?.number == 3)
  }

  @Test func testSetScopeFailure() {

    #expect(
      throws: DissError.multipleSet(type: "ScopeClass"),
      performing: { 
        try dissSet(policy: .scope) { ScopeClass(number: 1) }
        try dissSet(policy: .singleton) { ScopeClass(number: 1) }
      }
    )

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

struct BadSingleton {}
protocol UseCase {}
class UseCase1: UseCase {}
class UseCase2: UseCase {}

class ScopeClass {
  var number: Int
  init(number: Int) {
    self.number = number
  }
}