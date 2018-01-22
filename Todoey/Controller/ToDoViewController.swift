//
//  ViewController.swift
//  Todoey
//
//  Created by Ancy Thomas on 1/17/18.
//  Copyright © 2018 ThinkPalm. All rights reserved.
//

import UIKit
import RealmSwift

class ToDoViewController: UITableViewController {

    var itemArray: Results<Item>?
    
    let realm = try! Realm()
   
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

    func loadItems() {
        
        itemArray = selectedCategory?.items.sorted(byKeyPath: "createdDate", ascending: true)
       tableView.reloadData()
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New ToDo Item", message: "", preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "Add", style: .default) { (action) in
            if textField.text != "" {
                
                if let currentCategory = self.selectedCategory {
                   
                    do {
                        try self.realm.write {
                            let item = Item()
                            item.title = textField.text!
                            item.done = false
                            item.createdDate = Date()
                            currentCategory.items.append(item)
                        }
                    }catch {
                        print("Error writing items \(error)")
                    }
                   
                }
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
    
    func saveItems(item: Item){
     
        do {
            try realm.write{
                realm.add(item)
            }
        } catch  {
            print ("Error while saving item \(error)")
        }
        
    }
    
    //MARK - DataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return itemArray?.count ?? 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        if  let item = itemArray?[indexPath.row] {
        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.done ?  .checkmark : .none
        }else {
            cell.textLabel?.text = "No items added yet"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if  let item = itemArray?[indexPath.row] {
            
            do {
                try realm.write {
                    item.done = !item.done
                }
            }catch {
                print("Error saving done item \(error)")
            }
        }
        
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ToDoViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
     itemArray = itemArray?.filter("title contains[cd] %@", searchBar.text).sorted(byKeyPath: "createdDate", ascending: true)
        self.tableView.reloadData()
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
