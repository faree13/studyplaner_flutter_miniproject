import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:study_planner/model/study_planner_model.dart';

class DatabaseService{
  final CollectionReference todoCollection = FirebaseFirestore.instance.collection("todos");

  User? user = FirebaseAuth.instance.currentUser;

  // Add todo task
  Future<DocumentReference> addTodoTask(String title, String description)async{
    return await todoCollection.add({
      'uid' : user!.uid,
      'title' : title,
      'description' : description,
      'completed' : false,
      'createdAt' : FieldValue.serverTimestamp(),
    });
  }

  // Updata ToDo task
  Future<void> updateTodo(String id, String title, String description) async{
    final updatatodoCollection = FirebaseFirestore.instance.collection("todos").doc(id);
    return await updatatodoCollection.update({
      'title' : title,
      'description' : description,
    });
  }

  // Update todo Status
  Future<void> updateTodoStatus(String id, bool completed)async{
    return await todoCollection.doc(id).update({'completed':completed});
  }

  // delete todo Status
  Future<void> deleteTodoStatus(String id)async{
    return await todoCollection.doc(id).delete();
  }
   
  // get pending task
  Stream<List<Todo>> get todos{
    return todoCollection.where('uid', isEqualTo: user!.uid).where('completed', isEqualTo: false).snapshots().map(_todoListFromSnapShot);
  }

    // get completed task
   Stream<List<Todo>> get completedtodos{
    return todoCollection.where('uid', isEqualTo: user!.uid).where('completed', isEqualTo: true).snapshots().map(_todoListFromSnapShot);
  }

  List<Todo> _todoListFromSnapShot(QuerySnapshot snapshot){
    return snapshot.docs.map((doc){
      return Todo(id: doc.id, 
      title: doc['title'] ?? '', 
      description: doc['description'] ?? '', 
      completed: doc['completed'] ?? false,  
      timeStamp: doc['createdAt'] ?? ''
      );
    }).toList();
  }
}
