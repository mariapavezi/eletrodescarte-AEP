package br.com.eletrodescarte.services.observer;

import lombok.Getter;
import org.springframework.context.ApplicationEvent;

@Getter
public class DescarteConcluidoEvent extends ApplicationEvent {
    private final Long usuarioId;
    private final int pontosGanhos;

    public DescarteConcluidoEvent(Object source, Long usuarioId, int pontosGanhos) {
        super(source);
        this.usuarioId = usuarioId;
        this.pontosGanhos = pontosGanhos;
    }
}
