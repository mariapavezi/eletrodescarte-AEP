package br.com.eletrodescarte.services;

import br.com.eletrodescarte.models.PontoColeta;
import br.com.eletrodescarte.repositories.PontoColetaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class PontoColetaService {

    @Autowired
    private PontoColetaRepository pontoColetaRepository;

    @Transactional(readOnly = true)
    public List<PontoColeta> listarPontosAtivos() {
        return pontoColetaRepository.findByAtivoTrue();
    }
}