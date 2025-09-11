import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentPage extends StatefulWidget{
  final int amount;
  const PaymentPage({super.key,required this.amount});
  @override
  State<PaymentPage> createState()=>_PaymentPageState();
}
class _PaymentPageState extends State<PaymentPage>{
  late Razorpay _razorPay;
  @override
  void initState() {
    super.initState();
    _razorPay=Razorpay();
    _razorPay.on(Razorpay.EVENT_PAYMENT_SUCCESS,_handlePaymentSuccess);
    _razorPay.on(Razorpay.EVENT_PAYMENT_ERROR,_handlePaymentError);
    _razorPay.on(Razorpay.EVENT_EXTERNAL_WALLET,_handleExternalWallet);

  }

  void _openCheckout(){
    var options={
      'key':'rzp_test_R9e67H5dIpbeBV',
      'amount':widget.amount*100,
      'name':'TechVerse',
      'description':'Test Payment',
      'prefil':{'contact':'9999999999','email':'test@gmail.com'},
      'method':{
        'card':true,
      },
      'theme':{'color':'#F37254'}
    };
    try{
      _razorPay.open(options);
    }
    catch(e){
      debugPrint(e.toString());
    }
  }
  void _handlePaymentSuccess(PaymentSuccessResponse response){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Success:${response.paymentId}")),
    );
    Navigator.pop(context,true);
  }
  void _handlePaymentError(PaymentFailureResponse response){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failure:${response.code}-${response.message}")),
    );
    Navigator.pop(context,false);
  }
  void _handleExternalWallet(ExternalWalletResponse response){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content:Text("External Wallet:${response.walletName}")),
    );
  }
  @override
  void dispose(){
    _razorPay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text("Payment")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.black87.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(Icons.payment, size: 64, color: Colors.black87),
                  SizedBox(height: 16),
                  Text("Premium Upgrade", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                  SizedBox(height: 8),
                  Text("Unlock premium content and features", style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                ],
              ),
            ),
            SizedBox(height: 32),
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text("Amount to Pay", style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                  SizedBox(height: 8),
                  Text("₹${widget.amount}", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _openCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text("Pay ₹${widget.amount}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}