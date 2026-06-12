package br.com.eletrodescarte.services;

import br.com.eletrodescarte.models.Descarte;
import br.com.eletrodescarte.models.DescarteItem;
import br.com.eletrodescarte.repositories.DescarteRepository;
import br.com.eletrodescarte.repositories.MaterialRepository;
import br.com.eletrodescarte.repositories.PontoColetaRepository;
import br.com.eletrodescarte.repositories.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;

@Service
public class DescarteService {

    @Autowired
    private DescarteRepository descarteRepository;

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private PontoColetaRepository pontoColetaRepository;

    @Autowired
    private MaterialRepository materialRepository;

    @Transactional
    public Descarte salvarDescarte(Descarte descarteRequest) {
        if (descarteRequest.getUsuario() == null || descarteRequest.getUsuario().getIdUsuario() == null) {
            throw new IllegalArgumentException("Usuário é obrigatório.");
        }
        if (descarteRequest.getPontoColeta() == null || descarteRequest.getPontoColeta().getIdPonto() == null) {
            throw new IllegalArgumentException("Ponto de coleta é obrigatório.");
        }
        if (descarteRequest.getItens() == null || descarteRequest.getItens().isEmpty()) {
            throw new IllegalArgumentException("Informe ao menos um item de descarte.");
        }

        Descarte descarte = new Descarte();
        descarte.setObservacoes(descarteRequest.getObservacoes());
        descarte.setUsuario(
                usuarioRepository.getReferenceById(descarteRequest.getUsuario().getIdUsuario())
        );
        descarte.setPontoColeta(
                pontoColetaRepository.getReferenceById(descarteRequest.getPontoColeta().getIdPonto())
        );

        List<DescarteItem> itens = new ArrayList<>();
        for (DescarteItem itemRequest : descarteRequest.getItens()) {
            if (itemRequest.getMaterial() == null || itemRequest.getMaterial().getIdMaterial() == null) {
                throw new IllegalArgumentException("Material é obrigatório para cada item.");
            }
            if (itemRequest.getQuantidadeKg() == null) {
                throw new IllegalArgumentException("Quantidade é obrigatória para cada item.");
            }

            DescarteItem item = new DescarteItem();
            item.setQuantidadeKg(itemRequest.getQuantidadeKg());
            item.setMaterial(
                    materialRepository.getReferenceById(itemRequest.getMaterial().getIdMaterial())
            );
            item.setDescarte(descarte);
            itens.add(item);
        }

        descarte.setItens(itens);
        return descarteRepository.save(descarte);
    }
}
