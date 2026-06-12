package br.com.eletrodescarte.services;

import br.com.eletrodescarte.models.*;
import br.com.eletrodescarte.repositories.DescarteRepository;
import br.com.eletrodescarte.repositories.FatoresMateriaisRepository;
import br.com.eletrodescarte.repositories.UsuarioRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
public class IndicadorServiceTest {

    @Mock
    private DescarteRepository descarteRepository;

    @Mock
    private UsuarioRepository usuarioRepository;

    @Mock
    private FatoresMateriaisRepository fatoresRepository;

    @InjectMocks
    private IndicadorService indicadorService;

    private Usuario usuario;
    private Material pilhas;
    private Material notebooks;
    private FatoresMateriais fatorPilhas;
    private FatoresMateriais fatorNotebooks;

    @BeforeEach
    void setUp() {
        usuario = new Usuario();
        usuario.setIdUsuario(1L);
        usuario.setNomeCompleto("João Silva");

        pilhas = new Material();
        pilhas.setIdMaterial(1L);
        pilhas.setNome("Pilhas");

        notebooks = new Material();
        notebooks.setIdMaterial(2L);
        notebooks.setNome("Notebooks");

        fatorPilhas = new FatoresMateriais();
        fatorPilhas.setIdMaterial(1L);
        fatorPilhas.setCo2eKgPorKg(new BigDecimal("4.5"));
        fatorPilhas.setAguaLitrosPorKg(new BigDecimal("50.0"));

        fatorNotebooks = new FatoresMateriais();
        fatorNotebooks.setIdMaterial(2L);
        fatorNotebooks.setCo2eKgPorKg(new BigDecimal("8.0"));
        fatorNotebooks.setAguaLitrosPorKg(new BigDecimal("150.0"));
    }

    @Test
    @DisplayName("Deve calcular indicadores corretamente com múltiplos descartes e materiais")
    void deveCalcularIndicadoresCorretamente() {
        DescarteItem item1 = new DescarteItem();
        item1.setMaterial(pilhas);
        item1.setQuantidadeKg(new BigDecimal("2.0"));

        Descarte descarte1 = new Descarte();
        descarte1.setItens(List.of(item1));

        DescarteItem item2 = new DescarteItem();
        item2.setMaterial(notebooks);
        item2.setQuantidadeKg(new BigDecimal("5.0"));

        Descarte descarte2 = new Descarte();
        descarte2.setItens(List.of(item2));

        when(usuarioRepository.findById(1L)).thenReturn(Optional.of(usuario));
        when(descarteRepository.findByUsuario(usuario)).thenReturn(Arrays.asList(descarte1, descarte2));
        when(fatoresRepository.findAll()).thenReturn(Arrays.asList(fatorPilhas, fatorNotebooks));

        IndicadorService.IndicadoresDTO resultado = indicadorService.calcularIndicadoresPorUsuario(1L);

        assertEquals(new BigDecimal("7.0"), resultado.totalKgDescartado());
        assertEquals(new BigDecimal("49.00"), resultado.totalCo2Evitado());
        assertEquals(new BigDecimal("850.00"), resultado.totalAguaEconomizada());
    }
}
