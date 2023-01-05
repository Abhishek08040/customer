import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velocity_x/velocity_x.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home>
{
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(250, 244, 240, 1),
      body: Container(
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.only(top: 30, left: 5, right: 5,),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text("Welcome", style: GoogleFonts.poppins(fontSize: 35, fontWeight: FontWeight.w400),),

            const Expanded(child: ShowProducts()),


          ],


        ),
      ),
    );
  }
}


class ShowProducts extends StatefulWidget {
  const ShowProducts({Key? key}) : super(key: key);

  @override
  State<ShowProducts> createState() => _ShowProductsState();
}

class _ShowProductsState extends State<ShowProducts>
{

  CollectionReference products = FirebaseFirestore
      .instance
      .collection('Products');


  @override
  Widget build(BuildContext context)
  {
    return FutureBuilder(
        future: products.get(),

        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot)
        {

          if (snapshot.connectionState == ConnectionState.waiting)
          {
            return const Center(child: CircularProgressIndicator());
          }


          else if (!snapshot.hasData || snapshot.data.docs.length < 1)
          {
            return Text("No products found!",
              style: GoogleFonts.andikaNewBasic(fontSize: 15, fontWeight: FontWeight.w400),);
          }


          else if (snapshot.hasData && snapshot.connectionState == ConnectionState.done)
          {
            String productPicture;
            String productName;
            String productPrice;
            String productRating;
            String productDescription;

            var productDetails;

            int itemCount = snapshot.data.docs.length;
            List<Product> productsList = <Product>[];

            for (int i = 0; i < itemCount; i++)
            {

              productDetails = snapshot.data.docs[i].data();

              productPicture = productDetails['Picture'].toString();
              productName = productDetails['Name'].toString();
              productPrice = productDetails['Price'].toString();
              productRating = productDetails['Ratings'].toString();
              productDescription = productDetails['Description'].toString();

              productsList.add(
                Product(productPicture, productName, productPrice, productRating, productDescription)
              );
            }

          return GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 2/2.8,
              children: List.generate(itemCount, (index)
              {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Center(
                        child: Stack(
                          children: [
                            
                            VxBox(
                              child: Image.network(
                                productsList[index].productPicture,
                              ),
                            ).rounded.white.square(140).p16.make(),

                            Positioned(
                              right: 0,
                              top: 0,
                              child: IconButton(
                                splashRadius: 1,
                                onPressed: ()
                                {

                                },
                                icon: Icon(Icons.favorite_border_rounded), color: Colors.pinkAccent,
                              ),
                            ),

                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: SizedBox(
                                height: 35,
                                width: 45,

                                child: Center(
                                  child: ElevatedButton(
                                    onPressed: () async
                                    {

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
                                    child: Icon(Icons.add_shopping_cart_outlined),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        child: Text(productsList[index].productName.substring(0, 8), style: GoogleFonts.andikaNewBasic(
                         fontSize: 18, fontWeight: FontWeight.w800
                        ),).px16(),
                      ),

                      Text(productsList[index].productDescription.substring(0, 15), style: GoogleFonts.andikaNewBasic(
                        fontSize: 12, fontWeight: FontWeight.w400, color: Colors.black54,
                        ),).px16(),

                      Row(
                        children: [
                          Text("Rs. "+productsList[index].productPrice, style: GoogleFonts.andikaNewBasic(
                            fontSize: 16, fontWeight: FontWeight.w600, color: Vx.blue900
                            ),).px16(),

                          Text(productsList[index].productRating+" ★ ", style: GoogleFonts.andikaNewBasic(
                            fontSize: 16, fontWeight: FontWeight.w600,
                            ),).px16(),
                        ],
                      ),

                      SizedBox(height: 5,),

                    ],
                  );

              }, ),
            );
          }


          return const CircularProgressIndicator();

        }
    );
  }
}

class Product
{
  final String productPicture;
  final String productName;
  final String productPrice;
  final String productRating;
  final String productDescription;

  Product(this.productPicture, this.productName, this.productPrice, this.productRating, this.productDescription);
}
