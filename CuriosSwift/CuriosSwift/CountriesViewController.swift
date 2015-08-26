//
//  ViewController.swift
//  CountryFilter
//
//  Created by Emiaostein on 15/8/25.
//  Copyright (c) 2015年 BoTai Technology. All rights reserved.
//

import UIKit

protocol CountriesViewControllerDelegate: NSObjectProtocol {
  
  func countriesViewController(viewController: CountriesViewController, didSelectedZoneCode ZoneCode: String, countryName name: String)
  
}

class CountriesViewController: UIViewController {

  @IBOutlet weak var tablewVIew: UITableView!
  
  weak var selectedDelegate: CountriesViewControllerDelegate?
  
  let allCountryLocale = LocaleHelper.allCountriesFromLocalFile()
  
  lazy var keys: [String] = {
    return self.allCountryLocale.keys.array.sorted(<)
  }()
  
  var selectedIndexPath: NSIndexPath?
  
  let searchController: UISearchController = {
    let navi = UIStoryboard(name: "Independent", bundle: nil).instantiateViewControllerWithIdentifier("searchNavigationController") as! UINavigationController
    let aSearch = UISearchController(searchResultsController: navi.topViewController)
    return aSearch
    }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupSearchController()
  }
  
  func setupSearchController() {
    
    searchController.searchResultsUpdater = self
    (searchController.searchResultsController as! SearchTableViewController).searchDelegate = self
    searchController.searchBar.frame = CGRectMake(0, 0, view.bounds.width, 44)
//    navigationController?.navigationItem.titleView = searchController.searchBar
    view.addSubview(searchController.searchBar)
  }
}

// MARK: - DataSource & Delegate
extension CountriesViewController: UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, searchControllerResultsDelegate {
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return keys.count
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return allCountryLocale[keys[section]]!.count
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
    
    let countryLocale = allCountryLocale[keys[indexPath.section]]![indexPath.row]
    cell.textLabel?.text = countryLocale.displayName
    cell.detailTextLabel?.text = countryLocale.transiformLatin
    
    if let aselectedIndexPath = selectedIndexPath where aselectedIndexPath.compare(indexPath) == .OrderedSame {
      cell.accessoryType = .Checkmark
    } else {
      cell.accessoryType = .None
    }
    
    return cell
  }
  
  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    
    return keys[section]
  }
  
  func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
    
    return keys
  }
  
  func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
    if let cell = tableView.cellForRowAtIndexPath(indexPath) {
       cell.accessoryType = .None
    }
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if let cell = tableView.cellForRowAtIndexPath(indexPath) {
      cell.accessoryType = .Checkmark
    }
    let countryLocale = allCountryLocale[keys[indexPath.section]]![indexPath.row]
    selectedDelegate?.countriesViewController(self, didSelectedZoneCode: countryLocale.zoneCode, countryName: countryLocale.displayName)
  }

  // MARK: - SearchController
  func updateSearchResultsForSearchController(searchController: UISearchController) {
    filterSearchResultsForSearchController(searchController)
  }
  
  func searchController(controller: SearchTableViewController, DidSelectedItem item: CountryZone) {
    searchController.dismissViewControllerAnimated(true, completion: nil)
    searchController.searchBar.text = ""
    for (key, countries) in allCountryLocale {
      
      for (index, country) in enumerate(countries) {
        
        if country.zoneCode == item.zoneCode {
          selectedDelegate?.countriesViewController(self, didSelectedZoneCode: item.zoneCode,  countryName: item.displayName)
          let section = (keys as NSArray).indexOfObject(key)
          let row = index
          selectedIndexPath = NSIndexPath(forRow: row, inSection: section)
          tablewVIew.reloadData()
          tablewVIew.selectRowAtIndexPath(selectedIndexPath, animated: false, scrollPosition: .Top)
          break
        }
        
      }
    }
    
    println(item.displayName)
  }
  
}

// MARK: - Function Method
extension CountriesViewController {
  func filterSearchResultsForSearchController(searchController: UISearchController) {
    
    let text = searchController.searchBar.text
    
    var results = Dictionary<String, Array<CountryZone>>()
    for (key, countryZones) in allCountryLocale {
      
      let resultZones = countryZones.filter { countryZone -> Bool in
        
        let latin = countryZone.transiformLatin as NSString
        let name = countryZone.displayName as NSString
        
        let options: NSStringCompareOptions = NSStringCompareOptions.CaseInsensitiveSearch | NSStringCompareOptions.DiacriticInsensitiveSearch
        let rangeLatin = NSMakeRange(0, latin.length)
        let rangeName = NSMakeRange(0, name.length)
        
        debugPrint.p("latin = \(latin), name = \(name), rangeLatin =\(rangeLatin), rangeName = \(rangeName)")
        let findlatin = latin.rangeOfString(text, options: options, range: rangeLatin).length > 0
        let findName = name.rangeOfString(text, options: options, range: rangeName).length > 0
        
        return findlatin || findName
      }
      
      resultZones.count > 0 ? (results[key] = resultZones) : ()
    }
    
    let resultVC = searchController.searchResultsController as! SearchTableViewController
    resultVC.searchResult = results
    resultVC.update()
  }
}

