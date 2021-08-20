import XCTest
import RandomFactory
import CodableExtensions
import RuntimeExtensions

#if !os(Linux)
import CoreLocation
#endif

class SharedTests: XCTestCase {
    let factory = RandomFactory()

    override func setUpWithError() throws {
        try super.setUpWithError()
//        try factor.register(enumType: TestStringEnum.self)
        try factory.register(enumType: TestIntEnum.self)
    }
	func testRandomFactory() throws {
		let count = 5
		let users: [User] = try factory.randomizedArray(of: count)
		XCTAssertEqual(users.count, count)
		for user in users{
			try user.toAnyDictionary().printPrettyJSONString()
		}
	}

    func testNestedArray() throws {
        let count = 5
        let users: [Userbase] = try factory.randomizedArray(of: count)
        XCTAssertEqual(users.count, count)
        for user in users{
            try user.toAnyDictionary().printPrettyJSONString()
        }
    }
}

open class Userbase: Codable{
    public var users: [User]
    public var name: String
    public var dates: [Date]
    public var enumArray: [TestStringEnum]
    public var intEnumArray: [TestIntEnum]
}
public enum TestIntEnum: Int, Codable, CaseIterable {
    case case1
    case case2
    case case3
}

public enum TestStringEnum: String, Codable, CaseIterable {
    case case1
    case case2
    case case3
}

open class User: Codable{
    public var id: UUID
	public var name: Name
	public var username: String
	public var email: String
	public var jobTitle: String
	public var birthday: Date
	public var company: Company
	public var phoneNumber: String
	public var profileImageURL: URL
}

public struct Location: Codable{
	#if !os(Linux)
	var coordinate: CLLocationCoordinate2D
	#endif
	var thoroughfare: String
	var subThoroughfare: String
	var locality: String
	var subLocality: String
	var administrativeArea: String
	var subAdministrativeArea: String
	var postalCode: String
	var countryCode: String

}
public class Name: Codable{
	public var namePrefix: String
	public var givenName: String
	public var middleName: String
	public var familyName: String
	public var nameSuffix: String?
	public var nickname: String?
}

open class Company: Codable{
	public var name: String
	public var industry: String
	public var foundedOn: Date
	public var location: Location
	public var logoURL: URL
	public var products: [Product]
}

open class Product: Codable{
	public var name: String
	public var price: Int
	public var description: String
	public var image: URL
}

#if !os(Linux)
extension CLLocationCoordinate2D: ReflectionCodable{

	public init(from decoder: Decoder) throws {
		self.init()
		try decodeReflectively(from: decoder)
	}
}
#endif

