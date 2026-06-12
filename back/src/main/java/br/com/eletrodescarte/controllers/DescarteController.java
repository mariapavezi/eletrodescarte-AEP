package br.com.eletrodescarte.controllers;

import br.com.eletrodescarte.models.Descarte;
import br.com.eletrodescarte.repositories.DescarteRepository;
import br.com.eletrodescarte.services.DescarteService;
import br.com.eletrodescarte.services.IndicadorService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/descartes")
public class DescarteController {

    @Autowired
    private DescarteRepository descarteRepository;

    @Autowired
    private DescarteService descarteService;

    @Autowired
    private IndicadorService indicadorService;

    @PostMapping
    public ResponseEntity<Descarte> salvarDescarte(@RequestBody Descarte descarte) {
        try {
            Descarte novoDescarte = descarteService.salvarDescarte(descarte);
            return ResponseEntity.status(HttpStatus.CREATED).body(novoDescarte);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @GetMapping("/usuario/{usuarioId}/indicadores")
    public ResponseEntity<IndicadorService.IndicadoresDTO> getIndicadores(@PathVariable Long usuarioId) {
        IndicadorService.IndicadoresDTO indicadores = indicadorService.calcularIndicadoresPorUsuario(usuarioId);
        return ResponseEntity.ok(indicadores);
    }

    @GetMapping("/usuario/{usuarioId}")
    public ResponseEntity<List<Descarte>> listarPorUsuario(@PathVariable Long usuarioId) {
        return ResponseEntity.ok(
                descarteRepository.findByUsuario_IdUsuarioOrderByDescartadoEmDesc(usuarioId)
        );
    }
}