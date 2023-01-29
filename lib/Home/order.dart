import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'global.dart' as global_variables;

class Order extends StatefulWidget {
  const Order({Key? key}) : super(key: key);

  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order>
{

  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  final TextEditingController _location = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      resizeToAvoidBottomInset: false,

      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        margin: const EdgeInsets.all(25),

        child: Center(
          child: Form(
            key: _key,

            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text("Thank you for purchasing", style: GoogleFonts.comfortaa(
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

            Map <String, dynamic> location =
            {
              "Location" : _location.text.toString(),
            };

            FirebaseFirestore.instance.collection('Customers')
                .doc(user?.email!)
                .update(location);

            global_variables.listOfCart.clear();
            global_variables.listOfFavourites.clear();

            Navigator.pushReplacementNamed(context, '/home');

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
