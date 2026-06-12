package br.com.eletrodescarte;

import br.com.eletrodescarte.models.*;
import br.com.eletrodescarte.repositories.*;
import br.com.eletrodescarte.enums.PapelUsuario;
import br.com.eletrodescarte.enums.TipoOrganizacao;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.math.BigDecimal;
import java.time.LocalTime;
import java.util.Arrays;
import java.util.HashSet;
import java.util.ArrayList;
import java.util.List;

@SpringBootApplication
public class EletrodescarteApplication {

    public static void main(String[] args) {
        SpringApplication.run(EletrodescarteApplication.class, args);
    }

    @Bean
    public CommandLineRunner seedData(
            CidadeRepository cidadeRepository,
            MaterialRepository materialRepository,
            OrganizacaoRepository organizacaoRepository,
            PontoColetaRepository pontoColetaRepository,
            FatoresMateriaisRepository fatoresRepository,
            UsuarioRepository usuarioRepository,
            PasswordEncoder passwordEncoder
    ) {
        return args -> {
            // 1. Seed Cidades
            Cidade maringa = cidadeRepository.findAll().stream().filter(c -> c.getNome().equals("Maringá")).findFirst().orElse(null);
            if (maringa == null) {
                maringa = new Cidade();
                maringa.setNome("Maringá");
                maringa.setUf("PR");
                maringa = cidadeRepository.save(maringa);
            }

            Cidade curitiba = cidadeRepository.findAll().stream().filter(c -> c.getNome().equals("Curitiba")).findFirst().orElse(null);
            if (curitiba == null) {
                curitiba = new Cidade();
                curitiba.setNome("Curitiba");
                curitiba.setUf("PR");
                curitiba = cidadeRepository.save(curitiba);
            }

            Cidade saoPaulo = cidadeRepository.findAll().stream().filter(c -> c.getNome().equals("São Paulo")).findFirst().orElse(null);
            if (saoPaulo == null) {
                saoPaulo = new Cidade();
                saoPaulo.setNome("São Paulo");
                saoPaulo.setUf("SP");
                saoPaulo = cidadeRepository.save(saoPaulo);
            }

            // 2. Seed Organizacoes
            Organizacao prefMaringa = organizacaoRepository.findAll().stream().filter(o -> o.getNome().contains("Prefeitura")).findFirst().orElse(null);
            if (prefMaringa == null) {
                prefMaringa = new Organizacao();
                prefMaringa.setNome("Prefeitura de Maringá");
                prefMaringa.setTipo(TipoOrganizacao.publica);
                prefMaringa.setSite("https://maringa.pr.gov.br");
                prefMaringa = organizacaoRepository.save(prefMaringa);
            }

            Organizacao coletaCerta = organizacaoRepository.findAll().stream().filter(o -> o.getNome().contains("Coleta")).findFirst().orElse(null);
            if (coletaCerta == null) {
                coletaCerta = new Organizacao();
                coletaCerta.setNome("Coleta Certa LTDA");
                coletaCerta.setTipo(TipoOrganizacao.privada);
                coletaCerta.setSite("https://coletacerta.com");
                coletaCerta = organizacaoRepository.save(coletaCerta);
            }

            Organizacao reciclaTech = organizacaoRepository.findAll().stream().filter(o -> o.getNome().contains("Recicla")).findFirst().orElse(null);
            if (reciclaTech == null) {
                reciclaTech = new Organizacao();
                reciclaTech.setNome("ONG Recicla Tech");
                reciclaTech.setTipo(TipoOrganizacao.ong);
                reciclaTech.setSite("https://reciclatech.org");
                reciclaTech = organizacaoRepository.save(reciclaTech);
            }

            // 3. Seed Materiais & Fatores
            Material pilhas = materialRepository.findAll().stream().filter(m -> m.getNome().contains("Pilhas")).findFirst().orElse(null);
            if (pilhas == null) {
                pilhas = new Material();
                pilhas.setNome("Pilhas e Baterias");
                pilhas.setUnidade("kg");
                pilhas.setDescricao("Pilhas comuns, baterias de celular, notebook.");
                
                FatoresMateriais f = new FatoresMateriais();
                f.setMaterial(pilhas);
                f.setCo2eKgPorKg(new BigDecimal("4.500000"));
                f.setAguaLitrosPorKg(new BigDecimal("50.00"));
                f.setIndiceToxicidadePorKg(new BigDecimal("0.850000"));
                
                pilhas.setFatoresMateriais(f);
                pilhas = materialRepository.save(pilhas);
            }

            Material celulares = materialRepository.findAll().stream().filter(m -> m.getNome().contains("Celulares")).findFirst().orElse(null);
            if (celulares == null) {
                celulares = new Material();
                celulares.setNome("Celulares e Tablets");
                celulares.setUnidade("un");
                celulares.setDescricao("Aparelhos inteiros, mesmo quebrados.");
                
                FatoresMateriais f = new FatoresMateriais();
                f.setMaterial(celulares);
                f.setCo2eKgPorKg(new BigDecimal("12.000000"));
                f.setAguaLitrosPorKg(new BigDecimal("250.00"));
                f.setIndiceToxicidadePorKg(new BigDecimal("0.600000"));
                
                celulares.setFatoresMateriais(f);
                celulares = materialRepository.save(celulares);
            }

            Material computadores = materialRepository.findAll().stream().filter(m -> m.getNome().contains("Computadores")).findFirst().orElse(null);
            if (computadores == null) {
                computadores = new Material();
                computadores.setNome("Computadores");
                computadores.setUnidade("un");
                computadores.setDescricao("Desktops, notebooks, CPUs, monitores.");
                
                FatoresMateriais f = new FatoresMateriais();
                f.setMaterial(computadores);
                f.setCo2eKgPorKg(new BigDecimal("8.000000"));
                f.setAguaLitrosPorKg(new BigDecimal("150.00"));
                f.setIndiceToxicidadePorKg(new BigDecimal("0.400000"));
                
                computadores.setFatoresMateriais(f);
                computadores = materialRepository.save(computadores);
            }

            Material lampadas = materialRepository.findAll().stream().filter(m -> m.getNome().contains("Lâmpadas")).findFirst().orElse(null);
            if (lampadas == null) {
                lampadas = new Material();
                lampadas.setNome("Lâmpadas Fluorescentes");
                lampadas.setUnidade("un");
                lampadas.setDescricao("Lâmpadas que contêm mercúrio.");
                
                FatoresMateriais f = new FatoresMateriais();
                f.setMaterial(lampadas);
                f.setCo2eKgPorKg(new BigDecimal("2.000000"));
                f.setAguaLitrosPorKg(new BigDecimal("10.00"));
                f.setIndiceToxicidadePorKg(new BigDecimal("1.500000"));
                
                lampadas.setFatoresMateriais(f);
                lampadas = materialRepository.save(lampadas);
            }

            // 4. Seed PontosColeta
            if (pontoColetaRepository.count() == 0 && maringa != null && curitiba != null && saoPaulo != null) {
                // Point 1: Paço Municipal de Maringá
                PontoColeta p1 = new PontoColeta();
                p1.setNome("EcoCentro Pinheiros - Paço Maringá");
                p1.setEndereco("Av. XV de Novembro, 701 - Zona 01, Maringá - PR");
                p1.setLatitude(-23.4253);
                p1.setLongitude(-51.9386);
                p1.setTelefone("(44) 3221-1234");
                p1.setEmail("coleta@maringa.pr.gov.br");
                p1.setAtivo(true);
                p1.setCidade(maringa);
                p1.setOrganizacao(prefMaringa);
                p1.setMateriaisAceitos(new HashSet<>(Arrays.asList(pilhas, celulares, lampadas)));

                // Add schedules
                List<HorarioFuncionamento> h1 = new ArrayList<>();
                for (int d = 1; d <= 5; d++) {
                    HorarioFuncionamento h = new HorarioFuncionamento();
                    h.setDiaSemana(d);
                    h.setAbreAs(LocalTime.of(8, 0));
                    h.setFechaAs(LocalTime.of(17, 0));
                    h.setPontoColeta(p1);
                    h1.add(h);
                }
                p1.setHorarios(h1);
                pontoColetaRepository.save(p1);

                // Point 2: Recicla Tech Vila Mada
                PontoColeta p2 = new PontoColeta();
                p2.setNome("Recicla Tech Vila Mada");
                p2.setEndereco("Av. Sete de Setembro, 2000 - Centro, Curitiba - PR");
                p2.setLatitude(-25.4338);
                p2.setLongitude(-49.2730);
                p2.setTelefone("(41) 91234-5678");
                p2.setEmail("ajuda@reciclatech.org");
                p2.setAtivo(true);
                p2.setCidade(curitiba);
                p2.setOrganizacao(reciclaTech);
                p2.setMateriaisAceitos(new HashSet<>(Arrays.asList(pilhas, celulares, computadores, lampadas)));

                List<HorarioFuncionamento> h2 = new ArrayList<>();
                for (int d : new int[]{2, 4}) {
                    HorarioFuncionamento h = new HorarioFuncionamento();
                    h.setDiaSemana(d);
                    h.setAbreAs(LocalTime.of(13, 0));
                    h.setFechaAs(LocalTime.of(17, 0));
                    h.setPontoColeta(p2);
                    h2.add(h);
                }
                p2.setHorarios(h2);
                pontoColetaRepository.save(p2);

                // Point 3: Ponto Verde Jardins
                PontoColeta p3 = new PontoColeta();
                p3.setNome("Ponto Verde Jardins");
                p3.setEndereco("Rua Augusta, 1500 - Consolação, São Paulo - SP");
                p3.setLatitude(-23.5558);
                p3.setLongitude(-46.6620);
                p3.setTelefone("(11) 98765-4321");
                p3.setEmail("contato@coletacerta.com");
                p3.setAtivo(true);
                p3.setCidade(saoPaulo);
                p3.setOrganizacao(coletaCerta);
                p3.setMateriaisAceitos(new HashSet<>(Arrays.asList(pilhas, celulares, computadores)));

                List<HorarioFuncionamento> h3 = new ArrayList<>();
                for (int d = 1; d <= 5; d++) {
                    HorarioFuncionamento h = new HorarioFuncionamento();
                    h.setDiaSemana(d);
                    h.setAbreAs(LocalTime.of(9, 0));
                    h.setFechaAs(LocalTime.of(18, 0));
                    h.setPontoColeta(p3);
                    h3.add(h);
                }
                p3.setHorarios(h3);
                pontoColetaRepository.save(p3);
            }

            // 5. Seed default test user (cidadao@exemplo.com / senha)
            if (usuarioRepository.count() == 0 && maringa != null) {
                Usuario user = new Usuario();
                user.setNomeCompleto("Cidadão Exemplo");
                user.setEmail("cidadao@exemplo.com");
                user.setHashSenha(passwordEncoder.encode("senha"));
                user.setCidade(maringa);
                user.setPapel(PapelUsuario.CIDADAO);
                usuarioRepository.save(user);
            }
        };
    }
}
