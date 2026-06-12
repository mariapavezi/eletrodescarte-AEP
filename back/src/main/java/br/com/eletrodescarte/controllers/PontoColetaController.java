package br.com.eletrodescarte.controllers;

import br.com.eletrodescarte.models.PontoColeta;
import br.com.eletrodescarte.services.PontoColetaService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@RestController
@RequestMapping("/api/pontos-coleta")
public class PontoColetaController {

    @Autowired
    private PontoColetaService pontoColetaService;

    @GetMapping
    @Transactional(readOnly = true)
    public ResponseEntity<List<PontoColeta>> listarPontos() {
        List<PontoColeta> pontos = pontoColetaService.listarPontosAtivos();

        return ResponseEntity.ok(pontos);
    }
}