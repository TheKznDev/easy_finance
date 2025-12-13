import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

// Enum para o tipo de transação. Mais seguro que usar Strings.
enum TransactionType { income, expense }

class Transaction {
  final String id;
  final String description;
  final double value;
  final DateTime date;
  final TransactionType type;

  // Chaves estrangeiras (podem ser nulas)
  final String? categoryId;
  final String? goalId;
  final String? groupId;

  Transaction({
    String? id,
    required this.description,
    required this.value,
    required this.date,
    required this.type,
    this.categoryId,
    this.goalId,
    this.groupId,
  }) : id = id ?? const Uuid().v4();

  // Converte um objeto Transaction em um Map para persistência no SQLite.
  // O DateTime é convertido para um inteiro (millisecondsSinceEpoch).
  // O Enum é convertido para uma String.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'value': value,
      'date': date.millisecondsSinceEpoch,
      'type': type == TransactionType.income ? 'INCOME' : 'EXPENSE',
      'categoryId': categoryId,
      'goalId': goalId,
      'groupId': groupId,
    };
  }

  // Converte um Map (vindo do SQLite) em um objeto Transaction.
  // O inteiro é convertido de volta para DateTime.
  // A String é convertida de volta para o Enum.
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as String,
      description: map['description'] as String,
      value: map['value'] as double,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      type: map['type'] == 'INCOME' ? TransactionType.income : TransactionType.expense,
      categoryId: map['categoryId'] as String?,
      goalId: map['goalId'] as String?,
      groupId: map['groupId'] as String?,
    );
  }

  // Cria uma cópia do objeto Transaction com a possibilidade de alterar alguns de seus valores.
  // Útil para manter a imutabilidade.
  Transaction copyWith({
    String? id,
    String? description,
    double? value,
    DateTime? date,
    TransactionType? type,
    String? categoryId,
    String? goalId,
    String? groupId,
  }) {
    return Transaction(
      id: id ?? this.id,
      description: description ?? this.description,
      value: value ?? this.value,
      date: date ?? this.date,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      goalId: goalId ?? this.goalId,
      groupId: groupId ?? this.groupId,
    );
  }

  // Converte para um formato compatível com Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'description': description,
      'value': value,
      'date': Timestamp.fromDate(date), // Firestore usa seu próprio tipo Timestamp
      'type': type.toString(),
      'categoryId': categoryId,
      'goalId': goalId,
      'groupId': groupId,
    };
  }

  // Cria um objeto Transaction a partir de um snapshot do Firestore.
  factory Transaction.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options) {
    final data = snapshot.data();
    return Transaction(
      id: snapshot.id,
      description: data?['description'],
      value: data?['value'],
      date: (data?['date'] as Timestamp).toDate(),
      type: data?['type'] == TransactionType.income.toString() ? TransactionType.income : TransactionType.expense,
      categoryId: data?['categoryId'],
      goalId: data?['goalId'],
      groupId: data?['groupId'],
    );
  }
}
