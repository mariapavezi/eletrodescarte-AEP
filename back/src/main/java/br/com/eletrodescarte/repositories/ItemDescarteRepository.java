package br.com.eletrodescarte.repositories;

import br.com.eletrodescarte.models.ItemDescarte;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ItemDescarteRepository extends JpaRepository<ItemDescarte, Long> {
}
