//
//  RandomInitializable.swift
//  RandomFactory
//
//  Created by Brian Strobach on 5/15/18.
//

import Foundation
import RuntimeExtensions
import CodableExtensions
import Runtime
import Fakery
import PlaceholderImages
import Avatars
import Codability

public typealias RandomInitializable = Decodable

public enum RandomValueGeneratorError : Error {
	case typeMismatch
	case unencodable
	case optionalityMismatch
}

public typealias RandomValueGenerator = (PropertyInfo) -> Any?
extension RandomFactory{
	public static let explicitNil = "RandomFactory.ExplicitNilValue"
}
public class RandomFactory{

	public var generator: RandomEncodableGenerator
	public static let shared: RandomFactory = RandomFactory()


    public func register<E: CaseIterable & RawRepresentable>(enumType: E.Type) throws {
        let name = try! Runtime.typeInfo(of: enumType).name
        generator.enumFactory[name] = { E.allCases.randomElement()!.rawValue }
    }
	public init(maxKeywordDistance: Int? = nil){
		self.generator = RandomEncodableGenerator(maxKeywordDistance: maxKeywordDistance)
	}
	public func randomEncodedData(decodableTo type: Any.Type, overrides: RandomValueGenerator? = nil) throws -> Data{
		return try generator.randomDictionary(decodableTo: type, overrides: overrides).encodeAsJSONData()
	}

	public func randomized<O: Decodable>(type: O.Type = O.self, overrides: RandomValueGenerator? = nil) throws -> O{
		let data = try randomEncodedData(decodableTo: type, overrides: overrides)
		return try O.decode(fromJSON: data)
	}

	public func randomizedArray<O: Decodable>(of size: Int, elementType type: O.Type = O.self, overrides: RandomValueGenerator? = nil) throws -> [O]{
		var array: [O] = []
		for _ in 1...size{
			array.append(try randomized(type: type, overrides: overrides))
		}
		return array
	}
}


extension PropertyInfo{
	public func hashKey() throws -> String {
        return try Runtime.typeInfo(of: ownerType).name + "_" + name
	}
}

public class RandomEncodableGenerator{
	private var cache: [String : ContentType] = [:]
	private var parentCache: [String : ParentType] = [:]
	private lazy var faker: Faker = Faker()
	public var maxKeywordDistance: Int?
    var enumFactory: [String : () -> Any] = [:]

	public init(maxKeywordDistance: Int? = nil){
		self.maxKeywordDistance = maxKeywordDistance
	}
    public func randomDictionary(decodableTo type: Any.Type, collectionSize: Int = 5, overrides: RandomValueGenerator? = nil) throws -> AnyDictionary{
		var dict: AnyDictionary = [:]

		for property in try properties(type){
			if let override = overrides?(property) {
				if (override as? String) == RandomFactory.explicitNil{
//					if isOptionalType(property.type){
						continue
//					}
//					else {
//						throw RandomValueGeneratorError.optionalityMismatch
//					}
				}
				dict[property.name] = override
			}

			guard let randomValue = try randomValue(for: property) else { continue }
			//			print("Setting random value \(randomValue) for property \(property.name)")
            dict[property.name] = randomValue
		}
		return dict
	}

	public func randomValue(for property: PropertyInfo, collectionSize: Int = 5, maxDistance: Int? = nil) throws -> Any?{
		do{
            if try property.isArray(), let elementType = try property.elementTypeInfo() {
                var array: [Any] = []
                for _ in 0..<collectionSize {
                    if elementType.isEnum() {
                        if let randomCase = try randomEnumCase(for: elementType) {
                            array.append(randomCase)
                        }
                    }
                    else if let value = try randomValue(ofType: elementType.type, for: property, maxDistance: maxDistance) {
                        array.append(value)
                    }
                }
                return array
            }
            if try property.isEnum() {
                return try randomEnumCase(for: try property.typeInfo())
            }
			return try randomValue(ofType: property.type, for: property, maxDistance: maxDistance)
		}
		catch{
			return try randomValue(ofType: property.type, for: property, maxDistance: maxDistance)
		}
	}

    public func randomEnumCase(for typeInfo: TypeInfo) throws -> Any?{
        guard typeInfo.isEnum() else { return nil}


        if let generator = self.enumFactory[typeInfo.name] {
            let value = generator()
            return value
        }

        guard let randomCase = typeInfo.cases.randomElement()?.name else {
            return nil
        }
        return randomCase
    }

	public func contentType(forProperty property: PropertyInfo, maxDistance: Int? = nil) throws -> ContentType{
		let hashKey = try property.hashKey()
		guard let cachedType = cache[hashKey] else{
			let calculatedType = ContentType.closestMatch(ofString: property.name, maxDistance: maxDistance ?? maxKeywordDistance)
			cache[hashKey] = calculatedType
			return calculatedType
		}
		return cachedType
	}

	public func parentType(forClass classType: Any.Type, maxDistance: Int? = nil) throws -> ParentType{
		let hashKey = String(describing: classType)
		guard let cachedType = parentCache[hashKey] else{
			let calculatedType = ParentType.closestMatch(ofString: hashKey, maxDistance: maxDistance ?? maxKeywordDistance)
			parentCache[hashKey] = calculatedType
			return calculatedType
		}
		return cachedType
	}

	public func randomValue(ofType type: Any.Type, for property: PropertyInfo, collectionSize: Int = 5, maxDistance: Int? = nil) throws -> Any?{
		let contentType: ContentType = try self.contentType(forProperty: property, maxDistance: maxDistance)
		return try randomValue(ofType: type, forPropertyNamed: property.name, withOwnerOfType: property.ownerType, contentType: contentType)

	}


	public func randomValue(ofType type: Any.Type,
                            forPropertyNamed propertyName: String? = nil,
                            withOwnerOfType ownerType: Any.Type? = nil,
                            collectionSize: Int = 5,
                            contentType: ContentType = .unknown) throws -> Any?{

		let optionalHasValue = faker.number.randomBool()

		switch type{
		case is Optional<String>.Type:
			return optionalHasValue ? randomString(forContentType: contentType, named: propertyName, withOwnerOfType: ownerType): nil
		case is Optional<Bool>.Type:
			return optionalHasValue ? randomBool(forContentType: contentType, named: propertyName, withOwnerOfType: ownerType) : nil
		case is Optional<Double>.Type:
			return optionalHasValue ? randomDouble(forContentType: contentType, named: propertyName, withOwnerOfType: ownerType) : nil
		case is Optional<Int>.Type:
			return optionalHasValue ? randomInt(forContentType: contentType, named: propertyName, withOwnerOfType: ownerType) : nil
		case is Optional<Date>.Type:
			return optionalHasValue ? randomDate(forContentType: contentType, named: propertyName, withOwnerOfType: ownerType) : nil
		case is Optional<URL>.Type:
			return optionalHasValue ? randomURL(forContentType: contentType, named: propertyName, withOwnerOfType: ownerType) : nil
		case is Optional<Encodable>.Type:
			return optionalHasValue ? try randomDictionary(decodableTo: type) : nil
		case is String.Type:
			return randomString(forContentType: contentType, named: propertyName, withOwnerOfType: ownerType)
		case is Bool.Type:
			return randomBool(forContentType: contentType, named: propertyName, withOwnerOfType: ownerType)
		case is Double.Type:
			return randomDouble(forContentType: contentType, named: propertyName, withOwnerOfType: ownerType)
		case is Int.Type:
			return randomInt(forContentType: contentType, named: propertyName, withOwnerOfType: ownerType)
		case is Date.Type:
			return randomDate(forContentType: contentType, named: propertyName, withOwnerOfType: ownerType)
		case is URL.Type:
			return randomURL(forContentType: contentType, named: propertyName, withOwnerOfType: ownerType)
//        case is Array<Encodable>.Type:
//            var array: [Any] = []
//            for _ in 0...collectionSize {
//                if let value = try randomValue(ofType: type,
//                                               forPropertyNamed: propertyName,
//                                               withOwnerOfType: ownerType,
//                                               contentType: contentType) {
//                    array.append(value)
//                }
//            }
//            return array
		case is Encodable.Type:
			return try randomDictionary(decodableTo: type)
		default:
			print("Unhandled type \(type) for property \(String(describing: propertyName))in randomizer. Add case over override.")
			return nil
		}
	}


	public func randomString(forContentType contentType: ContentType? = nil, named propertyName: String? = nil, withOwnerOfType ownerType: Any.Type? = nil) -> String{
		guard let contentType = contentType else {
			return faker.lorem.word()
		}

		switch contentType{
		case .unknown:
			return faker.lorem.word()
		case .thoroughfare:
			return faker.address.streetName()
		case .subThoroughfare:
			return faker.address.buildingNumber()
		case .secondaryAddress:
			return faker.address.secondaryAddress()
		case .subLocality:
            return faker.address.county()
//			return faker.address.neighborhood()
		case .locality:
			return faker.address.city()
		case .subAdministrativeArea:
			return faker.address.county()
		case .administrativeArea:
			return faker.address.state()
		case .stateAbbreviation:
			return faker.address.stateAbbreviation()
		case .postalCode:
			return faker.address.postcode()
		case .country:
			return faker.address.country()
		case .ISOCountryCode:
			return faker.address.countryCode()
		case .timeZone:
			return faker.address.timeZone()
		case .latitude, .longitude:
			return String(randomDouble(forContentType: contentType, named: propertyName))
		case .companyName:
			return faker.company.name()
		case .email:
			return faker.internet.safeEmail()
		case .id:
			return "\(faker.number.increasingUniqueId())"
		case .age:
			return String(randomInt(forContentType: contentType, named: propertyName))
		case .jobTitle:
			return faker.name.title()
		case .fullname:
			return faker.name.firstName() + faker.name.lastName()
		case .namePrefix:
			return faker.name.prefix()
		case .givenName:
			return faker.name.firstName()
		case .familyName:
			return faker.name.lastName()
		case .middleName:
			return faker.name.firstName()
		case .middleInitial:
			return faker.lorem.character()
		case .nameSuffix:
			return faker.name.suffix()
		case .nickname:
			return faker.name.prefix() + " " + faker.company.catchPhrase()
		case .username:
			return faker.internet.username()
		case .password:
			return faker.internet.password()
		case .ipAddress:
			return faker.internet.ipV6Address()
		case .productName:
			return faker.commerce.productName()
		case .price:
			return String(faker.commerce.price())
		case .sentence:
			return faker.lorem.sentence()
		case .paragraph:
			return faker.lorem.paragraph()
		case .fulltext:
			return faker.lorem.paragraphs(amount: 10)
		case .name, .title:
			let disambiguatedType = disambiguateContentType(forContentType: contentType, named: propertyName, withOwnerOfType: ownerType)
			return randomString(forContentType: disambiguatedType, named: propertyName)
		case .number:
			return String(randomInt(forContentType: contentType, named: propertyName))
		case .truthy:
			return "\(faker.number.randomBool())"
		case .url, .imageURL, .profileImage, .logoImage, .avatarImage:
			return randomURL(forContentType: contentType, named: propertyName).absoluteString
		}
	}

	public func disambiguateContentType(forContentType contentType: ContentType, named propertyName: String? = nil, withOwnerOfType ownerType: Any.Type? = nil) -> ContentType{
		guard let ownerType = ownerType else { return .unknown }

		let ownerName = String(describing: ownerType)
		let parentChildKeyPath = "\(ownerName)\(contentType.rawValue)"
		let parentChildCombinedType = ContentType.closestMatch(ofString: parentChildKeyPath)
		if parentChildCombinedType != .unknown { return parentChildCombinedType}

		do {
			let parentType = try self.parentType(forClass: ownerType)
			if parentType == .unknown { return .unknown }
			let parentChildTypeKeyPath = "\(parentType.rawValue)\(contentType.rawValue)"
			let parentChildCombinedType = ContentType.closestMatch(ofString: parentChildTypeKeyPath)
			return parentChildCombinedType
		}
		catch {
			return .unknown
		}
	}

	public func randomBool(forContentType contentType: ContentType? = nil, named propertyName: String? = nil, withOwnerOfType ownerType: Any.Type? = nil) -> Bool{
		//		guard let contentType = contentType else{
		return faker.number.randomBool()
		//		}

	}

	public func randomDouble(forContentType contentType: ContentType? = nil, named propertyName: String? = nil, withOwnerOfType ownerType: Any.Type? = nil) -> Double{
		guard let contentType = contentType else{
			return faker.number.randomDouble()
		}
		switch contentType{
		case .latitude:
			return faker.address.latitude()
		case .longitude:
			return faker.address.longitude()
		default:
			return faker.number.randomDouble()
		}
	}

	public func randomInt(forContentType contentType: ContentType? = nil, named propertyName: String? = nil, withOwnerOfType ownerType: Any.Type? = nil) -> Int{
		guard let contentType = contentType else{
			return faker.number.randomInt()
		}
		switch contentType{
		default:
			return faker.number.randomInt()
		}
	}

	public func randomDate(forContentType contentType: ContentType? = nil, named propertyName: String? = nil, withOwnerOfType ownerType: Any.Type? = nil) -> Date{
		//		guard let contentType = contentType else{

        let int = Int.random(in: 1...999999999)
		let randomTime = TimeInterval(int)
		return Date(timeIntervalSince1970: randomTime)
		//		}
	}

	public func randomURL(forContentType contentType: ContentType? = nil, named propertyName: String? = nil, withOwnerOfType ownerType: Any.Type? = nil) -> URL{
		let defaultUrl = URL(string: faker.internet.url()) ?? URL(string: "https://www.google.com")!
		guard let contentType = contentType else{
			return defaultUrl
		}
		switch contentType {
		case .imageURL:
			return .imageURL()
		case .profileImage:
			return .avatarImageURL(provider: .adorableAvatar(userIdentifier: faker.internet.username()))
		case .logoImage:
			return URL(string: faker.company.logo())!
		case .avatarImage:
			return .avatarImageURL(provider: .adorableAvatar(userIdentifier: faker.internet.username()))
		default: return defaultUrl
		}

	}
}

//Workaround for swift's lack of covariance and contravariance on Optional type
//Allows for check like '<type> is OptionalProtocol' or 'isOptional(instance)
fileprivate protocol OptionalProtocol {}

extension Optional : OptionalProtocol {}

fileprivate func isOptional(_ instance: Any) -> Bool {
	return instance is OptionalProtocol
}

fileprivate func isOptionalType(_ type: Any.Type) -> Bool {
	return type is OptionalProtocol.Type
}


extension String{

	public func equals(anyOf collection: Set<String>) -> Bool{
		return collection.contains(self)
	}
	public func isSubstringOf(anyOf collection: Set<String>) -> Bool{
		return collection.joined(separator: "_").lowercased().contains(self.lowercased())
	}
}


class Levenshtein {
	private(set) var cache = [Set<String.SubSequence>: Int]()

	public func calculateDistance(a: String, b: String) -> Int {
		return calculateDistance(a: String.SubSequence(a), b: String.SubSequence(b))
	}
	public func calculateDistance(a: String.SubSequence, b: String.SubSequence) -> Int {
		let key = Set([a, b])
		if let distance = cache[key] {
			return distance
		} else {
			let distance: Int = {
				if a.count == 0 || b.count == 0 {
					return abs(a.count - b.count)
				} else if a.first == b.first {
					return calculateDistance(a: a[a.index(after: a.startIndex)...], b: b[b.index(after: b.startIndex)...])
				} else {
					let add = calculateDistance(a: a, b: b[b.index(after: b.startIndex)...])
					let replace = calculateDistance(a: a[a.index(after: a.startIndex)...], b: b[b.index(after: b.startIndex)...])
					let delete = calculateDistance(a: a[a.index(after: a.startIndex)...], b: b)
					return min(add, replace, delete) + 1
				}
			}()
			cache[key] = distance
			return distance
		}
	}
}


extension PropertyInfo {
    func typeInfo() throws -> TypeInfo {
        try Runtime.typeInfo(of: type)
    }

    func isArray() throws -> Bool {
        try typeInfo().isArray()
    }

    func elementTypeInfo() throws -> TypeInfo? {
        try genericTypeInfo(at: 0)
    }

    func isEnum() throws -> Bool {
        try typeInfo().isEnum()
    }

    func genericTypeInfo(at index: Int) throws -> TypeInfo? {
        try typeInfo().genericTypeInfo(at: index)
    }

    func genericTypes() throws -> [Any.Type] {
        try typeInfo().genericTypes
    }

    func genericType(at index: Int) throws -> Any.Type? {
        try typeInfo().genericType(at: index)
    }
}


extension TypeInfo {
    func isArray() -> Bool {
        mangledName == "Array"
    }

    func elementTypeInfo() throws -> TypeInfo? {
        try genericTypeInfo(at: 0)
    }

    func isEnum() -> Bool {
        numberOfEnumCases > 0
    }

    func genericTypeInfo(at index: Int) throws -> TypeInfo? {
        guard let genericType = try genericType(at: index) else {
            return nil
        }

        return try Runtime.typeInfo(of: genericType)
    }


    func genericType(at index: Int) throws -> Any.Type? {
        guard genericTypes.count > index else {
            return nil
        }
        return genericTypes[index]
    }
}
