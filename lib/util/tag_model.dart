import 'dart:io';
import 'package:flutter/material.dart';

class Tag {
  String id;
  String name;
  File? image;
  Color color;

  Tag({required this.id, required this.name, this.image, required this.color});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imagePath': image?.path,
      'color': color.value,
    };
  }

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'],
      name: json['name'],
      image: json['imagePath'] != null ? File(json['imagePath']) : null,
      color: Color(json['color']),
    );
  }
}