package br.com.eletrodescarte.services;

import br.com.eletrodescarte.models.Descarte;
import br.com.eletrodescarte.models.DescarteItem;
import br.com.eletrodescarte.models.FatoresMateriais;
import br.com.eletrodescarte.models.Usuario;
import br.com.eletrodescarte.repositories.DescarteRepository;
import br.com.eletrodescarte.repositories.FatoresMateriaisRepository;
import br.com.eletrodescarte.repositories.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class IndicadorService {

    @Autowired
    private DescarteRepository descarteRepository;

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private FatoresMateriaisRepository fatoresRepository;

    public record IndicadoresDTO(
            BigDecimal totalKgDescartado,
            BigDecimal totalCo2Evitado,
            BigDecimal totalAguaEconomizada
    ) {}

    /**
     * Calcula os indicadores de impacto ambiental do usuário.
     * Implementado com O(1) de busca em memória para FatoresMateriais, 
     * evitando múltiplas consultas ao banco durante o processamento.
     */
    public IndicadoresDTO calcularIndicadoresPorUsuario(Long idUsuario) {

        Usuario usuario = usuarioRepository.findById(idUsuario)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));

        List<Descarte> descartes = descarteRepository.findByUsuario(usuario);

        // O(N) para carregar todos os fatores em um HashMap, garantindo busca O(1) posterior
        Map<Long, FatoresMateriais> cacheFatores = fatoresRepository.findAll().stream()
                .collect(Collectors.toMap(FatoresMateriais::getIdMaterial, f -> f));

        BigDecimal totalKg = BigDecimal.ZERO;
        BigDecimal totalCo2 = BigDecimal.ZERO;
        BigDecimal totalAgua = BigDecimal.ZERO;

        for (Descarte descarte : descartes) {
            if (descarte.getItens() == null) continue;

            for (DescarteItem item : descarte.getItens()) {
                BigDecimal quantidadeKg = item.getQuantidadeKg();
                totalKg = totalKg.add(quantidadeKg);

                // Busca O(1) no HashMap
                FatoresMateriais fatores = cacheFatores.get(item.getMaterial().getIdMaterial());

                if (fatores != null) {
                    BigDecimal co2Evitado = quantidadeKg.multiply(fatores.getCo2eKgPorKg());
                    totalCo2 = totalCo2.add(co2Evitado);

                    BigDecimal aguaEconomizada = quantidadeKg.multiply(fatores.getAguaLitrosPorKg());
                    totalAgua = totalAgua.add(aguaEconomizada);
                }
            }
        }

        return new IndicadoresDTO(totalKg, totalCo2, totalAgua);
    }
}
