//
//  FoodCartViewController.swift
//  FoodDelivery
//
//  Created by Abbas on 11/26/20.
//
//

import UIKit
import RxSwift
import RxCocoa

class FoodCartViewController: UIViewController {
    @IBOutlet weak private var backButton: UIButton!
    @IBOutlet weak private var foodCartBackButtonYConstraint: NSLayoutConstraint!
    
    @IBOutlet weak private var foodManagerItemsView: UICollectionView!
    
    @IBOutlet weak private var foodCartItemsView: UITableView!
    @IBOutlet weak private var foodCartTotalLbl: UILabel!
    
    @IBOutlet weak private var foodCartPaymentButton: BadgeButton!
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var statusBarHeight: CGFloat = 0
        if #available(iOS 13.0, *) {
            let window1 = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            statusBarHeight = window1?.windowScene?.statusBarManager?.statusBarFrame.height ?? 30
        } else {
            statusBarHeight = UIApplication.shared.statusBarFrame.height
        }
        
        foodCartBackButtonYConstraint.constant = statusBarHeight
        
        initFoodManagerItemsView()
        initFoodCartItemsView()
        
        foodCartPaymentButton.badge = ""
        
        foodCartPresenter?.startRetrievingFoodCartItems()
    }

    // MARK: - Properties
    var foodCartPresenter: ViewToPresenterFoodCartProtocol?
    
    private let disposeBag = DisposeBag()
}

extension FoodCartViewController: PresenterToViewFoodCartProtocol{
    func onRetrieveFoodCartItemsResponse(foodCartTotal: Float, isFoodCartEmpty: Bool) {
        foodCartTotalLbl.text = "\(foodCartTotal) usd"
        
        foodCartPaymentButton.isHidden = isFoodCartEmpty
    }
}

extension FoodCartViewController {
    @IBAction func onBackAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    func initFoodManagerItemsView() {
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.width / 3 - 20, height: 35)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        foodManagerItemsView.collectionViewLayout = flowLayout
        if let foodManagerItems = self.foodCartPresenter?.viewModel.foodManagerItems {
            foodManagerItems
                .bind(to: foodManagerItemsView
                    .rx
                    .items(cellIdentifier: FoodManagerItemCell.Identifier,
                           cellType: FoodManagerItemCell.self)) {
                            item, managerItem, cell in
                            cell.setValue(managerItem)
                            cell.updateAsSelectedUI()
                }
                .disposed(by: disposeBag)
        }
        
        foodManagerItemsView
            .rx
            .itemSelected
            .subscribe(onNext:{ [unowned self] indexPath in
                let cell = self.foodManagerItemsView.cellForItem(at: indexPath) as? FoodManagerItemCell
                cell?.updateAsSelectedUI()
                self.foodManagerItemsView.scrollToItem(at: IndexPath(item: indexPath.item, section: 0), at: .centeredHorizontally, animated: true)
            })
            .disposed(by: disposeBag)
        
        foodManagerItemsView
            .rx
            .itemDeselected
            .subscribe(onNext:{ [unowned self] indexpath in
                let cell = self.foodManagerItemsView.cellForItem(at: indexpath) as? FoodManagerItemCell
                cell?.updateAsSelectedUI()
            })
            .disposed(by: disposeBag)
        
        foodManagerItemsView.selectItem(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .centeredHorizontally)
    }
    
    func initFoodCartItemsView() {
        foodCartItemsView.separatorColor = .clear
        
        if let viewModel = self.foodCartPresenter?.viewModel {
        
            foodCartTotalLbl.text = "\(viewModel.foodCartTotal) usd"
            
            viewModel.foodCartItemsRelay
                .bind(to: foodCartItemsView
                    .rx
                    .items(cellIdentifier: FoodCartItemsCell.Identifier,
                           cellType: FoodCartItemsCell.self)) {
                            row, foodItemSummary, cell in
                            cell.setValues(foodItemSummary)
                }
                .disposed(by: disposeBag)
        }
    }
}


