import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class Goal {
  final String id;
  final String name;
  final double targetValue;
  final DateTime deadline;

  Goal({
    String? id,
    required this.name,
    required this.targetValue,
    required this.deadline,
  }) : id = id ?? const Uuid().v4();

  // Converte um objeto Goal em um Map para o SQLite.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'targetValue': targetValue,
      'deadline': deadline.millisecondsSinceEpoch,
    };
  }

  // Converte um Map (vindo do SQLite) em um objeto Goal.
  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'] as String,
      name: map['name'] as String,
      targetValue: map['targetValue'] as double,
      deadline: DateTime.fromMillisecondsSinceEpoch(map['deadline'] as int),
    );
  }

  // Cria uma cópia do objeto Goal, útil para imutabilidade.
  Goal copyWith({
    String? id,
    String? name,
    double? targetValue,
    DateTime? deadline,
  }) {
    return Goal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetValue: targetValue ?? this.targetValue,
      deadline: deadline ?? this.deadline,
    );
  }

  // Converte para um formato compatível com Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'targetValue': targetValue,
      'deadline': Timestamp.fromDate(deadline),
    };
  }

  // Cria um objeto Goal a partir de um snapshot do Firestore.
  factory Goal.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options) {
    final data = snapshot.data();
    return Goal(
      id: snapshot.id,
      name: data?['name'],
      targetValue: data?['targetValue'],
      deadline: (data?['deadline'] as Timestamp).toDate(),
    );
  }
}
