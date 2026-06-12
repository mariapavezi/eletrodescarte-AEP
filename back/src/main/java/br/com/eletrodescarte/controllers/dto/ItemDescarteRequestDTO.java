package br.com.eletrodescarte.controllers.dto;

import br.com.eletrodescarte.enums.TipoEletronico;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ItemDescarteRequestDTO {
    @NotNull(message = "Tipo de eletrônico é obrigatório")
    private TipoEletronico tipoEletronico;

    @Positive(message = "Peso deve ser positivo")
    private double pesoKg;
}
