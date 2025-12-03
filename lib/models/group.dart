import 'package:hive/hive.dart';

part 'group.g.dart';

@HiveType(typeId: 1) // Novo typeId, diferente do Transaction
class Group extends HiveObject {
  @HiveField(0)
  late String name;

  @HiveField(1)
  late double targetValue;

  @HiveField(3)
  late double totalValue;


  @HiveField(2)
  late DateTime creationDate;
}
