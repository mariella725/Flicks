//
//  MoviesViewController.swift
//  Movie Reviews
//
//  Created by Mariella Sypa on 1/18/16.
//  Copyright © 2016 Mariella Sypa. All rights reserved.
//

import UIKit
import AFNetworking

class MoviesViewController: UIViewController, UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var TableView: UITableView!
    
    var movies: [NSDictionary]?
    var refreshControl: UIRefreshControl!
    var endpoint: String! = "now_playing"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        TableView.dataSource = self;
        TableView.delegate = self;
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "didRefresh", forControlEvents: .ValueChanged)
        TableView.insertSubview(refreshControl, atIndex: 0)
        
        
        networkRequest()
        
    }
      

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let movies = movies {
            return movies.count;
        }
        else {
            return 0;
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        
        let baseUrl = "https://image.tmdb.org/t/p/w342"
        if let posterPath = movie["poster_path"] as? String {
        let imageUrl = NSURL(string: baseUrl + posterPath)
        cell.posterView.setImageWithURL(imageUrl!)
            
        }
        
        return cell
    }
    
    func networkRequest() {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                
                
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            //NSLog("response: \(responseDictionary)")
                            
                            self.movies = responseDictionary["results"] as? [NSDictionary]

                            self.TableView.reloadData()
                            self.refreshControl.endRefreshing()
                    }
                }
                else {
                    print("There was a network error")
                    
                }
        });
        task.resume()
        
    }
    
    func didRefresh() {
        
        networkRequest()
}



    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let cell = sender as! UITableViewCell
        let indexPath = TableView.indexPathForCell(cell)
        let movie = movies![indexPath!.row]
        
        let detailViewController = segue
        .destinationViewController as! DetailViewController
        
        detailViewController.movie = movie
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    


}
