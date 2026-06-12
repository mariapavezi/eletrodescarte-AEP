package br.com.eletrodescarte.controllers.dto;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class AgendamentoRequestDTO {
    @NotNull(message = "ID do usuário é obrigatório")
    private Long usuarioId;

    @NotNull(message = "ID do ponto de coleta é obrigatório")
    private Long pontoColetaId;

    @NotEmpty(message = "A lista de itens não pode estar vazia")
    private List<ItemDescarteRequestDTO> itens;
}
