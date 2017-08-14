//
//  Log.swift
//  Copyright © 2017 gleesh. All rights reserved.
//

import Foundation


public struct Log: OptionSet {
	
	public let rawValue: UInt8
	public init(rawValue: UInt8) { self.rawValue = rawValue }
	
	static public var enabledTypes: Log = [.general, .network, .operations]
	static public var prefix: PrefixMode = [.date, .methodName, .line]
	
	public static let none: Log = []
	
	// MARK: - Types
	public static let general		= Log(rawValue: 1 << 0)
	public static let network		= Log(rawValue: 1 << 1)
	public static let operations	= Log(rawValue: 1 << 2)
	
	public func print(_ items: Any?..., separator: String = " ", terminator: String = "\n", _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
		#if DEBUG
			guard Log.enabledTypes.contains(self) else { return }
			
			let prefix = Log.prefix.generatePrefix(file: file, function: function, line: line)
			
			let validItems = items.flatMap { $0 }
			let validItemsArray = validItems.map { "\($0)" }
			let statement = validItemsArray.joined(separator: separator)
			
			let output = [prefix, statement].flatMap { $0 }.joined(separator: separator)
			
			Swift.print(output, terminator: terminator)
		#endif
	}
}


public struct PrefixMode: OptionSet {
	
	public let rawValue: UInt8
	public init(rawValue: UInt8) { self.rawValue = rawValue }
	
	public static let none			= PrefixMode(rawValue: 0)
	public static let date			= PrefixMode(rawValue: 1 << 0)
	public static let fileName		= PrefixMode(rawValue: 1 << 1)
	public static let methodName	= PrefixMode(rawValue: 1 << 2)
	public static let line			= PrefixMode(rawValue: 1 << 3)
	
	public func generatePrefix(file: String, function: String, line: Int, separator: String = " | ") -> String? {
		guard self != .none else { return nil }
		
		var components = [String]()
		
		if self.contains(.date) {
			let date = PrefixMode.formatter.string(from: Date())
			components.append(date)
		}
		
		if contains(.fileName) {
			components.append(file)
		}
		
		if contains(.methodName) {
			components.append(function)
		}
		
		if contains(.line) {
			components.append("\(line)")
		}
		
		let prefix = components.joined(separator: separator)
		
		return prefix.isEmpty ? nil : "[\(prefix)]"
	}
}


extension PrefixMode {
	
	static private let formatter: DateFormatter = {
		let value = DateFormatter()
		value.dateFormat = "yyyy.MM.dd HH:mm"
		return value
	}()
}
