package br.com.eletrodescarte.services;

import br.com.eletrodescarte.controllers.dto.AgendamentoRequestDTO;
import br.com.eletrodescarte.models.*;
import br.com.eletrodescarte.enums.*;
import br.com.eletrodescarte.exception.ResourceNotFoundException;
import br.com.eletrodescarte.repositories.AgendamentoDescarteRepository;
import br.com.eletrodescarte.repositories.PontoColetaRepository;
import br.com.eletrodescarte.repositories.UsuarioRepository;
import br.com.eletrodescarte.services.observer.DescarteConcluidoEvent;
import br.com.eletrodescarte.services.strategy.CalculoPontuacaoStrategy;
import lombok.RequiredArgsConstructor;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AgendamentoService {

    private final AgendamentoDescarteRepository agendamentoRepository;
    private final UsuarioRepository usuarioRepository;
    private final PontoColetaRepository pontoColetaRepository;
    private final ApplicationEventPublisher eventPublisher;
    private final List<CalculoPontuacaoStrategy> strategies;

    @Transactional
    public AgendamentoDescarte criarAgendamento(AgendamentoRequestDTO dto) {
        Usuario usuario = usuarioRepository.findById(dto.getUsuarioId())
                .orElseThrow(() -> new ResourceNotFoundException("Usuário não encontrado"));

        PontoColeta pontoColeta = pontoColetaRepository.findById(dto.getPontoColetaId())
                .orElseThrow(() -> new ResourceNotFoundException("Ponto de coleta não encontrado"));

        AgendamentoDescarte agendamento = AgendamentoDescarte.builder()
                .usuario(usuario)
                .pontoColeta(pontoColeta)
                .status(StatusAgendamento.PENDENTE)
                .build();

        List<ItemDescarte> itens = dto.getItens().stream().map(itemDto -> 
                ItemDescarte.builder()
                        .tipoEletronico(itemDto.getTipoEletronico())
                        .pesoKg(itemDto.getPesoKg())
                        .agendamento(agendamento)
                        .build()
        ).collect(Collectors.toList());

        agendamento.setItens(itens);

        return agendamentoRepository.save(agendamento);
    }

    public AgendamentoDescarte buscarPorId(Long id) {
        return agendamentoRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Agendamento não encontrado"));
    }

    @Transactional
    public AgendamentoDescarte concluirDescarte(Long id) {
        AgendamentoDescarte agendamento = buscarPorId(id);

        if (agendamento.getStatus() != StatusAgendamento.PENDENTE) {
            throw new IllegalStateException("Apenas agendamentos PENDENTES podem ser concluídos");
        }

        int totalPontos = 0;
        Map<TipoEletronico, CalculoPontuacaoStrategy> strategyMap = strategies.stream()
                .collect(Collectors.toMap(CalculoPontuacaoStrategy::getTipo, Function.identity()));

        for (ItemDescarte item : agendamento.getItens()) {
            CalculoPontuacaoStrategy strategy = strategyMap.get(item.getTipoEletronico());
            if (strategy != null) {
                int pontos = strategy.calcularPontos(item.getPesoKg());
                item.setPontosGanhos(pontos);
                item.setPegadaCarbonoEvitada(strategy.calcularCO2(item.getPesoKg()));
                totalPontos += pontos;
            }
        }

        agendamento.setStatus(StatusAgendamento.CONCLUIDO);
        AgendamentoDescarte salvo = agendamentoRepository.save(agendamento);

        eventPublisher.publishEvent(new DescarteConcluidoEvent(this, salvo.getUsuario().getIdUsuario(), totalPontos));

        return salvo;
    }
}
