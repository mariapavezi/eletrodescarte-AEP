package br.com.eletrodescarte.services.observer;

import br.com.eletrodescarte.models.Usuario;
import br.com.eletrodescarte.exception.ResourceNotFoundException;
import br.com.eletrodescarte.repositories.UsuarioRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
@RequiredArgsConstructor
public class UsuarioPointsListener {

    private final UsuarioRepository usuarioRepository;

    @EventListener
    @Transactional
    public void handleDescarteConcluido(DescarteConcluidoEvent event) {
        Usuario usuario = usuarioRepository.findById(event.getUsuarioId())
                .orElseThrow(() -> new ResourceNotFoundException("Usuário não encontrado para atualizar pontos"));
        
        usuario.setTotalPoints(usuario.getTotalPoints() + event.getPontosGanhos());
        usuarioRepository.save(usuario);
    }
}
