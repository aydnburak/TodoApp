//
//  ViewController.swift
//  TodoApp
//
//  Created by Burak on 4.09.2022.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var taskstore = [[TaskEntity](), [TaskEntity]()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        getData()
    }
    
    func getData() {
        let tasks = DataBaseHelper.shareInstance.fetch()
        
        taskstore = [tasks.filter{$0.isDone == false},tasks.filter{$0.isDone == true}]
        
        tableView.reloadData()
    }
    
    
    @IBAction func addButton(_ sender: Any) {
        
        let alert = UIAlertController(title: "Add Task", message: nil, preferredStyle: .alert)
        let  addAction = UIAlertAction(title: "Add", style: .default){ [self] _ in
            guard let name = alert.textFields?.first?.text else {return}
            DataBaseHelper.shareInstance.save(name: name, isDone: false)
            self.getData()
            print(name)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addTextField{ textField in
            textField.placeholder = "Enter Task Name..."
        }
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        present(alert, animated: true,completion: nil)
    }

}

extension ViewController: UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "To-do":"Done"
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return taskstore.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskstore[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = taskstore[indexPath.section][indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: nil){ (action, sourceView, completionHandler) in
            let row = self.taskstore[indexPath.section][indexPath.row]
            DataBaseHelper.shareInstance.deleteData(name: row.name!)
            self.getData()
        }
        deleteAction.image = UIImage(named: "trash")
        deleteAction.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let doneAction = UIContextualAction(style: .normal, title: nil){ (action, sourceView, completionHandler) in
            let row = self.taskstore[indexPath.section][indexPath.row]
            DataBaseHelper.shareInstance.update(name: row.name!, isdone: true)
            self.getData()
        }
        doneAction.image = UIImage(named: "checkmark")
        doneAction.backgroundColor = #colorLiteral(red: 0.1960784314, green: 0.7450980392, blue: 0.6509803922, alpha: 1)
        
        return indexPath.section == 0 ? UISwipeActionsConfiguration(actions: [doneAction]): nil
    }
    
    
}

