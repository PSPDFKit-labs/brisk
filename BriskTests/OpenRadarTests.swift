// swiftlint:disable line_length
import Brisk
import Sonar
import XCTest

final class OpenRadarTests: XCTestCase {
    func testDeserializingJSON() {
        let json = loadOpenRadarJSON()
        guard let radar = try? Radar(openRadar: json) else {
            return XCTFail("Failed to deserializing open radar JSON")
        }

        XCTAssertEqual(radar.classification, .OtherBug)
        XCTAssertEqual(radar.product, .DeveloperTools)
        XCTAssertEqual(radar.reproducibility, .Always)
        XCTAssertEqual(radar.version, "Xcode 9.0")
        XCTAssertEqual(radar.configuration, "Xcode 9.0")
        XCTAssertEqual(radar.title, "Some title")
        XCTAssertEqual(radar.description, "This is a duplicate of radar #1234\n\nSummary:\r\nfoo\n\nbar\nbaz\n\r\n\r\nSteps to Reproduce:\r\n1. foo\n2. bar\n\r\n\r\nExpected Results:\r\nfoo\n\r\n\r\nActual Results:\r\nbar\n\r\n\r\nVersion:\r\nXcode 9.0\r\n\r\nNotes:\r\n\r\nsome notes\n")
        XCTAssertEqual(radar.steps, " ")
        XCTAssertEqual(radar.expected, " ")
        XCTAssertEqual(radar.actual, " ")
        XCTAssertEqual(radar.notes, " ")
    }

    func testOpenRadarMissingResult() {
        do {
            _ = try Radar(openRadar: [:])
            XCTFail("Radar shouldn't be valid")
        } catch let error as OpenRadarParsingError {
            XCTAssertEqual(error, .noResult)
        } catch {
            XCTFail("Got invalid error")
        }
    }

    func testOpenRadarMissingTitle() {
        do {
            _ = try Radar(openRadar: ["result": [:]])
            XCTFail("Radar shouldn't be valid")
        } catch let error as OpenRadarParsingError {
            XCTAssertEqual(error, .missingRequiredFields)
        } catch {
            XCTFail("Got invalid error")
        }
    }
}

private func loadOpenRadarJSON() -> [String: Any] {
    let url = Bundle(for: OpenRadarTests.self).url(forResource: "openradar", withExtension: "json")!
    return try! Data(contentsOf: url).toJSONDictionary()!
}
