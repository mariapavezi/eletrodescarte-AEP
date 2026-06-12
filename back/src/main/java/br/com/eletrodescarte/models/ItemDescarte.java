package br.com.eletrodescarte.models;

import br.com.eletrodescarte.enums.TipoEletronico;
import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;

@Entity
@Table(name = "itens_descarte")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ItemDescarte {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    private TipoEletronico tipoEletronico;

    private double pesoKg;

    private BigDecimal pegadaCarbonoEvitada;

    private int pontosGanhos;

    @ManyToOne
    @JoinColumn(name = "agendamento_id")
    @JsonBackReference
    private AgendamentoDescarte agendamento;
}
