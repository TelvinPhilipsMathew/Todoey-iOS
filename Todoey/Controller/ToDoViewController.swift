//
//  ViewController.swift
//  Todoey
//
//  Created by Ancy Thomas on 1/17/18.
//  Copyright © 2018 ThinkPalm. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ToDoViewController: SwipteTableViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    
    var itemArray: Results<Item>?
    
    let realm = try! Realm()
   
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadItems()
        tableView.rowHeight = 100.0
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        if let color = selectedCategory?.color {
            navigationController?.navigationBar.barTintColor = UIColor(hexString: color)
            title = selectedCategory?.title
            searchBar.barTintColor = UIColor(hexString: color)
            navigationController?.navigationBar.tintColor = ContrastColorOf(UIColor(hexString: color)!, returnFlat: true)
            if #available(iOS 11.0, *) {
                navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : ContrastColorOf(UIColor(hexString: color)!, returnFlat: true)]
            } else {
                // Fallback on earlier versions
            }
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let originalColor = UIColor(hexString: "1D98F6") else {fatalError()}
        navigationController?.navigationBar.barTintColor = originalColor
        navigationController?.navigationBar.tintColor = FlatWhite()
    
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: FlatWhite()]
        } else {
            // Fallback on earlier versions
        }
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
    
    override func updateModel(at indexPath: IndexPath) {
        if let item = self.itemArray?[indexPath.row]{
            do {
                try realm.write {
                    realm.delete(item)
                }
            } catch {
                print("Error deleting item \(item)")
            }
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if  let item = itemArray?[indexPath.row] {
        cell.textLabel?.text = item.title
        
            if let color =  UIColor(hexString: (selectedCategory?.color)!)?.darken(byPercentage:(CGFloat(indexPath.row) / CGFloat(itemArray!.count)))
                 {
                cell.backgroundColor = color
                    cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            
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
        
        itemArray = itemArray?.filter("title contains[cd] %@", searchBar.text!).sorted(byKeyPath: "createdDate", ascending: true)
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
