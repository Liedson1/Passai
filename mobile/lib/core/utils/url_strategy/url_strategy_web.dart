import 'package:flutter_web_plugins/url_strategy.dart';

void configureAppUrlStrategy() {
  // Remove a cerquilha (#) da URL no navegador web
  usePathUrlStrategy();
}
