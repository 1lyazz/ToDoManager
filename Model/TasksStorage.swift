//  TasksStorage.swift
//  To-Do Manager
//  Created by Ilya Zablotski

import Foundation

protocol TasksStorageProtocol {
    func loadTasks() -> [TaskProtocol]
    func saveTasks(_ tasks: [TaskProtocol])
}

// Entity "TasksStorage"
class TasksStorage: TasksStorageProtocol {
    
//    Test data
//    func loadTasks() -> [TaskProtocol] {
//        let testTasks: [TaskProtocol] = [
//            Task(title: "Помыть кота", type: .normal, status: .planned),
//            Task(title: "Купить Porshe", type: .important, status: .planned),
//            Task(title: "Посетить Шерлок", type: .important, status: .completed),
//            Task(title: "Начать бегать", type: .normal, status: .completed),
//            Task(title: "Пройти собеседование ", type: .important, status: .planned),
//            Task(title: "Ударить Мишу", type: .important, status: .planned),
//            Task(title: "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor", type: .important, status: .planned)
//        ]
//        return testTasks
//    }

    // Link to storage
    private var storage = UserDefaults.standard

    // The key that will be used to save and load the storage from User Defaults
    var storageKey: String = "tasks"

    // Enumeration with keys to write to User Defaults
    private enum TaskKey: String {
        case title
        case type
        case status
    }

    func loadTasks() -> [TaskProtocol] {
        var resultTasks: [TaskProtocol] = []
        let tasksFromStorage = storage.array(forKey: storageKey) as? [[String: String]] ?? []
        for task in tasksFromStorage {
            guard let title = task[TaskKey.title.rawValue],
                  let typeRaw = task[TaskKey.type.rawValue],
                  let statusRaw = task[TaskKey.status.rawValue]
            else {
                continue
            }
            let type: TaskPriority = typeRaw == "important" ? .important : .normal
            let status: TaskStatus = statusRaw == "planned" ? .planned : .completed
            resultTasks.append(Task(title: title, type: type, status: status))
        }
        return resultTasks
    }

    func saveTasks(_ tasks: [TaskProtocol]) {
        var arrayForStorage: [[String: String]] = []
        for task in tasks {
            var newElementForStorage: [String: String] = [:]
            newElementForStorage[TaskKey.title.rawValue] = task.title
            newElementForStorage[TaskKey.type.rawValue] = (task.type == .important) ? "important" : "normal"
            newElementForStorage[TaskKey.status.rawValue] = (task.status == .planned) ? "planned" : "completed"
            arrayForStorage.append(newElementForStorage)
        }
        storage.set(arrayForStorage, forKey: storageKey)
    }
}
