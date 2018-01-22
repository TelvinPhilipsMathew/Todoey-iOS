//
//  SwipteTableViewController.swift
//  Todoey
//
//  Created by Ancy Thomas on 1/22/18.
//  Copyright © 2018 ThinkPalm. All rights reserved.
//

import UIKit
import SwipeCellKit

class SwipteTableViewController: UITableViewController, SwipeTableViewCellDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)as! SwipeTableViewCell
        cell.delegate = self
        
        return cell
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            self.updateModel(at: indexPath)
            self.tableView.reloadData()
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "delete")
        
        return [deleteAction]
    }
   
    func updateModel(at indexPath: IndexPath){
         self.tableView.reloadData()
    }
}
