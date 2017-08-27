//
//  ViewController.swift
//  SimpleApp
//
//  Created by abc on 8/26/17.
//  Copyright © 2017 DOT. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

//    private var todoItems   = ToDoItem.getMockData()
    private var todoItems   = [ToDoItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title  = "To-Do"
        
        // add button '+' in right navigation bar
        self.navigationItem.rightBarButtonItem  = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(ViewController.didTapAdditemButton(_:)))
        
        // Setup a notification to let us know when the app is about to close,
        // and that we should store the user items to persistence. This will call the
        // applicationDidEnterBackground() function in this class
        NotificationCenter.default.addObserver(
        self,
        selector: #selector(UIApplicationDelegate.applicationDidEnterBackground(_:)),
        name: NSNotification.Name.UIApplicationDidEnterBackground,
        object: nil)
        
        do
        {
        // Try to load from persistence
        self.todoItems = try [ToDoItem].readFromPersistence()
        }
        catch let error as NSError
        {
        if error.domain == NSCocoaErrorDomain && error.code == NSFileReadNoSuchFileError
        {
        NSLog("No persistence file found, not necesserially an error...")
        }
        else
        {
        let alert = UIAlertController(
        title: "Error",
        message: "Could not load the to-do items!",
        preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
        NSLog("Error loading from persistence: \(error)")
        }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell    = tableView.dequeueReusableCell(withIdentifier: "cell_todo", for: indexPath)
        
        if indexPath.row < todoItems.count {
            let item    = todoItems[indexPath.row]
            cell.textLabel?.text    = item.title
            let accessory: UITableViewCellAccessoryType = item.done ? .checkmark : .none
            cell.accessoryType  = accessory
        }
    
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row < todoItems.count {
            let item    = todoItems[indexPath.row]
            item.done   = !item.done
            
            // refresh tableview in this row
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if indexPath.row < todoItems.count {
            todoItems.remove(at: indexPath.row) // delete data
            tableView.deleteRows(at: [indexPath], with: .bottom) // delete row of table view
        }
    }
    
    func didTapAdditemButton(_ sender: UIBarButtonItem) {
    
        // create an alert
        let alert   = UIAlertController(
            title: "New to-do item",
            message: "insert the title of the new to-do item:",
            preferredStyle: .alert)
        
        // add textfield
        alert.addTextField(configurationHandler: nil)
        
        // add button cancel
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // add button ok
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            if let title = alert.textFields?[0].text {
                self.addNewToDoItem(title: title)
            }
        }))

        // showing alert
        self.present(alert, animated:  true, completion: nil)
    }
    
    // add new title to 'To-Do list'
    func addNewToDoItem(title: String) {
        let lastIndex = todoItems.count
        todoItems.append(ToDoItem(title: title))
        
        // insert into tableview
        tableView.insertRows(at: [IndexPath(row: lastIndex, section: 0)], with: .left)
        
    }
    
    @objc
    public func applicationDidEnterBackground(_ notification: NSNotification)
    {
        do
        {
            try todoItems.writeToPersistence()
        }
        catch let error
        {
            NSLog("Error writing to persistence: \(error)")
        }
    }

}

