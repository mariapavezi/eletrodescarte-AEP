package br.com.eletrodescarte.config;

import br.com.eletrodescarte.enums.PapelUsuario;
import br.com.eletrodescarte.enums.TipoOrganizacao;
import br.com.eletrodescarte.models.*;
import br.com.eletrodescarte.repositories.*;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;

@Component
public class DataSeeder implements CommandLineRunner {

    private final CidadeRepository cidadeRepository;
    private final MaterialRepository materialRepository;
    private final OrganizacaoRepository organizacaoRepository;
    private final PontoColetaRepository pontoColetaRepository;
    private final FatoresMateriaisRepository fatoresRepository;
    private final UsuarioRepository usuarioRepository;
    private final PasswordEncoder passwordEncoder;

    public DataSeeder(
            CidadeRepository cidadeRepository,
            MaterialRepository materialRepository,
            OrganizacaoRepository organizacaoRepository,
            PontoColetaRepository pontoColetaRepository,
            FatoresMateriaisRepository fatoresRepository,
            UsuarioRepository usuarioRepository,
            PasswordEncoder passwordEncoder
    ) {
        this.cidadeRepository = cidadeRepository;
        this.materialRepository = materialRepository;
        this.organizacaoRepository = organizacaoRepository;
        this.pontoColetaRepository = pontoColetaRepository;
        this.fatoresRepository = fatoresRepository;
        this.usuarioRepository = usuarioRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    @Transactional
    public void run(String... args) {
        Cidade maringa = findOrCreateCidade("Maringá", "PR");
        Cidade curitiba = findOrCreateCidade("Curitiba", "PR");
        Cidade saoPaulo = findOrCreateCidade("São Paulo", "SP");

        Organizacao prefMaringa = findOrCreateOrganizacao(
                "Prefeitura de Maringá", TipoOrganizacao.publica, "https://maringa.pr.gov.br"
        );
        Organizacao coletaCerta = findOrCreateOrganizacao(
                "Coleta Certa LTDA", TipoOrganizacao.privada, "https://coletacerta.com"
        );
        Organizacao reciclaTech = findOrCreateOrganizacao(
                "ONG Recicla Tech", TipoOrganizacao.ong, "https://reciclatech.org"
        );

        Material pilhas = findOrCreateMaterial(
                "Pilhas e Baterias", "kg", "Pilhas comuns, baterias de celular, notebook.",
                "4.500000", "50.00", "0.850000"
        );
        Material celulares = findOrCreateMaterial(
                "Celulares e Tablets", "un", "Aparelhos inteiros, mesmo quebrados.",
                "12.000000", "250.00", "0.600000"
        );
        Material computadores = findOrCreateMaterial(
                "Computadores", "un", "Desktops, notebooks, CPUs, monitores.",
                "8.000000", "150.00", "0.400000"
        );
        Material lampadas = findOrCreateMaterial(
                "Lâmpadas Fluorescentes", "un", "Lâmpadas que contêm mercúrio.",
                "2.000000", "10.00", "1.500000"
        );

        if (pontoColetaRepository.count() == 0) {
            seedPontosIniciais(maringa, curitiba, saoPaulo, prefMaringa, coletaCerta, reciclaTech,
                    pilhas, celulares, computadores, lampadas);
        } else {
            seedPontosMaringa(maringa, prefMaringa, reciclaTech, pilhas, celulares, computadores, lampadas);
        }

        if (usuarioRepository.count() == 0) {
            Usuario user = new Usuario();
            user.setNomeCompleto("Cidadão Exemplo");
            user.setEmail("cidadao@exemplo.com");
            user.setHashSenha(passwordEncoder.encode("senha"));
            user.setCidade(maringa);
            user.setPapel(PapelUsuario.CIDADAO);
            usuarioRepository.save(user);
        }
    }

    private void seedPontosIniciais(
            Cidade maringa,
            Cidade curitiba,
            Cidade saoPaulo,
            Organizacao prefMaringa,
            Organizacao coletaCerta,
            Organizacao reciclaTech,
            Material pilhas,
            Material celulares,
            Material computadores,
            Material lampadas
    ) {
        seedPontosMaringa(maringa, prefMaringa, reciclaTech, pilhas, celulares, computadores, lampadas);

        savePontoIfMissing(
                "Recicla Tech Vila Mada",
                "Av. Sete de Setembro, 2000 - Centro, Curitiba - PR",
                -25.4338, -49.2730,
                "(41) 91234-5678", "ajuda@reciclatech.org",
                curitiba, reciclaTech,
                List.of(pilhas, celulares, computadores, lampadas),
                new int[]{2, 4}, LocalTime.of(13, 0), LocalTime.of(17, 0)
        );

        savePontoIfMissing(
                "Ponto Verde Jardins",
                "Rua Augusta, 1500 - Consolação, São Paulo - SP",
                -23.5558, -46.6620,
                "(11) 98765-4321", "contato@coletacerta.com",
                saoPaulo, coletaCerta,
                List.of(pilhas, celulares, computadores),
                1, 5, LocalTime.of(9, 0), LocalTime.of(18, 0)
        );
    }

    private void seedPontosMaringa(
            Cidade maringa,
            Organizacao prefMaringa,
            Organizacao reciclaTech,
            Material pilhas,
            Material celulares,
            Material computadores,
            Material lampadas
    ) {
        savePontoIfMissing(
                "EcoCentro Pinheiros - Paço Maringá",
                "Av. XV de Novembro, 701 - Zona 01, Maringá - PR",
                -23.4253, -51.9386,
                "(44) 3221-1234", "coleta@maringa.pr.gov.br",
                maringa, prefMaringa,
                List.of(pilhas, celulares, lampadas),
                1, 5, LocalTime.of(8, 0), LocalTime.of(17, 0)
        );

        savePontoIfMissing(
                "EcoPonto Parque do Ingá",
                "Av. Doutor Gastão Vidigal, 634 - Parque do Ingá, Maringá - PR",
                -23.4128, -51.9236,
                "(44) 3221-5678", "inga@maringa.pr.gov.br",
                maringa, prefMaringa,
                List.of(pilhas, celulares, lampadas, computadores),
                1, 6, LocalTime.of(9, 0), LocalTime.of(16, 0)
        );

        savePontoIfMissing(
                "Coleta Eletrônicos Zona 7",
                "Av. Colombo, 4545 - Zona 7, Maringá - PR",
                -23.4562, -51.9078,
                "(44) 3031-8899", "zona7@maringa.pr.gov.br",
                maringa, prefMaringa,
                List.of(pilhas, celulares, computadores),
                1, 5, LocalTime.of(8, 30), LocalTime.of(17, 30)
        );

        savePontoIfMissing(
                "Ponto UEM - Campus Universitário",
                "Av. Mandacaru, 1550 - Jardim Alvorada, Maringá - PR",
                -23.4205, -51.9487,
                "(44) 3011-4500", "sustentabilidade@uem.br",
                maringa, reciclaTech,
                List.of(pilhas, celulares, computadores, lampadas),
                new int[]{1, 2, 3, 4, 5}, LocalTime.of(10, 0), LocalTime.of(18, 0)
        );

        savePontoIfMissing(
                "EcoPonto Catuaí",
                "Av. Colombo, 9161 - Jardim Nazareth, Maringá - PR",
                -23.4516, -51.9884,
                "(44) 3026-2000", "ecoponto@catuai.com.br",
                maringa, reciclaTech,
                List.of(pilhas, celulares, lampadas),
                new int[]{1, 2, 3, 4, 5, 6}, LocalTime.of(10, 0), LocalTime.of(20, 0)
        );
    }

    private void savePontoIfMissing(
            String nome,
            String endereco,
            double latitude,
            double longitude,
            String telefone,
            String email,
            Cidade cidade,
            Organizacao organizacao,
            List<Material> materiais,
            int diaInicio,
            int diaFim,
            LocalTime abreAs,
            LocalTime fechaAs
    ) {
        if (pontoJaExiste(nome, cidade)) {
            return;
        }
        savePonto(nome, endereco, latitude, longitude, telefone, email, cidade, organizacao,
                materiais, diaInicio, diaFim, abreAs, fechaAs);
    }

    private void savePontoIfMissing(
            String nome,
            String endereco,
            double latitude,
            double longitude,
            String telefone,
            String email,
            Cidade cidade,
            Organizacao organizacao,
            List<Material> materiais,
            int[] dias,
            LocalTime abreAs,
            LocalTime fechaAs
    ) {
        if (pontoJaExiste(nome, cidade)) {
            return;
        }
        savePonto(nome, endereco, latitude, longitude, telefone, email, cidade, organizacao,
                materiais, dias, abreAs, fechaAs);
    }

    private boolean pontoJaExiste(String nome, Cidade cidade) {
        return pontoColetaRepository.findAll().stream()
                .anyMatch(p -> p.getNome().equals(nome)
                        && p.getCidade().getIdCidade().equals(cidade.getIdCidade()));
    }

    private Cidade findOrCreateCidade(String nome, String uf) {
        return cidadeRepository.findAll().stream()
                .filter(c -> c.getNome().equals(nome))
                .findFirst()
                .orElseGet(() -> {
                    Cidade cidade = new Cidade();
                    cidade.setNome(nome);
                    cidade.setUf(uf);
                    return cidadeRepository.save(cidade);
                });
    }

    private Organizacao findOrCreateOrganizacao(String nome, TipoOrganizacao tipo, String site) {
        return organizacaoRepository.findAll().stream()
                .filter(o -> o.getNome().equals(nome))
                .findFirst()
                .orElseGet(() -> {
                    Organizacao organizacao = new Organizacao();
                    organizacao.setNome(nome);
                    organizacao.setTipo(tipo);
                    organizacao.setSite(site);
                    return organizacaoRepository.save(organizacao);
                });
    }

    private Material findOrCreateMaterial(
            String nome,
            String unidade,
            String descricao,
            String co2,
            String agua,
            String toxicidade
    ) {
        Material material = materialRepository.findAll().stream()
                .filter(m -> m.getNome().equals(nome))
                .findFirst()
                .orElseGet(() -> {
                    Material novo = new Material();
                    novo.setNome(nome);
                    novo.setUnidade(unidade);
                    novo.setDescricao(descricao);
                    return materialRepository.save(novo);
                });

        if (fatoresRepository.findById(material.getIdMaterial()).isEmpty()) {
            FatoresMateriais fatores = new FatoresMateriais();
            fatores.setMaterial(materialRepository.getReferenceById(material.getIdMaterial()));
            fatores.setCo2eKgPorKg(new BigDecimal(co2));
            fatores.setAguaLitrosPorKg(new BigDecimal(agua));
            fatores.setIndiceToxicidadePorKg(new BigDecimal(toxicidade));
            fatoresRepository.save(fatores);
        }

        return materialRepository.getReferenceById(material.getIdMaterial());
    }

    private void savePonto(
            String nome,
            String endereco,
            double latitude,
            double longitude,
            String telefone,
            String email,
            Cidade cidade,
            Organizacao organizacao,
            List<Material> materiais,
            int diaInicio,
            int diaFim,
            LocalTime abreAs,
            LocalTime fechaAs
    ) {
        PontoColeta ponto = new PontoColeta();
        ponto.setNome(nome);
        ponto.setEndereco(endereco);
        ponto.setLatitude(latitude);
        ponto.setLongitude(longitude);
        ponto.setTelefone(telefone);
        ponto.setEmail(email);
        ponto.setAtivo(true);
        ponto.setCidade(cidade);
        ponto.setOrganizacao(organizacao);
        ponto.setMateriaisAceitos(new HashSet<>(materiais));

        List<HorarioFuncionamento> horarios = new ArrayList<>();
        for (int dia = diaInicio; dia <= diaFim; dia++) {
            HorarioFuncionamento horario = new HorarioFuncionamento();
            horario.setDiaSemana(dia);
            horario.setAbreAs(abreAs);
            horario.setFechaAs(fechaAs);
            horario.setPontoColeta(ponto);
            horarios.add(horario);
        }
        ponto.setHorarios(horarios);
        pontoColetaRepository.save(ponto);
    }

    private void savePonto(
            String nome,
            String endereco,
            double latitude,
            double longitude,
            String telefone,
            String email,
            Cidade cidade,
            Organizacao organizacao,
            List<Material> materiais,
            int[] dias,
            LocalTime abreAs,
            LocalTime fechaAs
    ) {
        PontoColeta ponto = new PontoColeta();
        ponto.setNome(nome);
        ponto.setEndereco(endereco);
        ponto.setLatitude(latitude);
        ponto.setLongitude(longitude);
        ponto.setTelefone(telefone);
        ponto.setEmail(email);
        ponto.setAtivo(true);
        ponto.setCidade(cidade);
        ponto.setOrganizacao(organizacao);
        ponto.setMateriaisAceitos(new HashSet<>(materiais));

        List<HorarioFuncionamento> horarios = new ArrayList<>();
        for (int dia : dias) {
            HorarioFuncionamento horario = new HorarioFuncionamento();
            horario.setDiaSemana(dia);
            horario.setAbreAs(abreAs);
            horario.setFechaAs(fechaAs);
            horario.setPontoColeta(ponto);
            horarios.add(horario);
        }
        ponto.setHorarios(horarios);
        pontoColetaRepository.save(ponto);
    }
}
