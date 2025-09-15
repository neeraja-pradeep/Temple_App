import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:temple/features/shop/cart/presentation/checkout_screen.dart';
import 'package:temple/features/shop/presentation/shopping_section.dart';
import 'package:temple/features/shop/providers/gesture_riverpod.dart';

import '../features/home/presentation/home_page.dart';
import '../features/music/presentation/music_page.dart';
import '../features/pooja/presentation/pooja_page.dart';
import '../features/special/presentation/special_page.dart';
import 'app_colors.dart';

class MainNavScreen extends ConsumerStatefulWidget {
  final Widget? drawerContent;
  const MainNavScreen({super.key, this.drawerContent});

  @override
  ConsumerState<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends ConsumerState<MainNavScreen> {
  int _selectedIndex = 2;

  final List<String> _labels = [
    'പ്രത്യകം', // Special
    'പൂജ', // Pooja
    'ദർശനം', // Home
    'വിപണി', // Shop
    'സംഗീതം', // Music
  ];

  final List<String> _icons = [
    'assets/bottomNavBar/bn1.png',
    'assets/bottomNavBar/bn2.png',
    'assets/bottomNavBar/bn3.png',
    'assets/bottomNavBar/bn4.png',
    'assets/bottomNavBar/bn5.png',
  ];

  @override
  Widget build(BuildContext context) {
    final onTapCheckout = ref.watch(onclickCheckoutButton);
    final List<Widget> pages = [
      SpecialPage(),
      PoojaPage(),
      HomePage(),
      onTapCheckout ? CheckoutScreen() : ShoppingSectionScreeen(),

      MusicPage(),
    ];
    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return SafeArea(
      child: Scaffold(
        drawer: _selectedIndex == 2
            ? Drawer(
                backgroundColor: const Color(0xFFD9D9D9),
                width: 285.w,
                child: Consumer(
                  builder: (context, ref, _) =>
                      HomePage.buildDrawerContent(context, ref),
                ),
              )
            : null,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/backgroundimage.jpg',
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
              alignment: Alignment.topCenter,
            ),
            pages[_selectedIndex],
          ],
        ),
        bottomNavigationBar: Container(
          height: 70.h,
          decoration: BoxDecoration(
            color: AppColors.navBarBackground,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8.r,
                offset: Offset(0, -2.h),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_icons.length, (index) {
              final isSelected = _selectedIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedIndex = index),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    isSelected
                        ? Container(
                            width: 65.w,
                            height: 55.h, // increased to avoid overflow
                            decoration: BoxDecoration(
                              color: AppColors.selectedBackground,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: AppColors.selectedBackground,
                                width: 1.w,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color.fromRGBO(140, 0, 26, 0.16),
                                  offset: Offset(0, 4.h),
                                  blurRadius: 16.r,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  _icons[index],
                                  width: 26.w,
                                  height: 26.w,
                                  color: AppColors.selected,
                                ),
                                SizedBox(height: 1.h), // reduced spacing
                                FittedBox(
                                  child: Text(
                                    _labels[index],
                                    style: TextStyle(
                                      fontSize: 12.sp, // reduced font size
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.selected,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Image.asset(
                            _icons[index],
                            height: 26.h,
                            width: 26.w,
                            color: AppColors.unselected,
                          ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Temple App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MainNavScreen(),
      builder: (context, child) {
        ScreenUtil.init(context);
        return child!;
      },
    );
  }
}
