//
//  TopicsViewController.swift
//  HishowZone
//
//  Created by Chu Guimin on 16/9/6.
//  Copyright © 2016年 Chu Guimin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MJRefresh
import SwiftyJSON

class TopicsViewController: UIViewController, SegueHandlerType {

    private let disposeBag = DisposeBag()
    private let viewModel  = TopicsViewModel()
    
    enum SegueIdentifier: String {
        case ToProfileSegue
        case ToTopicDetailSegue
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 定义子界面返回键的文字文本
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)

        initMJRefresh()
        
        tableView.register(TopicItemCell.self)
        
        tableView.rx
            .setDelegate(self)
            .addDisposableTo(disposeBag)
    
        viewModel.dataSource
            .asObservable()
            .bindTo(tableView.rx.items(cellIdentifier: TopicItemCell.reuseIdentifier, cellType: TopicItemCell.self)) { index, element, cell in
                cell.configure(element)
                
                cell.gestureRecognizer.rx.event.subscribe(onNext: { (_) in
                    //                let topic = this.topics[path.row]
                    let author = element.author
                    self.performSegueWithIdentifier(SegueIdentifier.ToProfileSegue, sender: author)
                }).addDisposableTo(cell.disposeBag)
            }
            .addDisposableTo(disposeBag)
        
        tableView.rx
            .modelSelected(Topic.self)
            .subscribe(onNext: { [weak self] topic in
                if let selectedRowIndexPath = self?.tableView.indexPathForSelectedRow {
                    self?.tableView.deselectRow(at: selectedRowIndexPath, animated: true)
                }
                self?.performSegueWithIdentifier(SegueIdentifier.ToTopicDetailSegue, sender: topic)
            })
            .addDisposableTo(disposeBag)
        
        viewModel.refreshStatus
            .asObservable()
            .bindNext { [weak self] refreshStatus in
                switch refreshStatus {
                case .dropDownSuccess:
                    self?.tableView.mj_header.endRefreshing()
                case .pullSucessHasMoreData:
                    self?.tableView.mj_footer.endRefreshing()
                case .networkerError:
                    self?.tableView.mj_header.endRefreshing()
                    self?.tableView.mj_footer.endRefreshing()
                    print("??")
                default:
                    break
                }
            }
            .addDisposableTo(disposeBag)
    }
    
    func initMJRefresh() {
        let mjHeader = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(pullToRefresh))
        mjHeader?.lastUpdatedTimeLabel!.isHidden = true
        tableView.mj_header = mjHeader
        tableView.mj_header.beginRefreshing()
        
        tableView.mj_footer = MJRefreshBackNormalFooter(refreshingTarget: self, refreshingAction: #selector(pullToLoadMore))
    }
    
    func pullToRefresh() {
        viewModel.getTopics(isPullToRefresh: true)
    }
    
    func pullToLoadMore() {
        viewModel.getTopics(isPullToRefresh: false)
    }
}

// MARK: - Navigation

extension TopicsViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segueIdentifierForSegue(segue) {
        case .ToProfileSegue:
            
            let controller = segue.destination as! ProfileViewController
//            controller.uid = sender as? String
            controller.author = sender as! Author
        case .ToTopicDetailSegue:
            
            let controller = segue.destination as! TopicDetailViewController
            controller.topic = sender as? Topic
        }
    }
}

// MARK: - UITableViewDelegate

extension TopicsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 359
    }
}
