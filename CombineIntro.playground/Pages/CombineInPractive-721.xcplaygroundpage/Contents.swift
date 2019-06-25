import Foundation
import Combine
import SwiftUI
import PlaygroundSupport
import UIKit

extension Notification.Name {
    static let newTrickDownloaded = Notification.Name.init("newTrickDownloaded")
}


/*
 1. publisher: Notification / Never
 2. map: Data / Never
 3. flatMap: MagicTrick / Never
 4. publisher(for:): String / Never
 */

let trickNamePublisher = NotificationCenter.default.publisher(for: .newTrickDownloaded)
    .map { notification in
        notification.userInfo?["data"] as! Data
    }
    /*
     .tryMap { data in
        let decoder = JSONDecoder()
        try decoder.decode(MagicTrick.self, from data)
     }
     MagicTrick / Error
    */
    .flatMap { data in
        return Publishers.Just(data)
            .decode(type: MagicTrick.self, decoder: JSONDecoder())
            .catch { (error) -> Publishers.Just<MagicTrick> in
                return Publishers.Just(MagicTrick.placeholder)
        }
    }
//    .assertNoFailure() // MagicTrick, Never
    .publisher(for: \.name)
//    .sink { (name) in
//        print("Trick name: \(name)")
//    } // Attaches a subscriber with closure-based behavior.
    .receive(on: RunLoop.main)

let data1 = try? JSONEncoder().encode(["nameㄅ": "OMGGGGGG"])
NotificationCenter.default.post(name: .newTrickDownloaded, object: nil, userInfo: ["data": data1!])


let data2 = try? JSONEncoder().encode(["name": "WHAT!!!!!!!"])
NotificationCenter.default.post(name: .newTrickDownloaded, object: nil, userInfo: ["data": data2!])

let magicWordsSubject = PassthroughSubject<String, Never>()

let newTrickNamePublisher = NotificationCenter.default.publisher(for: .newTrickDownloaded)
    .map { notification in
        notification.userInfo?["data"] as! Data
    }
    .flatMap { data in
        return Publishers.Just(data)
            .decode(type: MagicTrick.self, decoder: JSONDecoder())
            .catch { (error) -> Publishers.Just<MagicTrick> in
                return Publishers.Just(MagicTrick.placeholder)
        }
    }
    .publisher(for: \.name)
newTrickNamePublisher.subscribe(magicWordsSubject)

magicWordsSubject.sink { (value) in
    print(value)
}
magicWordsSubject.send("Please")
let sharedTrickNamePublisher = newTrickNamePublisher.share()


class WizardTrick {
    var name: String = "a"
}

class Wand {
    let material = "Wood"
}

class WizardModel: BindableObject {
    
    var trick: WizardTrick { didSet { didChange.send(self) } }
    var wand: Wand? { didSet { didChange.send(self) } }
    
    let didChange = PassthroughSubject<WizardModel, Never>()
    
    init(trick: WizardTrick, wand: Wand? = nil) {
        self.trick = trick
        self.wand = wand
    }
}

let wizard = WizardModel(trick: WizardTrick())

struct TrickView: View {
    @ObjectBinding var model: WizardModel
    
    var body: some View {
        List {
            Text(model.trick.name)
        }
    }
}

let vc = UIHostingController(rootView: TrickView(model: wizard))
PlaygroundPage.current.liveView = vc
wizard.trick.name = "b"
PlaygroundPage.current.liveView = vc
/*:
 ![](PublisherDef2.png)
 ![](PracticeFlow.png)
 ![](PublisherTakeaway.png)
 ![](SubscriberDef.png)
 ![](SubscriberDef2.png)
 ![](SubscriberDef3.png)
 ![](SubscriberImageFlow.png)
 */
