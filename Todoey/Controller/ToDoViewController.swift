//
//  ViewController.swift
//  Todoey
//
//  Created by Ancy Thomas on 1/17/18.
//  Copyright © 2018 ThinkPalm. All rights reserved.
//

import UIKit
import CoreData

class ToDoViewController: UITableViewController {

    var itemArray = [Item]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        print(urls[urls.count-1] as URL)
        
        loadItems()
    }

    func loadItems(with request : NSFetchRequest<Item> = Item.fetchRequest()) {
        
        let predicate = NSPredicate(format: "parentCategory.title MATCHES %@", (self.selectedCategory?.title)!)
       
        if let requesPredicate = request.predicate {
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, requesPredicate])
            request.predicate = compoundPredicate
        }else {
            request.predicate = predicate
        }
        
        do {
            try itemArray = context.fetch(request)
        }catch {
            print("Error fetching data from context \(error)")
        }
        tableView.reloadData()
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New ToDo Item", message: "", preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "Add", style: .default) { (action) in
            if textField.text != "" {
                
                let item = Item(context: self.context)
                
                item.title = textField.text!
                
                item.done = false
                
                item.parentCategory = self.selectedCategory
                
                self.itemArray.append(item)
                
                self.saveItems()
               
                self.tableView.reloadData()
            }
        }
        
        alert.addTextField {
                (alertTextField) in
                alertTextField.placeholder = "Create new item"
                textField = alertTextField
        }
        
        alert.addAction(alertAction)
        
        present(alert, animated: true, completion: nil)
        
        }
    
    func saveItems(){
     
        do{
          try context.save()
        }catch{
            print("Error saving data item \(error)")
        }
        
    }
    
    //MARK - DataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return itemArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        cell.textLabel?.text = itemArray[indexPath.row].title
        
        cell.accessoryType = itemArray[indexPath.row].done ?  .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print(itemArray[indexPath.row])
        
        itemArray[indexPath.row].setValue(!itemArray[indexPath.row].done, forKey: "done")
        
        tableView.reloadData()
        
        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ToDoViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request : NSFetchRequest<Item> = Item.fetchRequest()        
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        //request.sortDescriptors = [NSSortDescriptor(key: title, ascending: true)]
        
        loadItems(with: request)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
        }
    }
}
