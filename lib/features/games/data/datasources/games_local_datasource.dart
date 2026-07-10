import '../models/game_model.dart';

abstract interface class GamesLocalDatasource {
  Future<List<GameModel>> getAuthorizedGames();
}

class GamesLocalDatasourceImpl implements GamesLocalDatasource {
  const GamesLocalDatasourceImpl();

  static const _basePath = 'assets/images/games';

  @override
  Future<List<GameModel>> getAuthorizedGames() async {
    return const [
      GameModel(id: 'diaria', name: 'Diaria', imagePath: '$_basePath/diaria.jpeg'),
      GameModel(id: 'juega3', name: 'Juega 3', imagePath: '$_basePath/juega3.jpeg'),
      GameModel(id: 'fechas', name: 'Fechas', imagePath: '$_basePath/fechas.jpeg'),
      GameModel(id: 'combo', name: 'Combo', imagePath: '$_basePath/combo.jpeg'),
      GameModel(id: 'terminacion2', name: 'Terminación 2', imagePath: '$_basePath/terminacion2.jpeg'),
      GameModel(id: 'tica', name: 'Tica', imagePath: '$_basePath/tica.jpeg'),
      GameModel(id: 'tresmonazo', name: 'Tresmonazo', imagePath: '$_basePath/tresmonazo.jpeg'),
      GameModel(id: 'hondurena', name: 'Hondureña', imagePath: '$_basePath/hondurena.jpeg'),
      GameModel(id: 'gana3', name: 'Gana 3', imagePath: '$_basePath/gana3.jpeg'),
      GameModel(id: 'primera', name: 'Primera', imagePath: '$_basePath/primera.jpeg'),
      GameModel(id: 'salvadorena', name: 'Salvadoreña', imagePath: '$_basePath/salvadorena.jpeg'),
      GameModel(id: 'rifas', name: 'Rifas', imagePath: '$_basePath/rifas.jpeg'),
      GameModel(id: 'multisorteo', name: 'Multi Sorteo', imagePath: '$_basePath/multisorteo.jpeg'),
    ];
  }
}
