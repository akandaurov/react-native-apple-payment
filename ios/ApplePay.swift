import PassKit

@objc(ApplePay)
class ApplePay: UIViewController {
    private var rootViewController: UIViewController = UIApplication.shared.keyWindow!.rootViewController!
    private var request: PKPaymentRequest = PKPaymentRequest()
    private var resolve: RCTPromiseResolveBlock?
    private var paymentNetworks: [PKPaymentNetwork]?


    @objc(invokeApplePay:details:)
    private func invokeApplePay(method: NSDictionary, details: NSDictionary) -> Void {
        self.paymentNetworks = method["supportedNetworks"] as? [PKPaymentNetwork]
        guard PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: paymentNetworks!) else {
            print("Can not make payment")
            return
        }

        let items = details["items"] != nil ? details["items"] as! NSArray : []
        let total = details["total"] as! NSDictionary

        request.paymentSummaryItems = [];

        for item in items {
          let itemObject = item as! NSDictionary
          request.paymentSummaryItems.append(PKPaymentSummaryItem.init(label: itemObject["label"] as! String, amount: NSDecimalNumber(value: itemObject["amount"] as! Double)))
        }

        request.paymentSummaryItems.append(PKPaymentSummaryItem.init(label: total["label"] as! String, amount: NSDecimalNumber(value: total["amount"] as! Double)))

        request.currencyCode = method["currencyCode"] as! String
        request.countryCode = method["countryCode"] as! String
        request.merchantIdentifier = method["merchantIdentifier"] as! String
        request.merchantCapabilities = PKMerchantCapability.capability3DS
        request.supportedNetworks = self.paymentNetworks!
    }

    @objc(initApplePay:withRejecter:)
    func initApplePay(resolve: @escaping RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
        guard PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: paymentNetworks!) else {
            print("Can not make payment")
            return
        }
        self.resolve = resolve
        if let controller = PKPaymentAuthorizationViewController(paymentRequest: request) {
            controller.delegate = self
            DispatchQueue.main.async {
                self.rootViewController.present(controller, animated: true, completion: nil)
            }
        }
    }

    @objc(canMakePayments:withRejecter:)
    func canMakePayments(resolve: RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
        if PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: paymentNetworks!) {
            resolve(true)
        } else {
            resolve(false)
        }
    }
}

extension ApplePay: PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
    }

    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        let paymentData = String(decoding: payment.token.paymentData, as: UTF8.self)
        let paymentMethod: NSDictionary = [
            "displayName": payment.token.paymentMethod.displayName,
            "network": payment.token.paymentMethod.network,
            "type": methodTypeToString(type: payment.token.paymentMethod.type)
        ]

        let result: NSDictionary = [
            "paymentData": paymentData,
            "paymentMethod": paymentMethod
        ]

        self.resolve!(result)
        completion(.success)
    }

    private func methodTypeToString(type: PKPaymentMethodType) -> String {
        switch (type) {
            case .credit:
                return "credit"
            case .debit:
                return "debit"
            case .eMoney:
                return "eMoney"
            case .prepaid:
                return "prepaid"
            case .store:
                return "store"
            default:
                return "unknown"
        }
    }
}
