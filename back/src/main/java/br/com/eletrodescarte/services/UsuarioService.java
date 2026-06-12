package br.com.eletrodescarte.services;

import br.com.eletrodescarte.models.Usuario;
import br.com.eletrodescarte.enums.PapelUsuario;
import br.com.eletrodescarte.repositories.UsuarioRepository;
import br.com.eletrodescarte.controllers.dto.UsuarioDTO;
import br.com.eletrodescarte.exception.ResourceNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Service
public class UsuarioService {

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Transactional
    public Usuario cadastrar(UsuarioDTO dto) {
        Usuario usuario = new Usuario();
        usuario.setNomeCompleto(dto.getNome());
        usuario.setEmail(dto.getEmail());
        usuario.setCpfCnpj(dto.getCpfCnpj());
        usuario.setPapel(PapelUsuario.CIDADAO);
        // Note: Missing password in DTO, setting a default or random if required by existing logic
        usuario.setHashSenha(passwordEncoder.encode("mudar123")); 
        return usuarioRepository.save(usuario);
    }

    public Usuario buscarPorId(Long id) {
        return usuarioRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Usuário não encontrado"));
    }

    @Transactional
    public Usuario cadastrarUsuario(Usuario usuario) {
        if (usuarioRepository.findByEmail(usuario.getEmail()).isPresent()) {
            throw new RuntimeException("E-mail já cadastrado.");
        }

        String senhaCriptografada = passwordEncoder.encode(usuario.getHashSenha());
        usuario.setHashSenha(senhaCriptografada);

        if (usuario.getPapel() == null) {
            usuario.setPapel(PapelUsuario.CIDADAO);
        }

        return usuarioRepository.save(usuario);
    }

    public Optional<Usuario> validarLogin(String email, String senhaPura) {
        Optional<Usuario> usuarioOpt = usuarioRepository.findByEmail(email);

        if (usuarioOpt.isEmpty()) {
            return Optional.empty();
        }

        Usuario usuario = usuarioOpt.get();

        if (passwordEncoder.matches(senhaPura, usuario.getHashSenha())) {
            return Optional.of(usuario);
        }

        return Optional.empty();
    }
}