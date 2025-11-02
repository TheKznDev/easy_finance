import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0)
class Transaction extends HiveObject {
  @HiveField(0)
  late String descricao;

  @HiveField(1)
  String? descricao2;

  @HiveField(2)
  late double valor;

  @HiveField(3)
  late DateTime dt_transacao;
}
