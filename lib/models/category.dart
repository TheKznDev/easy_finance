import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Category {
  final String id;
  final String name;
  final int? iconCodePoint; // Armazena o codePoint do ícone (ex: Icons.shopping_cart.codePoint)
  final int? color; // Armazena o valor da cor (ex: Colors.blue.value)

  Category({
    String? id,
    required this.name,
    this.iconCodePoint,
    this.color,
  }) : id = id ?? const Uuid().v4();

  // Métodos de conversão para SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconCodePoint': iconCodePoint,
      'color': color,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String,
      name: map['name'] as String,
      iconCodePoint: map['iconCodePoint'] as int?,
      color: map['color'] as int?,
    );
  }

  // Método copyWith para imutabilidade
  Category copyWith({
    String? id,
    String? name,
    int? iconCodePoint,
    int? color,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      color: color ?? this.color,
    );
  }

  // Métodos de conversão para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'iconCodePoint': iconCodePoint,
      'color': color,
    };
  }

  factory Category.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options) {
    final data = snapshot.data();
    return Category(
      id: snapshot.id,
      name: data?['name'],
      iconCodePoint: data?['iconCodePoint'],
      color: data?['color'],
    );
  }
}
