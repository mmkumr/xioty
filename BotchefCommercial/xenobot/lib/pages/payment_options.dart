import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:xenobot/db/users.dart';

import '../commons.dart';
import '../partials/menu.dart';
import '../providers/user_provider.dart';

class PaymentOptionsPage extends StatefulWidget {
  const PaymentOptionsPage({super.key});

  @override
  State<PaymentOptionsPage> createState() => _PaymentOptionsPageState();
}

class _PaymentOptionsPageState extends State<PaymentOptionsPage> {
  GlobalKey<FormState> form = GlobalKey<FormState>();
  TextEditingController amount = TextEditingController(text: "500");
  Razorpay razorpay = Razorpay();
  @override
  void initState() {
    super.initState();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentError);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = Provider.of<UserProvider>(context);
    _selectedValue = user.userModel.paymentMethod.index + 1;
    setState(() {});
  }

  int _selectedValue = 1;
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment Options"),
        centerTitle: true,
        backgroundColor: bgC,
        elevation: 0,
      ),
      drawer: menu(context),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RadioListTile(
                title: const Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        FontAwesomeIcons.wallet,
                        size: 50,
                      ),
                    ),
                    Text('Xenobot Wallet'),
                  ],
                ),
                subtitle: Row(
                  children: [
                    Text(
                        'Balance: Rs.${user.userModel.wallet.toStringAsFixed(2)}'),
                    TextButton(
                      onPressed: () {
                        addAmmountWallet();
                      },
                      child: const Text("+ Add Money"),
                    )
                  ],
                ),
                value: 1,
                groupValue: _selectedValue,
                onChanged: (value) {
                  setState(() {
                    _selectedValue = value!;
                  });
                },
              ),
              RadioListTile(
                title: const Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        FontAwesomeIcons.solidCreditCard,
                        size: 50,
                      ),
                    ),
                    Text('Other Payment Methods'),
                  ],
                ),
                subtitle: const Text(
                  'UPI, credit/debit cards, online banking, etc.',
                  softWrap: true,
                ),
                value: 2,
                groupValue: _selectedValue,
                onChanged: (value) {
                  setState(() {
                    _selectedValue = value!;
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: MaterialButton(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  color: elementsC,
                  onPressed: () async {
                    UserServices().updatePaymentMethod(
                        id: user.userModel.id,
                        paymentMethod: PaymentMethod.values[_selectedValue - 1],
                        context: context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 15.0, right: 15.0, top: 10, bottom: 10),
                    child: Text(
                      "Save Preference",
                      style: TextStyle(
                        fontSize: 20,
                        color: elementsC.computeLuminance() > 0.5
                            ? Colors.black
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  addAmmountWallet() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Amount to be added"),
        content: Form(
          key: form,
          child: TextFormField(
            controller: amount,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              labelText: "Amount",
              hintText: "Amount",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            validator: (value) {
              if (value!.isEmpty) {
                return "Invalid input";
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
              onPressed: () {
                var user = Provider.of<UserProvider>(context, listen: false);
                if (form.currentState!.validate()) {
                  Navigator.of(context).pop();
                  var options = {
                    'key': 'rzp_test_2Eh5LSk1v3ujdn',
                    'amount': "${amount.text}00",
                    'name': user.userModel.name,
                    'description': "Wallet recharge",
                    'prefill': {
                      'email': user.userModel.email,
                    }
                  };
                  razorpay.open(options);
                }
              },
              child: const Text("Add")),
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"))
        ],
      ),
    );
  }

  void handlePaymentSuccess(PaymentSuccessResponse response) {
    var user = Provider.of<UserProvider>(context, listen: false);
    UserServices().updateWallet(
        id: user.userModel.id,
        context: context,
        price: -int.parse(amount.text).toDouble());
    Fluttertoast.showToast(
        msg: "Paymtment Successful", backgroundColor: Colors.green);
  }

  void handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
        msg: "Paymtment Failed", backgroundColor: Colors.red);
  }
}
