//
//  MorePageViewController.swift
//  tempertureBLE
//
//  Created by Jician.ho  on 2017/3/1.
//  Copyright © 2017年 JicianHo. All rights reserved.
//

import UIKit

class MorePageViewController: UIPageViewController,UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    lazy var VCArr:[UIViewController] = {
        return[self.VCInstance(name:"FirstVC"),
               self.VCInstance(name:"SecondVC"),
               self.VCInstance(name:"ThirdVC")]
    }()
//    lazy var VCArr:[UIViewController] = {
//        return [self.VCInstance(name:"FirstVC"),
//                self.VCInstance(name:"FirstVC"),
//                self.VCInstance(name:"FirstVC")]
//    }()
    
    private func VCInstance(name:String)->UIViewController{
        return UIStoryboard(name:"Main" , bundle:nil).instantiateViewController(withIdentifier: name)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        if let firstVC = VCArr.first{
            setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?{
        guard let viewControllerIndex = VCArr.index(of: viewController) else{
            return nil
        }
        let previousIndex = viewControllerIndex-1
        
        guard previousIndex >= 0 else{
            return VCArr.last
        }
        
        guard VCArr.count > previousIndex else {
            return nil
        }
        
        return VCArr[previousIndex]
    }
    

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?{
        guard let viewControllerIndex = VCArr.index(of: viewController) else{
            return nil
        }
        let nextIndex = viewControllerIndex+1
        
        guard nextIndex < VCArr.count else{
            return VCArr.first
        }
        
        guard VCArr.count > nextIndex else {
            return nil
        }
        
        return VCArr[nextIndex]
    }
    

    public func presentationCount(for pageViewController: UIPageViewController) -> Int{
        return VCArr.count
    }// The number of items reflected in the page indicator.
    
    public func presentationIndex(for pageViewController: UIPageViewController) -> Int{
        guard let firstViewController = viewControllers?.first,
            let firstViewControllerIndex = VCArr.index(of: firstViewController) else{
            return 0
        }
        return firstViewControllerIndex
    }// The selected item reflected in the page indicator.



}
