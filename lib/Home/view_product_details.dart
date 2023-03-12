
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'home_page.dart';

import 'global.dart' as global_variables;

class ProductDetails extends StatefulWidget {
  final String productID;

  const ProductDetails({Key? key, required this.productID}) : super(key: key);

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails>
{

  @override
  Widget build(BuildContext context)
  {

    final String productID = widget.productID.toString();

    CollectionReference products = FirebaseFirestore
        .instance
        .collection('Products');

    return Material(
      child: FutureBuilder(
        future: products.doc(productID).get(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot)
        {
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done)
          {
            Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
            final String productPicture = data['Picture'].toString();
            final String productName = data['Name'].toString();
            final num productPrice = data['UnitPrice'];
            final num productRating = data['Ratings'] ?? 3;
            final String productDescription = data['Description'].toString();


            return Scaffold(
              backgroundColor: Colors.white,

              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.white,
                leading: const BackButton(
                  color: Colors.black,
                ),
              ),

              body: SingleChildScrollView(

                child: Column(

                  children: [

                    Image.network(productPicture,).h40(context),

                    Container(
                      padding: const EdgeInsets.all(15),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,

                        children: [

                          Row(
                            children: [
                              Row(
                                children: [
                                  for (int i = 0; i < productRating; i++)
                                    Text(' ★ ', style: GoogleFonts.andikaNewBasic(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: const Color.fromRGBO(255,215,0, 1),
                                    ), ),
                                ],
                              ),

                              const SizedBox(width: 10,),

                              ElevatedButton(

                                onPressed: () {

                                },

                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                    Colors.white,
                                  ),
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      )
                                  ),),

                                child: Text('214 Reviews', style: GoogleFonts.andikaNewBasic(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: Colors.pink,
                                ),),
                              )
                            ],
                          ).py4(),

                          Text(productName, style: GoogleFonts.raleway(
                            fontSize: 26,
                            color: const Color.fromRGBO(58, 1, 92, 1.0),
                            fontWeight: FontWeight.w700,
                          ),),

                          const SizedBox(height: 12,),

                          Text(productDescription, style: GoogleFonts.andikaNewBasic(
                            fontSize: 12,
                            color: const Color.fromRGBO(3, 16, 63, 1.0),
                          ),),

                          PriceFavouritesAndCartRow(
                            productID: productID,
                            productPicture: productPicture,
                            productName: productName,
                            productPrice: productPrice,
                            productRating: productRating,
                          ),

                          const SizedBox(height: 20,),

                          AddComments(productID: productID),

                          const SizedBox(height: 20,),

                          DisplayComments(productID: productID),

                        ],

                      ).px24(),

                    ),
                  ],
                ),
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());

        }
      ),

    );
  }
}

class PriceFavouritesAndCartRow extends StatefulWidget {
  final String productID;
  final String productPicture;
  final String productName;
  final num productPrice;
  final num productRating;

  const PriceFavouritesAndCartRow({Key? key,
    required this.productID,
    required this.productPicture,
    required this.productName,
    required this.productPrice,
    required this.productRating,

  }) : super(key: key);

  @override
  State<PriceFavouritesAndCartRow> createState() => _PriceFavouritesAndCartRowState();
}

class _PriceFavouritesAndCartRowState extends State<PriceFavouritesAndCartRow>
{

  @override
  Widget build(BuildContext context)
  {
    bool isProductAddedToFavourites = global_variables.listOfFavourites.where(
             (element) => element.productID == widget.productID).isNotEmpty;

    bool isProductAddedToCart = global_variables.listOfCart.where(
              (element) => element.productID == widget.productID).isNotEmpty;


    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        !isProductAddedToCart?

            const SizedBox(height: 24,) :
            const SizedBox(height: 0,),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [

            Text("₹ ${widget.productPrice}", style: GoogleFonts.lato(
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),),

            const SizedBox(width: 15,),

            InkWell(
              child: isProductAddedToFavourites ?
              const Icon(Icons.favorite, color: Colors.pink,):
              const Icon(Icons.favorite_outline),

              onTap: ()
              {
                if (isProductAddedToFavourites)
                {
                  global_variables.listOfFavourites.removeWhere((element) => element.productID == widget.productID);
                }
                else
                {
                  global_variables.listOfFavourites.add(FavouriteProducts(
                      widget.productID,
                      widget.productPicture,
                      widget.productName,
                  )
                  );
                }

                setState(() {

                });
              },
            ),

            !isProductAddedToCart ?

            FloatingActionButton(
              onPressed: ()
              {
                setState(() {
                  global_variables.listOfCart.add(CartProducts(
                      widget.productID,
                      widget.productPicture,
                      widget.productName,
                      widget.productPrice,
                      1,
                  ));
                });
              },
              child: const Icon(Icons.add,),
            ):

            Column(
              children: [
                InkWell(
                  onTap: () {
                    setState(()
                    {
                      global_variables.listOfCart[
                        global_variables.listOfCart.indexWhere(
                              (element) => element.productID == widget.productID
                        )
                      ].productQuantity--;

                      if (global_variables.listOfCart[
                        global_variables.listOfCart.indexWhere(
                                (element) => element.productID == widget.productID
                        )
                      ].productQuantity == 0)
                        {
                          global_variables.listOfCart.removeWhere((
                              (element) => element.productID == widget.productID
                          ));
                        }
                    });
                  },
                  child: const Icon(Icons.exposure_minus_1_outlined),
                ),

                FloatingActionButton(
                  onPressed: () {  },
                  child: Text(global_variables.listOfCart.singleWhere((element) =>
                      element.productID == widget.productID,
                  ).productQuantity.toString(),

                    style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),),
                ),

                InkWell(
                  onTap: () {
                    setState(() {
                      global_variables.listOfCart[
                      global_variables.listOfCart.indexWhere(
                              (element) => element.productID == widget.productID
                      )
                      ].productQuantity++;
                    });
                  },
                  child: const Icon(Icons.plus_one_outlined),
                ),

              ],
            ),


          ],
        ),

        isProductAddedToCart ?
        Text("Total ₹ ${widget.productPrice * global_variables.listOfCart[
          global_variables.listOfCart.indexWhere(
          (element) => element.productID == widget.productID
        )].productQuantity}", style: GoogleFonts.lato(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),) :
            const Text(''),

      ],
    );

  }
}


class AddComments extends StatefulWidget {
  final String productID;

  const AddComments({Key? key, required this.productID}) : super(key: key);

  @override
  State<AddComments> createState() => _AddCommentsState();
}

class _AddCommentsState extends State<AddComments>
{

  User? user = FirebaseAuth.instance.currentUser;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _ratings = TextEditingController(text: '1');
  final TextEditingController _comment = TextEditingController();

  CollectionReference commentsCollection = FirebaseFirestore
      .instance
      .collection('Comments');

  @override
  Widget build(BuildContext context)
  {
    return Form(
      key: _formKey,

      child: Column(
        children: [

          RatingBar(
            filledIcon: Icons.star,
            emptyIcon: Icons.star_border,
            onRatingChanged: (value) => {_ratings.text = value.toInt().toString()},
            initialRating: 1,
            maxRating: 5,
            size: 25,
          ),

          const SizedBox(height: 12,),

          TextFormField(

            controller: _comment,

            validator: (value)
            {
              if (value!.isEmpty)
              {
                return "Please enter your comment";
              }
              return null;
            },

            decoration: const InputDecoration(
              labelText: 'Enter your comment',
              enabledBorder: UnderlineInputBorder(),
            ),


          ),

          const SizedBox(height: 10,),

          Align(
            alignment: Alignment.bottomLeft,
            child: ElevatedButton(
              onPressed: () async
              {
                if (_formKey.currentState!.validate())
                {
                  commentsCollection.add({
                    'Customer' : user!.email.toString(),
                    'Rating' : _ratings.text,
                    'Comment' : _comment.text,
                    'ProductID' : widget.productID,
                  });

                  setState(() {
                    _comment.clear();
                  });

                  MotionToast message = MotionToast.success(
                    title:  const Text("Comment posted successfully!"),
                    description:  const Text(""),
                  );

                  WidgetsBinding.instance.addPostFrameCallback((timeStamp)
                  {
                    message.show(context);
                  });

                }
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  Vx.blue900,
                ),
                shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    )
                ),
              ),
              child: Text("Submit", style: GoogleFonts.openSans(),),
            ),
          ),
        ],
      ),

    );
  }
}


class DisplayComments extends StatefulWidget {
  final String productID;

  const DisplayComments({Key? key, required this.productID}) : super(key: key);

  @override
  State<DisplayComments> createState() => _DisplayCommentsState();
}

class _DisplayCommentsState extends State<DisplayComments>
{
  @override
  Widget build(BuildContext context)
  {
    Query commentsCollection = FirebaseFirestore
        .instance
        .collection('Comments')
        .where('ProductID', isEqualTo: widget.productID.toString());

    return FutureBuilder(
      future: commentsCollection.get(),

      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot)
      {
        if (snapshot.connectionState == ConnectionState.waiting)
        {
          return const Center(child: CircularProgressIndicator());
        }

        else if (!snapshot.hasData || snapshot.data.docs.length < 1)
        {
          return Text('No comments found!', style: GoogleFonts.andikaNewBasic());
        }

        else if (snapshot.hasData && snapshot.connectionState == ConnectionState.done)
        {
          return ListView.builder(
            itemCount: snapshot.data.docs.length,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index)
            {
              var comment = snapshot.data.docs[index].data();

              return ListTile(

                title: Row(
                  children: [
                    for (int i = 0; i < int.parse(comment['Rating']); i++)
                      Text('★ ', style: GoogleFonts.andikaNewBasic(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color.fromRGBO(255,215,0, 1),
                      ), ),
                  ],
                ),

                subtitle: Text(comment['Comment']).px4(),

              );
            },
          );

        }

        return const Center(child: CircularProgressIndicator());

      }


    );
  }

}

class Comment
{
  final String displayPhoto;
  final String customerName;
  final String comment;
  final int rating;

  Comment(this.displayPhoto, this.customerName, this.comment, this.rating);
}