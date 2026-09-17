import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const RunMyApp());
}

// FEATURE 3: Custom ThemeExtension for custom design tokens
class AppColors extends ThemeExtension<AppColors> {
  final Color success;

  const AppColors({required this.success});

  @override
  AppColors copyWith({Color? success}) =>
      AppColors(success: success ?? this.success);

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      success: Color.lerp(success, other.success, t)!,
    );
  }
}

class RunMyApp extends StatefulWidget {
  const RunMyApp({super.key});

  @override
  State<RunMyApp> createState() => _RunMyAppState();
}

class _RunMyAppState extends State<RunMyApp> {
  // Variable to manage current theme mode
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadThemeMode(); // FEATURE 2: Load saved theme mode on start
  }

  // FEATURE 2: Load theme mode from SharedPreferences
  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('themeMode');
    if (saved != null) {
      setState(() {
        _themeMode = ThemeMode.values.firstWhere(
          (mode) => mode.name == saved,
          orElse: () => ThemeMode.system,
        );
      });
    }
  }

  // FEATURE 2: Save theme mode to SharedPreferences
  Future<void> _saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode.name);
  }

  // Method to toggle theme and persist changes
  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
    _saveThemeMode(themeMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Status Card Demo',

      // FEATURE 1: Material 3 with ColorScheme.fromSeed
      // FEATURE 3: Register custom AppColors ThemeExtension
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.grey[200],
        extensions: const [
          AppColors(success: Colors.green),
        ],
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        extensions: const [
          AppColors(success: Colors.tealAccent),
        ],
      ),

      themeMode: _themeMode,

      home: HomeScreen(
        themeMode: _themeMode,
        onChangeTheme: changeTheme,
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final ThemeMode themeMode;
  final Function(ThemeMode) onChangeTheme;

  const HomeScreen({
    super.key,
    required this.themeMode,
    required this.onChangeTheme,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final customColors = Theme.of(context).extension<AppColors>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Status Card Demo'),
      ),
      // FEATURE 4: App-Wide AnimatedTheme Transition (500ms smooth cross-fade)
      body: AnimatedTheme(
        data: Theme.of(context),
        duration: const Duration(milliseconds: 500),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // PART 1 TASK: Avatar and Text
              CircleAvatar(
                radius: 45,
                backgroundColor: isDarkMode ? Colors.teal : Colors.blueGrey,
                child: const Icon(Icons.person, size: 42, color: Colors.white),
              ),

              const SizedBox(height: 12),

              const Text(
                'Flutter Theme Lab',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              // PART 2 TASK 1 & 3: AnimatedContainer (400ms transition)
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: 220,
                height: 64,
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.teal : Colors.amber,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // FEATURE 3 / PART 2: Status indicator using custom success color
                    Icon(
                      isDarkMode ? Icons.check_circle : Icons.circle_outlined,
                      size: 16,
                      color: customColors?.success ?? Colors.black87,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Status: Online',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              const Text('Toggle Dark Mode:', style: TextStyle(fontSize: 16)),

              const SizedBox(height: 10),

              // PART 2 TASK 2: Theme Switch Logic
              Switch(
                value: themeMode == ThemeMode.dark,
                onChanged: (bool isDark) {
                  onChangeTheme(isDark ? ThemeMode.dark : ThemeMode.light);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}