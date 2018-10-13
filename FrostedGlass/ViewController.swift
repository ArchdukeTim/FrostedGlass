//
//  ViewController.swift
//  FrostedGlass
//
//  Created by Tim Winters on 10/3/18.
//  Copyright © 2018 Tim Winters. All rights reserved.
//
import UIKit
import AVFoundation
import CoreFoundation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FrameExtractorDelegate{

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var attrTableView: UITableView!
    
    var attrs = [Attribute]();
    var frameExtractor: FrameExtractor!
    override func viewDidLoad() {
        super.viewDidLoad()
        frameExtractor = FrameExtractor()
        frameExtractor.delegate = self
        NetworkTablesWrapper.initialize()
        CSCoreWrapper.stream();
        loadAttrs()
        // Do any additional setup after loading the view, typically from a nib.
    }
    func captured(image: UIImage) {
        imageView.image = OpenCVWrapper.process(image)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation == .landscapeLeft {
            frameExtractor.captureSession.outputs[0].connection(with: .video)?.videoOrientation = .landscapeRight
        }
        else if UIDevice.current.orientation == .landscapeRight {
            frameExtractor.captureSession.outputs[0].connection(with: .video)?.videoOrientation = .landscapeLeft
        }
        else {frameExtractor.captureSession.outputs[0].connection(with: .video)?.videoOrientation = .portrait
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attrs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AttrSliderCell", for: indexPath) as! AttrCell
        
        // Fetches the appropriate meal for the data source layout.
        let attr = attrs[indexPath.row]
        
        cell.label.text = attr.label
        cell.slider.value = attr.value
        cell.slider.addTarget(attr, action: #selector(Attribute.onUpdate(sender:)), for: .touchUpInside)
        cell.slider.minimumValue = attr.min
        cell.slider.maximumValue = attr.max
        return cell
    }
    
    func loadAttrs(){
        
        let attr = Attribute.genAttr(label: "ISO", value: frameExtractor.cd.activeFormat.minISO, min: frameExtractor.cd.activeFormat.minISO, max: 1840, callback: {(newVal)  -> Void in
            do {
                let cd = (self.frameExtractor.captureSession.inputs.first as! AVCaptureDeviceInput).device
                try cd.lockForConfiguration();
                cd.setExposureModeCustom(duration: cd.exposureDuration, iso: min(cd.activeFormat.maxISO, newVal), completionHandler: nil);
                cd.unlockForConfiguration()
            } catch {} })
        attrs += [attr]
    }
    
    
}

