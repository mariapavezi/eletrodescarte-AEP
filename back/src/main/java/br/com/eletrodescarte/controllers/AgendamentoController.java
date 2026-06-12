package br.com.eletrodescarte.controllers;

import br.com.eletrodescarte.controllers.dto.AgendamentoRequestDTO;
import br.com.eletrodescarte.models.AgendamentoDescarte;
import br.com.eletrodescarte.services.AgendamentoService;
import org.springframework.web.bind.annotation.*;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

@RestController
@RequestMapping("/api/agendamentos")
@RequiredArgsConstructor
public class AgendamentoController {

    private final AgendamentoService agendamentoService;

    @PostMapping
    public ResponseEntity<AgendamentoDescarte> criar(@Valid @RequestBody AgendamentoRequestDTO dto) {
        return new ResponseEntity<>(agendamentoService.criarAgendamento(dto), HttpStatus.CREATED);
    }

    @PutMapping("/{id}/concluir")
    public ResponseEntity<AgendamentoDescarte> concluir(@PathVariable Long id) {
        return ResponseEntity.ok(agendamentoService.concluirDescarte(id));
    }
}
