import "dart:convert";
import "dart:io";

void run(List<String> args) async {
  var (actionArgs, valuesArgs) = parsheArguments(args);

  if (valuesArgs.isEmpty && actionArgs != 'list') {
    //TODO: Mostrar el manual de uso, similar al comando --help
    return;
  }

  File dataFile = File("data.json");

  switch (actionArgs) {
    case "add":
      add(valuesArgs, dataFile);
      break;
    case "update":
      print("Updateando");
      break;
    case "delete":
      print("Deleteando");
      delete(valuesArgs, dataFile);
      break;
    case "list":
      list(valuesArgs, dataFile);
      break;
  }
}

void add(List<String> valuesArgs, File dataFile) async {
  List data = await readFile(dataFile);
  List idsForDisplay = []; // lista de ids agregados.

  for (int i = 0; i < valuesArgs.length; i++) {
    var task = {
      'id': (data.length + 1).toString(),
      'description': valuesArgs[i],
      'status': 'todo',
    };

    idsForDisplay.add(data.length + 1);
    data.add(task);
  }

  saveFile(dataFile, data);
  print('Task added succesfully (ID: $idsForDisplay)');
}

void update(List<String> valuesArgs, File dataFile) {}

void delete(List<String> valuesArgs, File dataFile) async {
  List data = await readFile(dataFile);

  data.removeWhere((task) => valuesArgs.contains(task['id']));
  saveFile(dataFile, data);

  print("Task deleted ${valuesArgs.first} succesfully");
  
}

void list(List<String> valuesArgs, File dataFile) async {
  List data = await readFile(dataFile);
  if (data.isEmpty) {
    print('No existen tareas, agregue alguna');
    return;
  }

  print("ID\t|STATUS\t\t|DESCRIPTION");
  print("-" * 48);
  for (var task in data) {
    if (valuesArgs.isEmpty || task['status'] == valuesArgs[0]) {
      print(
        "${task['id']}\t|${task['status']}${(task['status'].length > 8) ? '\t' : '\t\t'}|${task['content']}",
      );
    }
  }
}

void saveFile(File dataFile, List data) async {
  var dataFileWriting = dataFile.openWrite();
  dataFileWriting.write(jsonEncode(data));
  await dataFileWriting.flush();
  await dataFileWriting.close();
}

Future<List> readFile(File dataFile) async {
  return dataFile.existsSync() ? jsonDecode(await dataFile.readAsString()) : [];
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
