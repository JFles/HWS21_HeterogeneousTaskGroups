//
//  ContentView.swift
//  Day2_Session2_HeteroTaskGroups_Example
//
//  Created by Jeremy Fleshman on 8/3/21.
//

import SwiftUI

/**
 https://hws.dev/username.json
 ​https://hws.dev/user-messages.json
 ​https://hws.dev/user-favorites.json
 */

struct User {
    let username: String
    let messages: [Message]
    let favorites: Set<Int>
}

struct Message: Codable, Identifiable {
    let id: Int
    let from: String
    let message: String
}

enum FetchResult {
    case username(String)
    case messages([Message])
    case favorites(Set<Int>)
}

struct ContentView: View {
    @State private var currentUser = User(username: "", messages: [], favorites: [])

    var body: some View {
        NavigationView {
            List(currentUser.messages) { message in
                HStack {
                    Text(message.from).bold()
                    if currentUser.favorites.contains(message.id) {
                        Image(systemName: "heart.fill")
                    }
                }
                Text(message.message)
            }
            .navigationTitle(currentUser.username.isEmpty ? "User" : currentUser.username)
            .task(loadData)
        }
    }

    func loadData() async {
        let user = await withThrowingTaskGroup(of: FetchResult.self) { group -> User in
            group.addTask {
                let url = URL(string: "https://hws.dev/username.json")!
                let result = try String(contentsOf: url, encoding: .utf8)
                return .username(result)
            }

            group.addTask {
                let url = URL(string: "https://hws.dev/user-messages.json")!
                let (data, _) = try await URLSession.shared.data(from: url)
                let result = try JSONDecoder().decode([Message].self, from: data)
                return .messages(result)
            }

            group.addTask {
                let url = URL(string: "https://hws.dev/user-favorites.json")!
                let (data, _) = try await URLSession.shared.data(from: url)
                let result = try JSONDecoder().decode(Set<Int>.self, from: data)
                return .favorites(result)
            }

            var username = ""
            var messages = [Message]()
            var favorites = Set<Int>()

            do {
                for try await value in group {
                    switch value {
                        case let .username(_username):
                            username = _username
                        case let .messages(_messages):
                            messages = _messages
                        case let .favorites(_favorites):
                            favorites = _favorites
                    }
                }
            } catch {
                print("Fetch at least partially failed; send back what we have so far.")
            }

            return User(username: username, messages: messages, favorites: favorites)

        }

        currentUser = user

        print(user.username)
        print(user.messages)
        print(user.favorites)
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
