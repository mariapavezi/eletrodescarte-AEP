package br.com.eletrodescarte.services;

import br.com.eletrodescarte.models.*;
import br.com.eletrodescarte.enums.*;
import br.com.eletrodescarte.repositories.AgendamentoDescarteRepository;
import br.com.eletrodescarte.services.observer.DescarteConcluidoEvent;
import br.com.eletrodescarte.services.strategy.CalculoPontuacaoStrategy;
import br.com.eletrodescarte.services.strategy.impl.BateriaStrategy;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Spy;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.context.ApplicationEventPublisher;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AgendamentoServiceTest {

    @Mock
    private AgendamentoDescarteRepository agendamentoRepository;

    @Mock
    private ApplicationEventPublisher eventPublisher;

    @Spy
    private List<CalculoPontuacaoStrategy> strategies = new ArrayList<>();

    @InjectMocks
    private AgendamentoService agendamentoService;

    @BeforeEach
    void setup() {
        strategies.add(new BateriaStrategy());
    }

    @Test
    void concluirDescarte_DeveCalcularPontosEPublicarEvento() {
        // Arrange
        Long agendamentoId = 1L;
        Usuario usuario = new Usuario();
        usuario.setIdUsuario(1L);
        usuario.setNomeCompleto("João");
        usuario.setTotalPoints(0);
        
        AgendamentoDescarte agendamento = AgendamentoDescarte.builder()
                .id(agendamentoId)
                .usuario(usuario)
                .status(StatusAgendamento.PENDENTE)
                .build();
        
        ItemDescarte item = ItemDescarte.builder()
                .tipoEletronico(TipoEletronico.BATERIA_CELULAR)
                .pesoKg(2.0)
                .agendamento(agendamento)
                .build();
        agendamento.getItens().add(item);

        when(agendamentoRepository.findById(agendamentoId)).thenReturn(Optional.of(agendamento));
        when(agendamentoRepository.save(any())).thenAnswer(invocation -> invocation.getArgument(0));

        // Act
        AgendamentoDescarte resultado = agendamentoService.concluirDescarte(agendamentoId);

        // Assert
        assertEquals(StatusAgendamento.CONCLUIDO, resultado.getStatus());
        assertEquals(100, item.getPontosGanhos()); // 2kg * 50 pts
        assertNotNull(item.getPegadaCarbonoEvitada());

        ArgumentCaptor<DescarteConcluidoEvent> eventCaptor = ArgumentCaptor.forClass(DescarteConcluidoEvent.class);
        verify(eventPublisher).publishEvent(eventCaptor.capture());
        
        DescarteConcluidoEvent evento = eventCaptor.getValue();
        assertEquals(usuario.getIdUsuario(), evento.getUsuarioId());
        assertEquals(100, evento.getPontosGanhos());
    }
}
