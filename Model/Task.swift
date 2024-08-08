//  Task.swift
//  To-Do Manager
//  Created by Ilya Zablotski

import Foundation

// Task Type
enum TaskPriority {
    case normal
    case important
}

// Task Status
enum TaskStatus: Int {
    case planned
    case completed
}

protocol TaskProtocol {
    var title: String { get set }
    var type: TaskPriority { get set }
    var status: TaskStatus { get set }
}

// entity "Task"
struct Task: TaskProtocol {
    var title: String,
        type: TaskPriority,
        status: TaskStatus
}
