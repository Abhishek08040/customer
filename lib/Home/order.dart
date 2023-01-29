import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import 'global.dart' as global_variables;

class OrderProducts extends StatefulWidget {
  const OrderProducts({Key? key}) : super(key: key);

  @override
  State<OrderProducts> createState() => _OrderProductsState();
}

class _OrderProductsState extends State<OrderProducts>
{

  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  final TextEditingController _location = TextEditingController();
  final TextEditingController _deliveryTime = TextEditingController();

  List<String> deliveryTime = ['7 AM to 12 PM', '12 PM to 4 PM', '4 PM to 8 PM', '8 PM to 12 AM'];

  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      resizeToAvoidBottomInset: false,

      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        margin: const EdgeInsets.all(25),

        child: Center(
          child: Form(
            key: _key,

            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                const SizedBox(height: 20,),

                Text("Thank you for ordering", style: GoogleFonts.comfortaa(
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: 30,
                ),),

                const SizedBox(height: 20,),

                Text("Enter your Location:", style: GoogleFonts.andikaNewBasic(),),

                const SizedBox(height: 5,),

                TextFormField(
                  keyboardType: TextInputType.multiline,
                  maxLines: 3,
                  minLines: 3,

                  controller: _location,

                  validator: (value)
                  {
                    if (value!.isEmpty)
                    {
                      return "Please enter your location";
                    }
                    return null;
                  },

                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),


                ),

                const SizedBox(height: 20,),

                Text("Choose a delivery time:", style: GoogleFonts.andikaNewBasic(),),

                const SizedBox(height: 5,),

                DropdownButtonFormField2(
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),

                  isExpanded: true,

                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.black45,
                  ),

                  iconSize: 30,

                  buttonHeight: 60,

                  buttonPadding: const EdgeInsets.only(left: 5, right: 5),

                  dropdownDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                  ),

                  items: deliveryTime
                      .map((item) =>
                      DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ))
                      .toList(),

                  validator: (value)
                  {
                    if (value == null)
                    {
                      return 'Empty selection';
                    }
                    return null;
                  },

                  onChanged: (value)
                  {
                    setState(() {
                      _deliveryTime.text = value.toString();
                    });

                  },

                  onSaved: (value)
                  {
                    setState(() {
                      _deliveryTime.text = value.toString();
                    });

                  },

                ),

                const SizedBox(height: 20,),

              ],
            ),
          ),
        ),
      ).py32(),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async
        {
          if (_key.currentState!.validate())
          {

            Map <String, dynamic> data =
            {
              "Location" : _location.text.toString(),
            };

            FirebaseFirestore.instance.collection('Customers')
                .doc(user?.email!)
                .update(data);

            List<String> productsInCart = [];
            for (var element in global_variables.listOfCart)
            {
              for (int i = 0; i < element.productQuantity; i++)
                {
                  productsInCart.add(element.productID);
                }
            }

            final now = DateTime.now();
            String invoiceDate =
                (now.year).toString().padLeft(2, '0')
                    + (now.month).toString().padLeft(2, '0')
                    + (now.day).toString().padLeft(2, '0')
                    + (now.hour).toString().padLeft(2, '0')
                    + (now.minute).toString().padLeft(2, '0');

                FirebaseFirestore
                    .instance
                    .collection('Stores')
                    .doc('Transaction data')
                    .get()
                    .then((value1)
                {
                  Map item1 = value1.data()!;
                  FirebaseFirestore
                      .instance
                      .collection('Customers')
                      .doc(user?.email!)
                      .get()
                      .then((value2)
                      {
                        Map item2 = value2.data()!;

                        num invoiceNo = item1['last invoice no'] + 1;
                        Map <String, dynamic> newTransaction =
                        {
                          'CustomerID' : item2['CustomerID'],
                          'InvoiceDate' : invoiceDate,
                          'InvoiceNo' : invoiceNo,
                          'OrderedDelivered' : false,
                          'StockCode' : productsInCart,
                          "Delivery Time" : _deliveryTime.text.toString(),
                        };

                        FirebaseFirestore.instance.collection('Transactions')
                            .doc(invoiceNo.toString())
                            .set(newTransaction);
                        FirebaseFirestore.instance.collection('Stores')
                            .doc('Transaction data')
                            .update({'last invoice no' : invoiceNo});

                        global_variables.listOfCart.clear();

                        FirebaseFirestore.instance.collection('Customers')
                            .doc(user?.email!)
                            .update({'Cart': []});

                        FirebaseFirestore.instance.collection('Customers')
                            .doc(user?.email!)
                            .update({'Favourites': []});

                      });
                });
            Navigator.pushNamed(context, '/home');
          }
        },

        icon: const Icon(Icons.shopping_cart),
        backgroundColor: Colors.pink,
        hoverColor: Vx.pink600,
        elevation: 10.0,
        label: Text("Order", style: GoogleFonts.openSans(),),
      ),

    );
  }



}
