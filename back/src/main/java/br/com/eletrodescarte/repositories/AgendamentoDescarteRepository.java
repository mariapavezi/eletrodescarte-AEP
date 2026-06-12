package br.com.eletrodescarte.repositories;

import br.com.eletrodescarte.models.AgendamentoDescarte;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface AgendamentoDescarteRepository extends JpaRepository<AgendamentoDescarte, Long> {
}
