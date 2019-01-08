//
// THIS IS NOT PART OF THE PITCH, JUST AN EXAMPLE HOW A LOGGER IMPLEMENTATION LOOKS LIKE
//

import Foundation
import Logging

// helper class to keep things DRY
internal final class SimpleLogger {
    let label: String
    private var _logLevel: Logging.Level?
    private let formatter: DateFormatter
    private let lock = NSLock()

    public init(label: String) {
        self.label = label
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.locale = Locale(identifier: "en_US")
        formatter.calendar = Calendar(identifier: .gregorian)
        self.formatter = formatter
    }

    public func log(level: Logging.Level, message: String, error: Error?, printer: (String) -> Void) {
        printer("[\(self.label)] \(self.formatter.string(from: Date()))\(self.prettyMetadata.map { " \($0)" } ?? "") \(level): \(message)\(error.map { " \($0)" } ?? "")")
    }

    public var logLevel: Logging.Level? {
        get {
            return self.lock.withLock { self._logLevel }
        }
        set {
            self.lock.withLock {
                self._logLevel = newValue
            }
        }
    }

    private var prettyMetadata: String?
    private var _metadata = Logging.Metadata() {
        didSet {
            self.prettyMetadata = !self._metadata.isEmpty ? self._metadata.map { "\($0)=\($1)" }.joined(separator: " ") : nil
        }
    }

    public var metadata: Logging.Metadata {
        get {
            return self.lock.withLock { self._metadata }
        }
        set {
            self.lock.withLock { self._metadata = newValue }
        }
    }

    public subscript(metadataKey metadataKey: String) -> Logging.Metadata.Value? {
        get {
            return self.lock.withLock { self._metadata[metadataKey] }
        }
        set {
            self.lock.withLock {
                self._metadata[metadataKey] = newValue
            }
        }
    }
}

private extension NSLock {
    func withLock<T>(_ body: () -> T) -> T {
        self.lock()
        defer {
            self.unlock()
        }
        return body()
    }
}
