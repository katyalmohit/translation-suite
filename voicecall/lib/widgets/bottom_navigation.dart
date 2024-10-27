// import 'package:flutter/material.dart';

// class BottomNavigationWidget extends StatelessWidget {
//   final int currentIndex;
//   final ValueChanged<int> onTap; // Use ValueChanged for clarity

//   const BottomNavigationWidget({
//     Key? key,
//     required this.currentIndex,
//     required this.onTap,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       items: const [
//         BottomNavigationBarItem(
//           icon: Icon(Icons.dialpad),
//           label: 'Keypad',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.history),
//           label: 'Recents',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.contacts),
//           label: 'Contacts',
//         ),
        
//       ],
//       currentIndex: currentIndex,
//       selectedItemColor: Colors.blue,
//       unselectedItemColor: Colors.grey,
//       backgroundColor: Colors.white,
//       type: BottomNavigationBarType.fixed,
//       showSelectedLabels: true,
//       showUnselectedLabels: true,
//       elevation: 8.0,
//       onTap: onTap, // Directly call the onTap function from the parent
//     );
//   }
// }
