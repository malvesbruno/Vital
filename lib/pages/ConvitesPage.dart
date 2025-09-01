import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_data.dart';
import '../cloud_service.dart';
import '../pages/DeluxePage.dart';


// Pagina que mostra os convites recebidos pelo user

class ConvitesPage extends StatefulWidget {
  const ConvitesPage({super.key});

  @override
  State<ConvitesPage> createState() => _ConvitesPageState();
}

class _ConvitesPageState extends State<ConvitesPage> {
  List<Map<String, dynamic>> convites = []; // lista de convites
  List<Map<String, dynamic>> respostas = []; // lista de respostas
  bool isLoading = true; // está carregando 
  @override
  void initState() {
    super.initState();
    buscarConvites(); // busca convites
    WidgetsBinding.instance.addPostFrameCallback((_) {
    isUltimate(AppData.ultimate);  //verifica se o player é ultimate
  });
  }

  // busca todos os convites no banco de dados
  Future<void> buscarConvites() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('invites')
        .where('receiverId', isEqualTo: AppData.id)
        .orderBy('timestamp', descending: true)
        .get();

    final todos = snapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data(),
    }).toList();

    setState(() {
      respostas = todos
        .where((doc) => doc['isResponse'] == true)
        .toList();

      convites = todos
        .where((doc) => doc['status'] == 'pending' && (doc['isResponse'] == null || doc['isResponse'] == false))
        .toList();

      isLoading = false;
    });
  }

  // atualiza o status do convite
  Future<void> atualizarStatus(String id, String status) async {
    await FirebaseFirestore.instance
        .collection('invites')
        .doc(id)
        .update({'status': status});

    // enviar resposta de volta para o remetente
    final convite = convites.firstWhere((c) => c['id'] == id);
    await FirebaseFirestore.instance.collection('invites').add({
      'senderId': AppData.id,
      'receiverId': convite['senderId'],
      'workoutSuggestion': convite['workoutSuggestion'],
      'timestamp': FieldValue.serverTimestamp(),
      'isResponse': true,
      'responseStatus': status,
    });

    // deletar o convite original
    await FirebaseFirestore.instance.collection('invites').doc(id).delete();

    buscarConvites();
  }

  // busca nome do sender
  Future<String> BuscarNome(String id) async {
    final sender = await BackupService().getUser(id);
    return sender?['name'] ?? 'Usuário';
  }

  // apaga a resposta
  Future<void> deletarResposta(String id) async {
    await FirebaseFirestore.instance.collection('invites').doc(id).delete();
    buscarConvites();
  }

  // verifica se o player é ultimate
  void isUltimate(ultimate){
    if (!ultimate){
      Navigator.push(context, MaterialPageRoute(builder: (context) => Deluxepage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Convites Recebidos"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : (convites.isEmpty && respostas.isEmpty)
              ? Center(
                  child: Text(
                    "Você não possui convites ou respostas no momento.",
                    style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                  ),
                )
              : ListView(
                  children: [
                    if (respostas.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text("Respostas aos seus convites",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary),
                        ),
                      ),
                    ...respostas.map((resposta) => FutureBuilder<String>(
                      future: BuscarNome(resposta['senderId']),
                      builder: (context, snapshot) {
                        final nome = snapshot.data ?? 'Usuário';
                        return Card(
                          margin: const EdgeInsets.all(12),
                          color: Theme.of(context).primaryColor.withOpacity(0.9),
                          child: ListTile(
                            title: Text("${nome} ${resposta['responseStatus'] == 'accepted' ? 'aceitou' : 'recusou'} seu convite para treinar ${resposta['workoutSuggestion']}",
                              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () => deletarResposta(resposta['id']),
                            ),
                          ),
                        );
                      },
                    )),
                    if (convites.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text("Convites pendentes",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary),
                        ),
                      ),
                    ...convites.map((convite) => FutureBuilder<String>(
                      future: BuscarNome(convite['senderId']),
                      builder: (context, snapshot) {
                        final nome = snapshot.data ?? 'Usuário';
                        return Card(
                          margin: const EdgeInsets.all(12),
                          color: Theme.of(context).primaryColor,
                          child: ListTile(
                            title: Text("Convite para treinar: ${convite['workoutSuggestion']}",
                                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
                            subtitle: Text("De: $nome",
                                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check, color: Colors.green),
                                  onPressed: () => atualizarStatus(convite['id'], 'accepted'),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  onPressed: () => atualizarStatus(convite['id'], 'rejected'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )),
                  ],
                ),
    );
  }
}
