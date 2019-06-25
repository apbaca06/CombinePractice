import Foundation
import Combine


class Wizard {
    var grade: Int
    
    init(grade: Int) {
        self.grade = grade
    }
}

let merlin = Wizard(grade: 2)

extension Notification.Name {
    static let graduated = Notification.Name.init("graduated")
}

let graduationPublisher = NotificationCenter.Publisher(center: .default, name: .graduated, object: merlin)

let gradeSubscriber = Subscribers.Assign(object: merlin, keyPath: \.grade)
// Instance method 'subscribe' requires the types 'NotificationCenter.Publisher.Output' (aka 'Notification') and 'Int' be equivalent
//graduationPublisher.subscribe(gradeSubscriber)


let newGraduationPublisher = graduationPublisher.map { (notification) in
    return notification.userInfo?["NewGrade"] as? Int ?? 0
}

newGraduationPublisher.subscribe(gradeSubscriber)


print("Third Grade ..............\n")
NotificationCenter.default.post(name: .graduated, object: merlin, userInfo: ["NewGrade": 3])
print("Merlin Object: \(merlin.grade)")
print("Grade Subscriber: \(String(describing: gradeSubscriber.object?.grade))")

print("\nFourth Grade ..............\n")
NotificationCenter.default.post(name: .graduated, object: merlin, userInfo: ["NewGrade": 4])
print("Merlin Object: \(merlin.grade)")
print("Grade Subscriber: \(String(describing: gradeSubscriber.object?.grade))")


print("\nFifth Grade ..............\n")
NotificationCenter.default.post(name: .graduated, object: merlin, userInfo: ["NewGrade": 5])
print("Merlin Object: \(merlin.grade)")
print("Grade Subscriber: \(String(describing: gradeSubscriber.object?.grade))")

let merlinSecond = Wizard(grade: 2)

let cancellable = NotificationCenter.Publisher(center: .default,
                                               name: .graduated,
                                               object: merlinSecond)
    .compactMap { (notification) in
        return notification.userInfo?["NewGrade"] as? Int
    }
    .filter{ $0 >= 5}
    .prefix(4)
    .assign(to: \.grade, on: merlinSecond)

print("Third Grade ..............\n")
NotificationCenter.default.post(name: .graduated, object: merlinSecond, userInfo: ["NewGrade": 3])
print("Merlin Second Object: \(merlinSecond.grade)")

print("\nFourth Grade ..............\n")
NotificationCenter.default.post(name: .graduated, object: merlinSecond, userInfo: ["NewGrade": 4])
print("Merlin Second Object: \(merlinSecond.grade)")

print("\nFifth Grade ..............\n")
NotificationCenter.default.post(name: .graduated, object: merlinSecond, userInfo: ["NewGrade": 5])
print("Merlin Second Object: \(merlinSecond.grade)")
print("\nCancel cancellable ..............\n")
cancellable.cancel()

print("\nSixth Grade ..............\n")
NotificationCenter.default.post(name: .graduated, object: merlinSecond, userInfo: ["NewGrade": 6])
print("Merlin Second Object: \(merlinSecond.grade)")

/*:
 ![](Pattern.png)
 ![](PublisherDef.png)
 ![](PublisherNotificationCenter.png)
 ![](OperatorDef.png)
 ![](OperatorMap.png)
 ![](LackOfOperator.png)
 ![](SubscriberDef.png)
 ![](Assign.png)
 */
