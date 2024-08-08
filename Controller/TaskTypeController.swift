//  TaskTypeController.swift
//  To-Do Manager
//  Created by Ilya Zablotski

import UIKit

class TaskTypeController: UITableViewController {
    
    typealias TypeCellDescription = (type: TaskPriority, title: String, description: String)

    var selectedType: TaskPriority = .normal
    var doAfterTypeSelected: ((TaskPriority) -> Void)?

    private var taskTypesInformation: [TypeCellDescription] = [
        (type: .important, title: "Important", description: "This type of tasks is the highest priority for execution. All important tasks are displayed at the top of the task list"),
        (type: .normal, title: "Current", description: "Task with regular priority")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        let cellTypeNib = UINib(nibName: "TaskTypeCell", bundle: nil)
        tableView.register(cellTypeNib, forCellReuseIdentifier: "TaskTypeCell")
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskTypesInformation.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTypeCell", for: indexPath) as! TaskTypeCell
        let typeDescription = taskTypesInformation[indexPath.row]

        cell.typeTitle.text = typeDescription.title
        cell.typeDescription.text = typeDescription.description

        if selectedType == typeDescription.type {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedType = taskTypesInformation[indexPath.row].type

        doAfterTypeSelected?(selectedType)
        navigationController?.popViewController(animated: true)
    }
}
