import 'package:flutter/material.dart';

import 'screens/home_page.dart';
import 'state/store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final StoreController store = await StoreController.load();
  runApp(WatchStoreApp(store: store));
}

class WatchStoreApp extends StatefulWidget {
  const WatchStoreApp({super.key, this.store});

  /// The store to use. Without one the app keeps its state in memory only.
  final StoreController? store;

  @override
  State<WatchStoreApp> createState() => _WatchStoreAppState();
}

class _WatchStoreAppState extends State<WatchStoreApp> {
  late final StoreController _store = widget.store ?? StoreController();

  @override
  Widget build(BuildContext context) {
    return StoreScope(
      store: _store,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Chrono Vault',
        theme: ThemeData(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFEE8A2E),
            secondary: Color(0xFF63E5D7),
            surface: Color(0xFF131B2C),
          ),
          scaffoldBackgroundColor: const Color(0xFF0B1120),
          useMaterial3: true,
        ),
        home: const WatchStoreHome(),
      ),
    );
  }
}
