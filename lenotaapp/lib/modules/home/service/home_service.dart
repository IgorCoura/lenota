class HomeService {
  List<String> listScanners = [];

  Future addScanner(String scanner) async {
    listScanners.add(scanner);
  }

  Future<List<String>> getScanners() {
    return Future.value(listScanners);
  }
}
