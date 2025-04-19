import '../models/TreinoModel.dart';
import '../app_data.dart';

bool verificarTreino(){
  for (TreinoModel treino in AppData.treinos){
    bool completed = treino.exercicios.every((ex) => ex.completed);
    if (completed){
      return true;
    }
  }
  return false;
}

bool verificarAtividade(){
  bool completed = AppData.listaAtividades.every((el) => el.completed);
  return completed;
}

bool verificarAgua(){
  if (AppData.waterConsumed > 2000){
    return true;
  }
  return false;
}

bool verificarMedicamento(){
  if (AppData.listaAtividades.where((el) => el.categoria == 'Saúde' && el.completed).toList().length == AppData.listaAtividades.where((el) => el.categoria == 'Saúde')){
    return true;
  }
  return false;
}