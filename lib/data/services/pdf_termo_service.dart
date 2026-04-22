import 'package:aiesec_lar_global/data/models/comite_local/testemunha.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import 'package:aiesec_lar_global/data/models/usuario/usuario.dart';
import 'package:aiesec_lar_global/data/models/intercambista/intercambista.dart';
import 'package:aiesec_lar_global/data/models/comite_local/comite_local.dart';

class PdfTermoService {
  static Future<void> gerarEImprimirTermo({
    required Usuario host,
    required Intercambista ep,
    required ComiteLocal comite,
  }) async {
    final pdf = pw.Document();

    // 1. Carrega a Fonte e a Logo
    final fontNormal = await PdfGoogleFonts.openSansRegular();
    final fontBold = await PdfGoogleFonts.openSansBold();

    // Tenta carregar a imagem da pasta assets (certifique-se de que ela existe)
    pw.MemoryImage? logoImage;
    try {
      final ByteData bytes = await rootBundle.load(
        'assets/image/aiesec_blue_logo.png',
      );
      logoImage = pw.MemoryImage(bytes.buffer.asUint8List());
    } catch (e) {
      print("Aviso: Logo não encontrada no caminho especificado.");
    }

    // 2. Estilos de Texto
    final normalStyle = pw.TextStyle(
      font: fontNormal,
      fontSize: 11,
      lineSpacing: 1.5,
    );
    final boldStyle = pw.TextStyle(font: fontBold, fontSize: 11);

    // --- ALTERAÇÃO: Título reduzido de 14 para 12 ---
    final titleStyle = pw.TextStyle(font: fontBold, fontSize: 12);

    // 3. Tratamento de Variáveis
    String dataAssinatura =
        "${comite.cidade}, ${DateFormat("dd 'de' MMMM 'de' yyyy", "pt_BR").format(DateTime.now())}";

    String endComite = comite.endereco != null
        ? "${comite.endereco!.logradouro}, nº ${comite.endereco!.numero}, bairro ${comite.endereco!.bairro}, CEP ${comite.endereco!.cep}, ${comite.endereco!.cidade} - ${comite.endereco!.estado}"
        : "__________________________________________________";

    String endHost = host.endereco != null
        ? "${host.endereco!.logradouro}, nº ${host.endereco!.numero}, bairro ${host.endereco!.bairro}, CEP ${host.endereco!.cep}, ${host.endereco!.cidade} - ${host.endereco!.estado}"
        : "__________________________________________________";

    String presNome =
        comite.dadosPresidente?.nomeCompleto ?? "_________________";
    String presEstadoCivil = comite.dadosPresidente?.estadoCivil ?? "_______";
    String presTelefone = comite.dadosPresidente?.telefone ?? "______________";
    String presRg = comite.dadosPresidente?.rg ?? "_________";
    String presOrgao = comite.dadosPresidente?.orgaoEmissor ?? "____";
    String presCpf = comite.dadosPresidente?.cpf ?? "______________";

    String dataChegada = ep.dataChegada ?? ep.dataRePresencial;
    if (dataChegada.isEmpty || dataChegada == 'Não preenchido') {
      dataChegada = "___/___/_____";
    }

    String dataPartida = ep.dataPartida ?? ep.dataFinPresencial;
    if (dataPartida.isEmpty || dataPartida == 'Não preenchido') {
      dataPartida = "___/___/_____";
    }

    // 4. Construção do PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 50, vertical: 40),

        // --- HEADER (Repete em todas as páginas) ---
        header: (pw.Context context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 20),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                if (logoImage != null)
                  // --- ALTERAÇÃO: Largura da logo aumentada de 100 para 140 ---
                  pw.Image(logoImage, width: 140)
                else
                  pw.Text(
                    "AIESEC",
                    style: pw.TextStyle(
                      font: fontBold,
                      fontSize: 18,
                      color: PdfColors.blue900,
                    ),
                  ),
                pw.Text(
                  "ÚLTIMA ATUALIZAÇÃO: Março de 2023",
                  style: pw.TextStyle(
                    font: fontNormal,
                    fontSize: 8,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
          );
        },

        build: (pw.Context context) {
          return [
            // --- TÍTULO ---
            pw.Center(
              child: pw.Text(
                "TERMO DE HOSPEDAGEM DE INTERCAMBISTA",
                style: titleStyle,
              ),
            ),
            pw.SizedBox(height: 20),

            // --- INTRODUÇÃO E PARTES ---
            pw.Text(
              "Por este instrumento particular que entre si celebram:",
              style: normalStyle,
            ),
            pw.SizedBox(height: 10),

            pw.RichText(
              textAlign: pw.TextAlign.justify,
              text: pw.TextSpan(
                style: normalStyle,
                children: [
                  pw.TextSpan(text: "AIESEC: ", style: boldStyle),
                  pw.TextSpan(
                    text:
                        "${comite.nome}, pessoa jurídica de direito privado sem fins lucrativos, inscrita no CNPJ/MF sob n° ${comite.cnpj ?? '______________'}, com sede na $endComite, neste ato representada por seu(sua) presidente, $presNome, estado civil $presEstadoCivil, telefone $presTelefone, portador do RG n° $presRg e inscrito no CPF sob o n° $presCpf, emitido pelo $presOrgao, doravante denominada simplesmente AIESEC.",
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 10),

            pw.RichText(
              textAlign: pw.TextAlign.justify,
              text: pw.TextSpan(
                style: normalStyle,
                children: [
                  pw.TextSpan(text: "Anfitrião: ", style: boldStyle),
                  pw.TextSpan(
                    text:
                        "${host.nome}, nacionalidade brasileiro(a), estado civil ${host.estadoCivil ?? '________'}, profissão ${host.profissao ?? '________'}, telefone ${host.telefone ?? '______________'}, portador do RG nº ${host.rg ?? '______________'} e inscrito no CPF sob o n° ${host.cpf ?? '______________'}, correio eletrônico ${host.email}, residente e domiciliado na $endHost, doravante denominada simplesmente Anfitrião.",
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 15),

            pw.Text(
              "Resolvem as Partes celebrar o presente Termo de Prestação de Serviços, doravante denominado simplesmente CONTRATO DE HOSPEDAGEM, na melhor forma de direito, que será regido pelas cláusulas e condições seguintes:",
              style: normalStyle,
              textAlign: pw.TextAlign.justify,
            ),
            pw.SizedBox(height: 20),

            // --- CLÁUSULA 1 ---
            pw.Text("1. DO OBJETO", style: boldStyle),
            pw.SizedBox(height: 5),
            pw.Text(
              "1.1 O presente termo tem por objeto a hospedagem temporária de Intercambista Voluntário ${ep.nome}, nacionalidade ${ep.nacionalidade ?? ep.pais ?? '___________'}, que estiver participando de projetos da AIESEC, nas dependências da residência do Anfitrião, situada na $endHost, durante o período compreendido entre $dataChegada e $dataPartida.",
              style: normalStyle,
              textAlign: pw.TextAlign.justify,
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              "1.2 - O Anfitrião confirma ser legítimo possuidor do imóvel acima referido.",
              style: normalStyle,
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              "1.3 - A AIESEC compromete-se a enviar, com antecedência mínima de 05 (cinco) dias os dados e informações do Intercambista que irá se hospedar na residência do Anfitrião, durante o período descrito no item 1.1, de modo que o mesmo possa ser identificado em sua chegada.",
              style: normalStyle,
              textAlign: pw.TextAlign.justify,
            ),
            pw.SizedBox(height: 15),

            // --- CLÁUSULA 2 ---
            pw.Text("2. DAS OBRIGAÇÕES DAS PARTES", style: boldStyle),
            pw.SizedBox(height: 5),
            pw.Text("2.1. O Anfitrião obriga-se:", style: boldStyle),
            pw.Text(
              "I. Promover todos os atos necessários para a execução do objeto deste Contrato;\nII. Preencher os formulários solicitados;\nIII. Responder a avaliação final;\nIV. Oferecer ao INTERCAMBISTA uma cama individual;\nV. Oferecer ao INTERCAMBISTA espaço para disposição de objetos pessoais;\nVI. Disponibilizar ao INTERCAMBISTA acesso a Banheiro adequado para realização de higiene pessoal e banho;\nVII. Disponibilizar local onde o INTERCAMBISTA possa fazer e preparar suas refeições;\nVIII. Disponibilizar local ao INTERCAMBISTA onde este possa lavar/secar suas roupas;\nIX. Liberar acesso às áreas comuns da residência, devendo indicar alguma área restrita, caso houver;\nX. Oferecer ao INTERCAMBISTA água tratada e energia elétrica.",
              style: normalStyle,
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              "Parágrafo 1° - É facultado ao Anfitrião fornecer alimentação ao INTERCAMBISTA.\nParágrafo 2° - Ao Anfitrião é dado o direito de efetuar vistoria ao quarto ocupado pelo INTERCAMBISTA, através de fotos ou presencialmente com sua supervisão ou com o seu consentimento, salvaguardando-se as situações que dizem respeito à verificação de irregularidades ou trabalhos de limpeza e manutenção das instalações ou equipamentos.\nParágrafo 3° - Compete ao Anfitrião receber e recepcionar o INTERCAMBISTA durante todo o período de hospedagem estabelecido no item 1.1.",
              style: normalStyle,
              textAlign: pw.TextAlign.justify,
            ),
            pw.SizedBox(height: 10),

            pw.Text("2.2. A AIESEC obriga-se:", style: boldStyle),
            pw.Text(
              "I. Fornecer ficha completa com os dados do Intercambista que irá hospedar-se na residência do Anfitrião, com antecedência de 05 dias da data inicial do período referido no item 1.1 deste instrumento;\nII. Acompanhar todos os atos relacionados com o Intercambista e o período de hospedagem, objeto deste contrato, executando as tarefas necessárias para solução de problemas, incluindo a transferência de hospedagem do Intercambista, caso este venha a causar problemas e danos ao Anfitrião.\nIII. A Elaborar Termo onde o INTERCAMBISTA se comprometa a conservar o imóvel objeto do presente contrato em perfeitas condições de higiene e limpeza, com todos os aparelhos, equipamentos, utensílios e objetos de decoração, instalados no imóvel em perfeito estado de conservação e funcionamento, para assim, restituí-los quando findo ou rescindido o presente contrato.\nIV. A realocar o INTERCAMBISTA caso este viole algum dos itens acordados em até 03 (três) dias da solicitação oficial pelo Anfitrião.\nV. Nos termos da Lei n° 13.709/2018 a AIESEC é obrigada a manter em sigilo todas as informações relacionadas o Anfitrião às quais A AIESEC terá acesso durante o período de vigência do contrato.",
              style: normalStyle,
              textAlign: pw.TextAlign.justify,
            ),
            pw.SizedBox(height: 10),

            pw.Text("Em particular, a AIESEC é obrigada a:", style: boldStyle),
            pw.Text(
              "a) Qualquer dado e/ou informação compartilhado com a AIESEC pelo Anfitrião deve ser tratado com base no princípio da confidencialidade, de modo que sejam armazenado com segurança e acessado apenas por pessoas autorizadas.\nb) Não compartilhar nenhuma informação e/ou dados pessoais do Anfitrião, a menos que haja explícito consentimento do titular.\nc) Tomar precauções para evitar a perda, corrupção ou uso fraudulento dos dados contidos no banco de dados e/ou qualquer fonte de dados proveniente da AIESEC.\nd) Abster-se de tomar e usar as informações e dados pessoais contidos no banco de dados e/ou qualquer fonte de dados da AIESEC para qualquer tipo de uso, seja pessoal ou não relacionado a qualquer atividade que não seja destinada ao cumprimento exclusivo do contrato.\ne) A AIESEC, após a utilização dos dados do Anfitrião ou tiver seu uso revogado, deve eliminá-los por completo.",
              style: normalStyle,
              textAlign: pw.TextAlign.justify,
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              "Parágrafo único: As cláusulas relativas à privacidade e armazenamento de dados nesta cláusula serão válidas mesmo após o término da vigência deste contrato.",
              style: normalStyle,
              textAlign: pw.TextAlign.justify,
            ),
            pw.SizedBox(height: 15),

            // --- CLÁUSULAS 3 E 4 ---
            pw.Text("3. DO PAGAMENTO", style: boldStyle),
            pw.SizedBox(height: 5),
            pw.Text(
              "3.1. Não haverá compensação financeira entre INTERCAMBISTAS, A AIESEC ou o Anfitrião pela hospedagem de acordo como objeto desse termo.",
              style: normalStyle,
            ),
            pw.SizedBox(height: 15),

            pw.Text("4. DA RESCISÃO", style: boldStyle),
            pw.SizedBox(height: 5),
            pw.Text(
              "4.1. O presente contrato poderá ser rescindido a qualquer momento, por qualquer das partes, mediante denúncia expressa e com antecedência mínima de 30 (trinta) dias. No entanto, deverão ser respeitadas as hospedagens que estiverem em andamento, até que as mesmas se findem.",
              style: normalStyle,
              textAlign: pw.TextAlign.justify,
            ),
            pw.SizedBox(height: 30),

            // --- FECHAMENTO E ASSINATURAS ---
            pw.Text(
              "E por estarem as partes de pleno acordo com o disposto neste instrumento particular, assinam-no em duas vias de igual teor e forma, na presença de duas testemunhas destinando-se uma via a cada parte interessada.",
              style: normalStyle,
              textAlign: pw.TextAlign.justify,
            ),
            pw.SizedBox(height: 20),

            pw.Text(dataAssinatura, style: normalStyle),
            pw.SizedBox(height: 40),

            // --- BLOCOS DE ASSINATURA ---
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Center(
                    child: _buildAssinaturaPrincipal(
                      "AIESEC EM ${comite.nomePodio.toUpperCase()}",
                    ),
                  ),
                ),
                pw.Expanded(
                  child: pw.Center(
                    child: _buildAssinaturaPrincipal("ANFITRIÃO\n${host.nome}"),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 40),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Center(
                    child: _buildTestemunha(
                      comite.testemunhas.isNotEmpty
                          ? comite.testemunhas[0]
                          : null,
                      "1",
                    ),
                  ),
                ),
                pw.Expanded(
                  child: pw.Center(
                    child: _buildTestemunha(
                      comite.testemunhas.length > 1
                          ? comite.testemunhas[1]
                          : null,
                      "2",
                    ),
                  ),
                ),
              ],
            ),
          ];
        },
      ),
    );

    // Exibe a tela de pré-visualização
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Termo_${ep.nome.replaceAll(" ", "_")}.pdf',
    );
  }

  // Widget gerador de linha de assinatura centralizada
  static pw.Widget _buildAssinaturaPrincipal(String texto) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Container(width: 200, height: 1, color: PdfColors.black),
        pw.SizedBox(height: 5),
        pw.Text(
          texto,
          style: const pw.TextStyle(fontSize: 10),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }

  // Widget gerador de bloco de testemunha com dados alinhados e sem "espremer"
  static pw.Widget _buildTestemunha(Testemunha? t, String numero) {
    return pw.Column(
      crossAxisAlignment:
          pw.CrossAxisAlignment.start, // Mantém o texto alinhado com a linha
      children: [
        pw.Container(width: 200, height: 1, color: PdfColors.black),
        pw.SizedBox(height: 5),
        pw.Text(
          "TESTEMUNHA $numero:",
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          "Nome: ${t?.nomeCompleto ?? '__________________________'}",
          style: const pw.TextStyle(fontSize: 10),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          "CPF: ${t?.cpf ?? '__________________________'}",
          style: const pw.TextStyle(fontSize: 10),
        ),
        pw.SizedBox(height: 2),
        // O uso do Wrap garante que se os dados do RG forem grandes, quebram linha naturalmente sem comprimir as letras
        pw.Wrap(
          children: [
            pw.Text(
              "RG: ${t?.rg ?? '______________'}   ",
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.Text(
              "Órgão Emissor: ${t?.orgaoEmissor ?? '____'}",
              style: const pw.TextStyle(fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }
}
