package br.com.eletrodescarte.services.strategy.impl;

import br.com.eletrodescarte.enums.TipoEletronico;
import br.com.eletrodescarte.services.strategy.CalculoPontuacaoStrategy;
import org.springframework.stereotype.Component;
import java.math.BigDecimal;
import java.math.RoundingMode;

@Component
public class InformaticaStrategy implements CalculoPontuacaoStrategy {
    @Override
    public TipoEletronico getTipo() {
        return TipoEletronico.TI_INFORMATICA;
    }

    @Override
    public int calcularPontos(double peso) {
        return (int) (peso * getTipo().getPontosPorKg());
    }

    @Override
    public BigDecimal calcularCO2(double peso) {
        return BigDecimal.valueOf(peso * getTipo().getCo2PorKg()).setScale(2, RoundingMode.HALF_UP);
    }
}
