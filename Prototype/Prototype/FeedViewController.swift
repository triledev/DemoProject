//
//  FeedViewController.swift
//  Prototype
//
//  Created by Tri Le on 9/20/22.
//

import UIKit

struct FeedItemViewModel {
    let description: String?
    let location: String?
    let imageName: String
}

final class FeedViewController: UITableViewController {
    private var feed = [FeedItemViewModel]()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        refresh()
        tableView.setContentOffset(CGPoint(x: 0, y: -tableView.contentInset.top), animated: false)
    }

    @IBAction func refresh() {
        refreshControl?.beginRefreshing()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if self.feed.isEmpty {
                self.feed = FeedItemViewModel.prototypeFeed
                self.tableView.reloadData()
            }
            self.refreshControl?.endRefreshing()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feed.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedItemCell", for: indexPath) as! FeedItemCell
        let model = feed[indexPath.row]
        cell.configure(with: model)
        return cell
    }
}

extension FeedItemCell {
    func configure(with model: FeedItemViewModel) {
        locationLabel.text = model.location
        locationContainer.isHidden = model.location == nil

        descriptionLabel.text = model.description
        descriptionLabel.isHidden = model.description == nil

        fadeIn(UIImage(named: model.imageName))
    }
}
