import UIKit
import XCTest
import Foundation

class Bug {
    enum State {
        case open
        case closed
    }
    
    let state: State
    let timestamp: Date
    let comment: String
    
    init(state: State, timestamp: Date, comment: String) {
        // To be implemented
        
        self.state = state
        self.timestamp = timestamp
        self.comment = comment
    }
    
    init(jsonString: String) throws {
        // To be implemented
        
        /* Exception enumerator */
        enum ParseError: Error {
            case parseError(String)
        }
        /* Extracting values from JSON */
        let data = jsonString.data(using: .utf8)
        let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
        
        if let dict = jsonObj as? NSDictionary {
            /* Variable Declarations */
            self.comment = dict.value(forKey: "comment") as! String
            let interval = TimeInterval(exactly: dict.value(forKey: "timestamp") as! Int)
            self.timestamp = Date(timeIntervalSince1970: interval!)
            let stateString = dict.value(forKey: "state") as! String
            self.state = stateString == "open" ? State.open : State.closed
        }
        else {
            /* Handling String parse error exception */
            throw ParseError.parseError("Could not parse string")
        }
    }
}

enum TimeRange {
    case pastDay
    case pastWeek
    case pastMonth
}

class Application {
    var bugs: [Bug]
    
    init(bugs: [Bug]) {
        self.bugs = bugs
    }
    
    func findBugs(state: Bug.State?, timeRange: TimeRange) -> [Bug] {
        // To be implemented
        
        /* Initializing output array */
        var outputBugs: [Bug] = []
        
        /* Initializing constant representations of ( pastDay - pastWeek - pastMonth ) */
        let dayAgo = Date().addingTimeInterval(-1 * (24 * 60 * 60))
        let weekAgo = Date().addingTimeInterval(-1 * (7 * 24 * 60 * 60))
        let monthAgo = Date().addingTimeInterval(-1 * (4 * 7 * 24 * 60 * 60))
        
        /* Looping on all bugs initialized in Application */
        for bug in bugs
        {
            
            /* Insert current bug into the output array, if,
             * input state matches current bug state OR input state is nil
             * AND input timeRange matches current bug timeStamp
             */
            if (state == nil) || (state == bug.state)
            {
                switch timeRange {
                case .pastDay:
                    if bug.timestamp >= dayAgo
                    {
                        outputBugs.append(bug)
                    }
                case .pastWeek:
                    if bug.timestamp >= weekAgo
                    {
                        outputBugs.append(bug)
                    }
                case .pastMonth:
                    if bug.timestamp >= monthAgo
                    {
                        outputBugs.append(bug)
                    }
                }
            }
        }
        
        return outputBugs
    }
}

class UnitTests : XCTestCase {
    lazy var bugs: [Bug] = {
        var date26HoursAgo = Date()
        date26HoursAgo.addTimeInterval(-1 * (26 * 60 * 60))
        
        var date2WeeksAgo = Date()
        date2WeeksAgo.addTimeInterval(-1 * (14 * 24 * 60 * 60))
        
        let bug1 = Bug(state: .open, timestamp: Date(), comment: "Bug 1")
        let bug2 = Bug(state: .open, timestamp: date26HoursAgo, comment: "Bug 2")
        let bug3 = Bug(state: .closed, timestamp: date2WeeksAgo, comment: "Bug 2")
        
        return [bug1, bug2, bug3]
    }()
    
    lazy var application: Application = {
        let application = Application(bugs: self.bugs)
        return application
    }()
    
    // Test 1
    func testFindOpenBugsInThePastDay() {
        let bugs = application.findBugs(state: .open, timeRange: .pastDay)
        XCTAssertTrue(bugs.count == 1, "Invalid number of bugs")
        XCTAssertEqual(bugs[0].comment, "Bug 1", "Invalid bug order")
        
    }
    
    // Test 2
    func testFindClosedBugsInThePastMonth() {
        let bugs = application.findBugs(state: .closed, timeRange: .pastMonth)
        
        XCTAssertTrue(bugs.count == 1, "Invalid number of bugs")
    }
    
    // Test 3
    func testFindClosedBugsInThePastWeek() {
        let bugs = application.findBugs(state: .closed, timeRange: .pastWeek)
        
        XCTAssertTrue(bugs.count == 0, "Invalid number of bugs")
    }
    
    // Test 4
    func testInitializeBugWithJSON() {
        do {
            let json = "{\"state\": \"open\",\"timestamp\": 1493393946,\"comment\": \"Bug via JSON\"}"
            
            let bug = try Bug(jsonString: json)
            
            XCTAssertEqual(bug.comment, "Bug via JSON")
            XCTAssertEqual(bug.state, .open)
            XCTAssertEqual(bug.timestamp, Date(timeIntervalSince1970: 1493393946))
        } catch {
            print(error)
        }
    }
}

class PlaygroundTestObserver : NSObject, XCTestObservation {
    @objc func testCase(_ testCase: XCTestCase, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: UInt) {
        print("Test failed on line \(lineNumber): \(String(describing: testCase.name)), \(description)")
    }
}

let observer = PlaygroundTestObserver()
let center = XCTestObservationCenter.shared()
center.addTestObserver(observer)

TestRunner().runTests(testClass: UnitTests.self)
