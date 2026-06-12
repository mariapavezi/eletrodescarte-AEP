package br.com.eletrodescarte.repositories;

import br.com.eletrodescarte.models.DescarteItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface DescarteItemRepository extends JpaRepository<DescarteItem, Long> {
}
