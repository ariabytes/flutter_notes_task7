import 'package:cloud_firestore/cloud_firestore.dart';

class CrudService {
  final CollectionReference items =
  FirebaseFirestore.instance.collection('items');

  Future <void> addItems(String name, int quantity) {
    //CREATE
    return items.add({
      'name': name,
      'quantity': quantity,
      'createdAt': Timestamp.now(),
      });
  }

  // READ
  Stream<QuerySnapshot> getItems() {
    return items.orderBy('createdAt', descending: true).snapshots();
  }

  // UPDATE
  Future <void> updateItems(String id, String name, int quantity){
    return items.doc(id).update({
      'name': name,
      'quantity': quantity,
    });
  }

  // DELETE
  Future <void> deleteItems(String id) {
    return items.doc(id).delete();
  }
}