import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class Group {
  final String id;
  final String name;
  final DateTime creationDate;

  Group({
    String? id,
    required this.name,
    required this.creationDate,
  }) : id = id ?? const Uuid().v4();

  // Métodos de conversão para SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'creationDate': creationDate.millisecondsSinceEpoch,
    };
  }

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'] as String,
      name: map['name'] as String,
      creationDate: DateTime.fromMillisecondsSinceEpoch(map['creationDate'] as int),
    );
  }

  // Método copyWith para imutabilidade
  Group copyWith({
    String? id,
    String? name,
    double? targetValue,
    DateTime? creationDate,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      creationDate: creationDate ?? this.creationDate,
    );
  }

  // Métodos de conversão para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'creationDate': Timestamp.fromDate(creationDate),
    };
  }

  factory Group.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options) {
    final data = snapshot.data();
    return Group(
      id: snapshot.id,
      name: data?['name'],
      creationDate: (data?['creationDate'] as Timestamp).toDate(),
    );
  }
}
