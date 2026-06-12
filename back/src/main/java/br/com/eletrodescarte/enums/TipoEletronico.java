package br.com.eletrodescarte.enums;

import lombok.Getter;

@Getter
public enum TipoEletronico {
    BATERIA_CELULAR(50, 2.5),
    TI_INFORMATICA(30, 1.8),
    LINHA_BRANCA(15, 1.2);

    private final int pontosPorKg;
    private final double co2PorKg;

    TipoEletronico(int pontosPorKg, double co2PorKg) {
        this.pontosPorKg = pontosPorKg;
        this.co2PorKg = co2PorKg;
    }
}
