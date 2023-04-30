// import 'dart:async';
// import 'package:flutter/foundation.dart';
// import 'package:mynotes/%20extensions/list/filter.dart';
// import 'package:path/path.dart' show join;
// import 'package:path_provider/path_provider.dart'
//     show MissingPlatformDirectoryException, getApplicationDocumentsDirectory;
// import 'package:sqflite/sqflite.dart';
// import '../../constants/crud_const.dart';
// import 'crud_exceptions.dart';
// // import 'dart:developer' as devtools show log;

// class NotesService {
//   DatabaseUser? _user;

//   NotesService._sharedInstance() {
//     _notesStreamController =
//         StreamController<List<DatabaseNote>>.broadcast(onListen: () {
//       _notesStreamController.sink.add(_notes);
//     });
//   }
//   static final NotesService _shared = NotesService._sharedInstance();
//   factory NotesService() {
//     return _shared;
//   }
//   Database? _db;

//   List<DatabaseNote> _notes = [];
//   late final StreamController<List<DatabaseNote>> _notesStreamController;

//   Stream<List<DatabaseNote>> get allNotes => _notesStreamController.stream.filter((note) {
//     final currentUser = _user;
//     if(currentUser != null) {
//       return note.userId == currentUser.id;
//     }else{
//       throw UserShouldBeSetBeforeReadingAllNotes();
//     }
//   });

//   Future<void> _cacheNotes() async {
//     final allNotes = await getAllNotes();
//     _notes = allNotes.toList();
//     _notesStreamController.add(_notes);
//   }

//   Future<DatabaseUser> getOrCreateUser({
//     required email,
//     bool setAsCurrentUser = true,
//   }) async {
//     try {
//       final user = await getUser(email: email);
//       if(setAsCurrentUser) {
//         _user = user;
//       }
//       return user;
//     } on CouldNotFindUser {
//       final createDbUser = await createUser(email: email);
//       if(setAsCurrentUser) {
//         _user = createDbUser;
//       }
//       return createDbUser;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Database _getDatabaseOrThrow() {
//     final db = _db;
//     if (db == null) {
//       throw DatabaseIsNotOpenException();
//     } else {
//       return db;
//     }
//   }

//   Future<DatabaseNote> updateNote({
//     required DatabaseNote note,
//     required String text,
//   }) async {
//     await _ensureDbIsOpen();

//     final db = _getDatabaseOrThrow();
//     await getNote(id: note.id);

//     final updateCount = await db.update(
//         noteTable,
//         {
//           textColumn: text,
//           isSyncedWithCloudColumn: 0,
//         },
//         where: 'id = ?',
//         whereArgs: [note.id]);

//     if (updateCount == 0) throw CouldNotUpdateNote();
//     final updatedNote = await getNote(id: note.id);
//     _notes.removeWhere((n) => n.id == updatedNote.id);
//     _notes.add(updatedNote);

//     _notesStreamController.add(_notes);

//     return updatedNote;
//   }

//   Future<Iterable<DatabaseNote>> getAllNotes() async {
//     await _ensureDbIsOpen();

//     final db = _getDatabaseOrThrow();
//     final notes = await db.query(noteTable);

//     return notes.map((note) => DatabaseNote.fromRow(note));
//   }

//   Future<DatabaseNote> getNote({required int id}) async {
//     await _ensureDbIsOpen();

//     final db = _getDatabaseOrThrow();
//     final resultNote = await db.query(
//       noteTable,
//       limit: 1,
//       where: 'id = ?',
//       whereArgs: [id],
//     );

//     if (resultNote.isEmpty) {
//       throw CouldNotFindNote();
//     } else {
//       final note = DatabaseNote.fromRow(resultNote.first);
//       _notes.removeWhere((n) => n.id == id);
//       _notes.add(note);
//       _notesStreamController.add(_notes);
//       return note;
//     }
//   }

//   Future<int> deleteAllNotes() async {
//     await _ensureDbIsOpen();

//     final db = _getDatabaseOrThrow();

//     final deleteCount = await db.delete(noteTable);

//     // ignore: unrelated_type_equality_checks
//     if (deleteCount == 0) throw CouldNotDeleteNote();
//     _notes = [];
//     _notesStreamController.add(_notes);
//     return deleteCount;
//   }

//   Future<void> deleteNote({required int id}) async {
//     await _ensureDbIsOpen();

//     final db = _getDatabaseOrThrow();

//     final deleteCount = db.delete(noteTable, where: 'id = ?', whereArgs: [id]);

//     // ignore: unrelated_type_equality_checks
//     if (deleteCount == 0) throw CouldNotDeleteNote();
//     _notes.removeWhere((n) => n.id == id);
//     _notesStreamController.add(_notes);
//   }

//   Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
//     await _ensureDbIsOpen();

//     final db = _getDatabaseOrThrow();
//     final dbUser = await getUser(email: owner.email);
//     //Checking the owner exists and is the owner of the note
//     if (dbUser != owner) throw CouldNotFindUser();

//     const text = '';
//     //Creating the note
//     final noteId = await db.insert(noteTable, {
//       userIdColumn: owner.id,
//       textColumn: text,
//       isSyncedWithCloudColumn: true,
//     });

//     final note = DatabaseNote(
//       id: noteId,
//       userId: owner.id,
//       text: text,
//       isSyncedWithCloud: true,
//     );

//     _notes.add(note);
//     _notesStreamController.add(_notes);

//     return note;
//   }

//   Future<DatabaseUser> getUser({required String email}) async {
//     await _ensureDbIsOpen();

//     final db = _getDatabaseOrThrow();

//     final res = await db.query(
//       userTable,
//       limit: 1,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );

//     if (res.isEmpty) {
//       throw CouldNotFindUser();
//     } else {
//       return DatabaseUser.fromRow(res.first);
//     }
//   }

//   Future<DatabaseUser> createUser({required String email}) async {
//     await _ensureDbIsOpen();

//     final db = _getDatabaseOrThrow();
//     //checking if the user exists
//     final res = await db.query(
//       userTable,
//       limit: 1,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );
//     if (res.isNotEmpty) throw UserAlreadyExists();

//     final userId =
//         await db.insert(userTable, {emailColumn: email.toLowerCase()});

//     return DatabaseUser(id: userId, email: email);
//   }

//   Future<void> deleteUser({required String email}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();

//     final deleteCount = await db.delete(userTable,
//         where: 'email = ?', whereArgs: [email.toLowerCase()]);

//     if (deleteCount != 1) throw CouldNotDeleteUser();
//   }

//   Future<void> close() async {
//     final db = _db;
//     if (db == null) {
//       throw DatabaseIsNotOpenException();
//     } else {
//       await db.close();
//       _db = null;
//     }
//   }

//   Future<void> _ensureDbIsOpen() async {
//     try {
//       await open();
//     } on DatabaseAlreadyOpenException {
//       //Ntin
//     }
//   }

//   Future<void> open() async {
//     if (_db != null) throw DatabaseAlreadyOpenException();

//     try {
//       final docsPath = await getApplicationDocumentsDirectory();
//       final dbPath = join(docsPath.path, dbName);
//       final db = await openDatabase(dbPath);

//       _db = db;

//       await db.execute(createUserTable);

//       await db.execute(createNoteTable);
//       //  to cache the notes
//       await _cacheNotes();
//     } on MissingPlatformDirectoryException {
//       throw UnableToGetDocumentDirectory();
//     } catch (e) {
//       rethrow;
//     }
//   }
// }

// @immutable
// class DatabaseUser {
//   final int id;
//   final String email;

//   const DatabaseUser({
//     required this.id,
//     required this.email,
//   });

//   DatabaseUser.fromRow(Map<String, dynamic> map)
//       : email = map[emailColumn] as String,
//         id = map[idColumn] as int;

//   @override
//   String toString() {
//     return "Person, ID = $id, Email = $email";
//   }

//   @override
//   bool operator ==(covariant DatabaseUser other) => id == other.id;

//   @override
//   int get hashCode => id.hashCode;
// }

// class DatabaseNote {
//   final int id;
//   final int userId;
//   final String text;
//   final bool isSyncedWithCloud;

//   DatabaseNote(
//       {required this.id,
//       required this.userId,
//       required this.text,
//       required this.isSyncedWithCloud});

//   DatabaseNote.fromRow(Map<String, dynamic> map)
//       : id = map[idColumn] as int,
//         userId = map[userIdColumn],
//         text = map[textColumn] as String,
//         isSyncedWithCloud = map[isSyncedWithCloudColumn] == 1 ? true : false;

//   @override
//   String toString() => "text = $text";
//       // "Note, ID = $id, UserId = $userId, isSyncedWithCloud = $isSyncedWithCloud, text = $text";

//   @override
//   bool operator ==(covariant DatabaseNote other) => id == other.id;

//   @override
//   int get hashCode => id.hashCode;
// }
