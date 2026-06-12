package br.com.eletrodescarte.repositories;

import br.com.eletrodescarte.models.Descarte;
import br.com.eletrodescarte.models.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface DescarteRepository extends JpaRepository<Descarte, Long> {
    List<Descarte> findByUsuario(Usuario usuario);

    List<Descarte> findByUsuario_IdUsuarioOrderByDescartadoEmDesc(Long idUsuario);
}