import 'package:flutter/material.dart';

class RoleDecider extends StatefulWidget{
  @override
  State<RoleDecider> createState() => _RoleDeciderState();
}

class _RoleDeciderState extends State<RoleDecider> {
  @override
  Widget build(BuildContext context) {
   return Scaffold(
      
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(255, 5, 61, 107),
                  Color.fromARGB(255, 255, 206, 59),
                ],
              
                
              ),
            ),

          ),

          Center(

            child:Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(onPressed:(){
                   Navigator.pushNamed(context, '/userLogin');
                }
                ,style:ElevatedButton.styleFrom(
                  backgroundColor:  const Color.fromARGB(255, 5, 61, 107),
                )
               , child: const Text('User',style: TextStyle(  color:Color.fromARGB(255, 255, 206, 59)),),)
           , Padding(padding: EdgeInsets.all(10),
           
           child: 
                ElevatedButton(onPressed:(){
                  Navigator.pushNamed(context, '/mLogin');
                }
                ,style:ElevatedButton.styleFrom(
                  backgroundColor:  const Color.fromARGB(255, 5, 61, 107),
                )
               , child: const Text('Manager',style: TextStyle(  color:Color.fromARGB(255, 255, 206, 59)),),),
           
           )  ],
              
            ),
               

          )
        ],
      )
   
   
   
   );
  }
}