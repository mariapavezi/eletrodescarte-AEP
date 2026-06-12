package br.com.eletrodescarte.services.strategy;

import br.com.eletrodescarte.enums.TipoEletronico;
import java.math.BigDecimal;

public interface CalculoPontuacaoStrategy {
    TipoEletronico getTipo();
    int calcularPontos(double peso);
    BigDecimal calcularCO2(double peso);
}
