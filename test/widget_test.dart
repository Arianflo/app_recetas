import '../lib/main.dart';
import '../lib/providers/favorites_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Carga de pantalla principal', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => FavoritesProvider(),
        child: const MyApp(),
      ),
    );

    // Verifica que aparezca el texto de AppBar
    expect(find.text('App de Recetas'), findsOneWidget);
  });
}
