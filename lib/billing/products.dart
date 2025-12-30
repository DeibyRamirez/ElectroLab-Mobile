class AppProduct {
  final String id;
  final bool consumable;
  final int coins;
  final String title;
  final String description;

  const AppProduct({
    required this.id,
    required this.consumable,
    required this.title,
    required this.description,
    this.coins = 0,
  });
}

class Products {
  static const creditos10 = AppProduct(
    id: 'creditos_10',
    consumable: true,
    coins: 10,
    title: '10 Créditos',
    description: 'Recibe 10 créditos para usar en la app',
  );

  static const creditos20 = AppProduct(
    id: 'creditos_20',
    consumable: true,
    coins: 20,
    title: '20 Créditos',
    description: 'Recibe 20 créditos para usar en la app',
  );

  static const creditos50 = AppProduct(
    id: 'creditos_50',
    consumable: true,
    coins: 50,
    title: '50 Créditos',
    description: 'Recibe 50 créditos para usar en la app',
  );

  static const removeAds = AppProduct(
    id: 'anuncios',
    consumable: false,
    title: 'Quitar anuncios',
    description: 'Elimina todos los anuncios de la aplicación',
  );

  static const all = [
    creditos10,
    creditos20,
    creditos50,
    removeAds,
  ];

  static AppProduct byId(String id) {
    return all.firstWhere(
      (p) => p.id == id,
      orElse: () => throw Exception("Producto no registrado: $id"),
    );
  }
}
