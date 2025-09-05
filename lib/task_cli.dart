import "dart:convert";
import "dart:io";

void run(List<String> args) async {
  try {
    var (actionArgs, valuesArgs) = parsheArguments(args);

    if (valuesArgs.isEmpty && actionArgs != 'list') {
      throw Exception("Las acciones necesitan un argumento");
    }

    File dataFile = File("data.json");

    switch (actionArgs) {
      case "add":
        add(valuesArgs, dataFile);
        break;
      case "update":
        update(valuesArgs, dataFile);
        break;
      case "delete":
        delete(valuesArgs, dataFile);
        break;
      case "list":
        list(valuesArgs, dataFile);
        break;
      case "mark-in-progress":
        markTask("in-progress", valuesArgs, dataFile);
        break;
      case "mark-done":
        markTask("done", valuesArgs, dataFile);
        break;
      case "help":
        showHelp();
        break;

    }
  } catch (e) { // Este try cath esta para poder mostrar la ayuda para el usuario
    showHelp();
  }
}

// ADD
void add(List<String> valuesArgs, File dataFile) async {
  List data = await readFile(dataFile);
  List idsForDisplay = []; // lista de ids agregados.

  for (int i = 0; i < valuesArgs.length; i++) {
    DateTime createdDate = DateTime.now();
    var task = {
      'id': (data.length + 1).toString(),
      'description': valuesArgs[i],
      'status': 'todo',
      'createdAt': createdDate.toString(),
      'updatedAt': createdDate.toString(),
    };

    idsForDisplay.add(data.length + 1);
    data.add(task);
  }

  saveFile(dataFile, data);
  print('Task added succesfully (ID: $idsForDisplay)');
}

// UPDATE
void update(List<String> valuesArgs, File dataFile) async {
  List data = await readFile(dataFile);
  for (var task in data) {
    if (task['id'] == valuesArgs.first) {
      task['description'] = valuesArgs[1];
      task['updatedAt'] = DateTime.now().toString();
      break;
    }
  }
  saveFile(dataFile, data);
  print('Task updated succesfully (ID: ${valuesArgs.first})');
}

// DELETE
void delete(List<String> valuesArgs, File dataFile) async {
  List data = await readFile(dataFile);

  data.removeWhere((task) => valuesArgs.contains(task['id']));
  saveFile(dataFile, data);

  print("Task deleted ${valuesArgs.first} succesfully");
}

// LIST
void list(List<String> valuesArgs, File dataFile) async {
  List data = await readFile(dataFile);
  if (data.isEmpty) {
    print('No existen tareas, agregue alguna');
    return;
  }

  for (var task in data) {
    if (valuesArgs.isEmpty || task['status'] == valuesArgs[0]) {
      print(
        '-' * (8 * 14),
      ); // numero 8 es el tamano de espacios de tab y 14 la cantidad de veces este se repetira
      print(
        "ID: ${task['id']}\t|Status: ${task['status']}${(task['status'].length > 8) ? '\t' : '\t\t'}|Created at: ${task['createdAt']}\t|Updated at: ${task['updatedAt']}\t|",
      );
      print('-' * (8 * 14));
      print("\t ${task['description']}\n");
    }
  }
}

// MARK IN MARK IN PROGRESS
void markTask(String newStatus, List<String> valuesArgs, File dataFile) async {
  List data = await readFile(dataFile);
  for (var task in data) {
    if (task['id'] == valuesArgs.first) {
      task['status'] = newStatus;
      task['updatedAt'] = DateTime.now().toString();
      break;
    }
  }
  saveFile(dataFile, data);
  print('Task marked to in progress (ID: ${valuesArgs.first})');
}

void showHelp() {
  var displayHelp = """
Usage:
\ttask-cli [action] [valuesArgs]
action:
\tadd [valuesArgs]\t\tYou have agree many task for example: task-cli add 'one task' 'two task' 'and many tasks'
\tupdate [idTask] [newContent]\tUpdate the description to task passed for id un idTask.
\tdelete [idTask]\t\t\tDelete one or many task passed in idTask, example: delete 1 2 5 645
\tmark-in-progress [idTask]\tMark the task passed for idTask with in-progress.
\tmark-done [idTask]\t\tMark the task passed for idTask with done.
\thelp\t\t\t\tShow this display usage.
  """;
  print(displayHelp);
}

void saveFile(File dataFile, List data) async {
  var dataFileWriting = dataFile.openWrite();
  dataFileWriting.write(jsonEncode(data));
  await dataFileWriting.flush();
  await dataFileWriting.close();
}

Future<List> readFile(File dataFile) async {
  var data = await dataFile.readAsString();
  return (dataFile.existsSync() && data.isNotEmpty) ? jsonDecode(data) : [];
}

/// Esta funcion separa la lista de argumentos en un Record
/// de @action y la lista que viene despues
(String, List<String>) parsheArguments(List<String> args) {
  if (args case [String action, ...]) {
    return (action, args.sublist(1));
  } else {
    throw Exception("No existen argumentos");
  }
}
