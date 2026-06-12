package br.com.eletrodescarte.controllers;

import br.com.eletrodescarte.models.Cidade;
import br.com.eletrodescarte.models.Usuario;
import br.com.eletrodescarte.services.UsuarioService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    private UsuarioService usuarioService;

    private record CadastroRequestDTO(
            String nomeCompleto,
            String email,
            String senha,
            Long idCidade
    ) {}

    private record LoginRequestDTO(String email, String senha) {}

    @PostMapping("/cadastrar")
    public ResponseEntity<Usuario> cadastrarUsuario(@RequestBody CadastroRequestDTO dto) {
        try {
            Usuario novoUsuario = new Usuario();
            novoUsuario.setNomeCompleto(dto.nomeCompleto());
            novoUsuario.setEmail(dto.email());
            novoUsuario.setHashSenha(dto.senha());

            if (dto.idCidade() != null) {
                Cidade cidade = new Cidade();
                cidade.setIdCidade(dto.idCidade());
                novoUsuario.setCidade(cidade);
            }

            Usuario usuarioSalvo = usuarioService.cadastrarUsuario(novoUsuario);

            return new ResponseEntity<>(usuarioSalvo, HttpStatus.CREATED);

        } catch (RuntimeException e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().build();
        }
    }

    @PostMapping("/login")
    public ResponseEntity<Usuario> login(@RequestBody LoginRequestDTO dto) {

        Optional<Usuario> usuarioOpt = usuarioService.validarLogin(dto.email(), dto.senha());

        if (usuarioOpt.isPresent()) {
            return ResponseEntity.ok(usuarioOpt.get());
        } else {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
    }
}