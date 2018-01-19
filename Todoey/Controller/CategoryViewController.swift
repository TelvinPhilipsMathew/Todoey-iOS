//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Ancy Thomas on 1/19/18.
//  Copyright © 2018 ThinkPalm. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {

    
    var categoryArray = [Category]()
    let context  = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return categoryArray.count
    }

   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryItemCell", for: indexPath)

        cell.textLabel?.text = categoryArray[indexPath.row].title as! String
        
        return cell
    }

    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "goToItems"){
            let destination = segue.destination as! ToDoViewController
            
            if let indexPath = tableView.indexPathForSelectedRow {
               destination.selectedCategory = categoryArray[indexPath.row]
            }
        }
    }
    
    //MARK - Category Add Button Click
    @IBAction func addCategoryButtonPressed(_ sender: Any) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add Category", message: "", preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "Add", style: .default) { (alertAction) in
            
            if textField.text == ""{
                return
            }
            
            let category = Category(context: self.context)
            category.title = textField.text
            
            self.categoryArray.append(category)
            
            self.tableView.reloadData()
            
            self.saveCategory()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        
        alert.addAction(alertAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func saveCategory () {
        
        do {
            try context.save()
        }catch {
            print("Error saving context \(error)")
        }
    }
    
    func loadCategories (with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        
        do {
            categoryArray = try context.fetch(request)
        } catch {
            print("Error fetching category \(error)")
        }
    }
    
    
}
