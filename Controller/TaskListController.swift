//  Task TaskListController.swift
//  To-Do Manager
//  Created by Ilya Zablotski

import UIKit

class TaskListController: UITableViewController {
    
    var isLoadingTasks = false
    // Tasks storage
    var tasksStorage: TasksStorageProtocol = TasksStorage()
    // Tasks collection
    var tasks: [TaskPriority: [TaskProtocol]] = [:] {
        didSet {
            // sort table
            for (tasksGroupPriority, tasksGroup) in tasks {
                tasks[tasksGroupPriority] = tasksGroup.sorted { task1, task2 in
                    let task1position = tasksStatusPosition.firstIndex(of: task1.status) ?? 0
                    let task2position = tasksStatusPosition.firstIndex(of: task2.status) ?? 0
                    return task1position < task2position
                }
            }
            
            guard !isLoadingTasks else { return }
            
            // task save
            var savingArray: [TaskProtocol] = []
            for (_, value) in tasks {
                savingArray += value
            }
            tasksStorage.saveTasks(savingArray)
        }
    }
    
    // array index equal table section index
    var sectionsTypesPosition: [TaskPriority] = [.important, .normal]
    
    // порядок отображения задач по их статусу
    var tasksStatusPosition: [TaskStatus] = [.planned, .completed]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MessageCell")
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .customGold
        loadTasks()
        // edit button
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    private func loadTasks() {
        isLoadingTasks = true
        
        for taskType in sectionsTypesPosition {
            tasks[taskType] = []
        }
        
        for task in tasksStorage.loadTasks() {
            tasks[task.type]?.append(task)
        }
        
        isLoadingTasks = false
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tasks.count
    }
    
    // get the list of tasks, parse them and set them to the tasks property
    func setTasks(_ tasksCollection: [TaskProtocol]) {
        for taskType in sectionsTypesPosition {
            tasks[taskType] = []
        }
        
        for task in tasksCollection {
            tasks[task.type]?.append(task)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // define the task priority corresponding to the current section
        let taskType = sectionsTypesPosition[section]
        guard let currentTasksType = tasks[taskType] else {
            return 0
        }
        return currentTasksType.count
    }
    
    // cell for the table row
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getConfiguredTaskCell_stack(for: indexPath)
    }
    
    // MARK: Table Data with constraints
    
    private func getConfiguredTaskCell_constraints(for indexPath: IndexPath) -> UITableViewCell {
        // load the cell prototype by identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCellConstraints", for: indexPath)
        // get data about the task to be displayed in the cell
        let taskType = sectionsTypesPosition[indexPath.section]
        guard let currentTask = tasks[taskType]?[indexPath.row] else {
            return cell
        }
        
        let symbolLabel = cell.viewWithTag(1) as? UILabel
        let textLabel = cell.viewWithTag(2) as? UILabel
        
        symbolLabel?.text = getSymbolForTask(with: currentTask.status)
        textLabel?.text = currentTask.title
        
        if currentTask.status == .planned {
            textLabel?.textColor = .black
            symbolLabel?.textColor = .black
        } else {
            textLabel?.textColor = .lightGray
            symbolLabel?.textColor = .lightGray
        }
        return cell
    }
    
    // return the symbol for the corresponding task type
    private func getSymbolForTask(with status: TaskStatus) -> String {
        var resultSymbol: String
        if status == .planned {
            resultSymbol = "\u{25CB}"
        } else if status == .completed {
            resultSymbol = "\u{25C9}"
        } else {
            resultSymbol = ""
        }
        return resultSymbol
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()

        let headerLabel = UILabel(frame: CGRect(x: 15, y: 8, width:
            tableView.bounds.size.width, height: tableView.bounds.size.height))
        headerLabel.font = UIFont(name: "Arial-BoldMT", size: 19)
        headerLabel.textColor = UIColor.label

        let tasksType = sectionsTypesPosition[section]
        if tasksType == .important {
            headerLabel.text = "Important"
        } else if tasksType == .normal {
            headerLabel.text = "Current"
        }

        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }

    // MARK: Table Data with Horizontal Stack View
    
    // stack-based cell
    private func getConfiguredTaskCell_stack(for indexPath: IndexPath) -> UITableViewCell {
        // load the cell prototype by identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCellStack", for: indexPath) as! TaskCell
        // get the task data to be displayed in the cell
        let taskType = sectionsTypesPosition[indexPath.section]
        guard let currentTask = tasks[taskType]?[indexPath.row] else {
            return cell
        }
        
        cell.title.text = currentTask.title
        cell.symbol.text = getSymbolForTask(with: currentTask.status)
        
        if currentTask.status == .planned {
            cell.title.textColor = UIColor.label
            cell.symbol.textColor = .customGold
            cell.symbol.font = .boldSystemFont(ofSize: 20)
        } else {
            cell.title.textColor = .lightGray
            cell.symbol.textColor = .lightGray
            cell.symbol.font = .boldSystemFont(ofSize: 20)
        }
        return cell
    }
    
    // MARK: Change tasks status (planned -> comleted)
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let taskType = sectionsTypesPosition[indexPath.section]
        guard let _ = tasks[taskType]?[indexPath.row] else {
            return
        }
        
        guard tasks[taskType]![indexPath.row].status == .planned else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        tasks[taskType]![indexPath.row].status = .completed
        tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .automatic)
    }
    
    // MARK: Change tasks status (comleted -> planned)
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let taskType = sectionsTypesPosition[indexPath.section]
        guard let _ = tasks[taskType]?[indexPath.row] else {
            return nil
        }
        
        let actionSwipeInstance = UIContextualAction(style: .normal, title: "Не выполнена") { _, _, _ in
            self.tasks[taskType]![indexPath.row].status = .planned
            self.tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .automatic)
        }
        
        // action to switch to the edit screen
        let actionEditInstance = UIContextualAction(style: .normal, title: "Изменить") { _, _, _ in
            let editScreen = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "TaskEditController") as! TaskEditController
            // passing the values of the edited task
            editScreen.taskText = self.tasks[taskType]![indexPath.row].title
            editScreen.taskType = self.tasks[taskType]![indexPath.row].type
            editScreen.taskStatus = self.tasks[taskType]![indexPath.row].status
            editScreen.title = "Edit Task"
            // passing a handler to save the task
            editScreen.doAfterEdit = { [self] title, type, status in
                let editedTask = Task(title: title, type: type, status: status)
                tasks[taskType]!.remove(at: indexPath.row)
                tasks[type]?.append(editedTask)
                tableView.reloadData()
            }
            
            self.navigationController?.pushViewController(editScreen, animated: true)
        }
        
        actionEditInstance.backgroundColor = .darkGray
        
        let actionsConfiguration: UISwipeActionsConfiguration
        if tasks[taskType]![indexPath.row].status == .completed {
            actionsConfiguration = UISwipeActionsConfiguration(actions: [actionSwipeInstance, actionEditInstance])
        } else {
            actionsConfiguration = UISwipeActionsConfiguration(actions:
                [actionEditInstance])
        }
        return actionsConfiguration
    }
    
    // MARK: Delete row (task) method
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let taskType = sectionsTypesPosition[indexPath.section]
        // удаляем задачу
        tasks[taskType]?.remove(at: indexPath.row)
        // удаляем строку, соответствующую задаче
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    // MARK: Manual sorting of rows (tasks).
    
    // manual sorting of the task list
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let taskTypeFrom = sectionsTypesPosition[sourceIndexPath.section]
        let taskTypeTo = sectionsTypesPosition[destinationIndexPath.section]
        
        guard let movedTask = tasks[taskTypeFrom]?[sourceIndexPath.row] else {
            return
        }

        tasks[taskTypeFrom]!.remove(at: sourceIndexPath.row)
        tasks[taskTypeTo]!.insert(movedTask, at: destinationIndexPath.row)

        if taskTypeFrom != taskTypeTo {
            tasks[taskTypeTo]![destinationIndexPath.row].type = taskTypeTo
        }

        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCreateScreen" {
            let destination = segue.destination as! TaskEditController
            destination.doAfterEdit = { [unowned self] title, type, status in
                let newTask = Task(title: title, type: type, status: status)
                tasks[type]?.append(newTask)
                tableView.reloadData()
            }
        }
    }
}
