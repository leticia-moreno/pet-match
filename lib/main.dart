import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';

import 'app_navigator.dart';
import './screens/home_screen.dart';
import './screens/listing_screen.dart';
import './screens/management_screen.dart';
import './screens/profile_screen.dart';
import './screens/login_screen.dart';
import './screens/register_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adoption App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => const MainScreen(initialTab: AppTab.home),
      },
      home: BlocProvider(
        create: (context) => AppNavigatorCubit(),
        child: AuthenticationWrapper(),
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;

          if (user == null) {
            return LoginScreen();
          } else {
            return const MainScreen(initialTab: AppTab.home);
          }
        }

        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  final AppTab initialTab;

  const MainScreen({required this.initialTab, Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialTab.index);
    _currentIndex = widget.initialTab.index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          HomeScreen(),
          ListingScreen(),
          ManagementScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavyBar(
        selectedIndex: _currentIndex,
        onItemSelected: (index) {
          _pageController.jumpToPage(index);
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavyBarItem(
            icon: const Icon(Icons.home),
            title: const Text("Home"),
          ),
          BottomNavyBarItem(
            icon: const Icon(Icons.dashboard),
            title: const Text("Pets"),
          ),
          BottomNavyBarItem(
            icon: const Icon(Icons.notifications),
            title: const Text("Gerenciar"),
          ),
          BottomNavyBarItem(
            icon: const Icon(Icons.person),
            title: const Text("Perfil"),
          ),
        ],
      ),
    );
  }

  // Widget _buildScreen(AppTab activeTab) {
  //   switch (activeTab) {
  //     case AppTab.home:
  //       return HomeScreen();
  //     case AppTab.announce:
  //       return ListingScreen();
  //     case AppTab.manage:
  //       return ManagementScreen();
  //     case AppTab.profile:
  //       return ProfileScreen();
  //   }
  // }
}
