import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wrapp de MaterialApp para tests con todos los providers necesarios
class TestApp extends StatelessWidget {
  final Widget child;
  final ThemeData? theme;
  final List<Override> providers;
  final GoRouter? router;

  const TestApp({
    super.key,
    required this.child,
    this.theme,
    this.providers = const [],
    this.router,
  });

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: providers,
      child: MaterialApp(
        theme: theme ?? ThemeData.light(),
        home: Scaffold(body: child),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

/// Wrapp con DarkMode para tests de themas
class TestAppWithDarkMode extends StatelessWidget {
  final Widget child;
  final List<Override> providers;

  const TestAppWithDarkMode({
    super.key,
    required this.child,
    this.providers = const [],
  });

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: providers,
      child: MaterialApp(
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.dark,
        home: Scaffold(body: child),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

/// Helper para crear test widget con pumping y settling
Future<void> pumpTestWidget(
  WidgetTester tester,
  Widget widget, {
  Duration duration = Duration.zero,
}) async {
  await tester.pumpWidget(widget);
  await tester.pump(duration);
  await tester.pumpAndSettle();
}

/// Helper para verificar que un widget está visible
void expectVisible(
  Finder finder, {
  bool visible = true,
  String? reason,
}) {
  if (visible) {
    expect(finder, findsOneWidget, reason: reason);
  } else {
    expect(finder, findsNothing, reason: reason);
  }
}

/// Helper para tap en widget con manejo de excepciones
Future<void> safeTap(
  WidgetTester tester,
  Finder finder, {
  Duration settleDelay = const Duration(milliseconds: 100),
}) async {
  try {
    await tester.tap(finder);
    await tester.pumpAndSettle(settleDelay);
  } catch (e) {
    throw TestFailure('Failed to tap on $finder: $e');
  }
}

/// Helper para ingresar texto con manejo de excepciones
Future<void> safeEnterText(
  WidgetTester tester,
  Finder finder,
  String text, {
  bool clearFirst = true,
  Duration settleDelay = const Duration(milliseconds: 100),
}) async {
  try {
    if (clearFirst) {
      await tester.enterText(finder, '');
    }
    await tester.enterText(finder, text);
    await tester.pumpAndSettle(settleDelay);
  } catch (e) {
    throw TestFailure('Failed to enter text "$text" in $finder: $e');
  }
}

/// Helper para verificar excepción esperada
Future<void> expectThrows<T>(
  FutureOr<void> Function() function, {
  String? reason,
}) async {
  try {
    await function();
    throw TestFailure('Expected exception of type $T but none was thrown${reason != null ? ': $reason' : ''}');
  } on T {
    // Expected exception - test passes
  } catch (e) {
    throw TestFailure('Expected exception of type $T but got ${e.runtimeType}${reason != null ? ': $reason' : ''}');
  }
}

/// Helper para esperar hasta que se cumpla una condición
Future<void> waitFor(
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 5),
  Duration checkInterval = const Duration(milliseconds: 100),
}) async {
  final stopwatch = Stopwatch()..start();
  while (stopwatch.elapsed < timeout) {
    if (condition()) {
      return;
    }
    await Future.delayed(checkInterval);
  }
  throw TestFailure('Condition not met within $timeout');
}

/// Helper para verificar texto en widget
void expectText(
  String expectedText, {
  Finder? finder,
  bool contains = false,
}) {
  if (finder != null) {
    final widget = finder.evaluate().first.widget as Text?;
    expect(widget, isNotNull);
    final text = widget!.data as String?;
    expect(text, isNotNull);
    if (contains) {
      expect(text, contains(expectedText));
    } else {
      expect(text, equals(expectedText));
    }
  } else {
    if (contains) {
      expect(find.text(expectedText), findsOneWidget);
    } else {
      expect(find.text(expectedText), findsOneWidget);
    }
  }
}

/// Helper para verificar que una lista tiene la longitud esperada
void expectListLength<T>(
  List<T> list,
  int expectedLength, {
  String? reason,
}) {
  expect(list.length, equals(expectedLength), reason: reason);
}

/// Helper para verificar que un mapa tiene la llave esperada
void expectMapContains<K, V>(
  Map<K, V> map,
  K key, {
  String? reason,
}) {
  expect(map.containsKey(key), isTrue, reason: reason);
}

/// Helper para verificar que un valor no es nulo
void expectNotNull<T>(
  T? value, {
  String? reason,
}) {
  expect(value, isNotNull, reason: reason);
}

/// Helper para verificar que un valor es nulo
void expectNull<T>(
  T? value, {
  String? reason,
}) {
  expect(value, isNull, reason: reason);
}

/// Helper para verificar que un iterable está vacío
void expectEmpty<T>(
  Iterable<T> iterable, {
  String? reason,
}) {
  expect(iterable.isEmpty, isTrue, reason: reason);
}

/// Helper para verificar que un iterable no está vacío
void expectNotEmpty<T>(
  Iterable<T> iterable, {
  String? reason,
}) {
  expect(iterable.isNotEmpty, isTrue, reason: reason);
}

/// Helper para crear fecha de prueba
DateTime createTestDate({
  int year = 2024,
  int month = 1,
  int day = 1,
  int hour = 0,
  int minute = 0,
  int second = 0,
  int millisecond = 0,
}) {
  return DateTime(year, month, day, hour, minute, second, millisecond);
}

/// Helper para crear fecha futura de prueba
DateTime createFutureDate({
  int days = 1,
  DateTime? from,
}) {
  return (from ?? DateTime.now()).add(Duration(days: days));
}

/// Helper para crear fecha pasada de prueba
DateTime createPastDate({
  int days = 1,
  DateTime? from,
}) {
  return (from ?? DateTime.now()).subtract(Duration(days: days));
}

/// Helper para generar string aleatorio para tests
String generateRandomString({
  int length = 10,
  bool includeNumbers = true,
  bool includeUppercase = true,
  bool includeLowercase = true,
}) {
  final chars = <String>[];
  if (includeLowercase) {
    chars.addAll('abcdefghijklmnopqrstuvwxyz'.split(''));
  }
  if (includeUppercase) {
    chars.addAll('ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split(''));
  }
  if (includeNumbers) {
    chars.addAll('0123456789'.split(''));
  }

  chars.shuffle();
  return chars.take(length).join();
}

/// Helper para generar email aleatorio de prueba
String generateTestEmail() {
  return '${generateRandomString(length: 8).toLowerCase()}@test.com';
}

/// Helper para generar número aleatorio de prueba
int generateTestNumber({
  int min = 0,
  int max = 100,
}) {
  return min + DateTime.now().millisecond % (max - min);
}

/// Helper para generar número decimal aleatorio de prueba
double generateTestDecimal({
  double min = 0,
  double max = 100,
}) {
  return min + (DateTime.now().millisecond / 1000) * (max - min);
}

/// Excepción personalizada para errores de test
class TestFailure extends TestFailure {
  final String message;

  TestFailure(this.message) : super(message);
}
