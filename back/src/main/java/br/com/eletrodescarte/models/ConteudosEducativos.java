package br.com.eletrodescarte.models;

import br.com.eletrodescarte.enums.NivelConteudo;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@JsonIgnoreProperties({"hibernateLazyInitializer"})
@Entity
@Table(name = "conteudos_educativos")
public class ConteudosEducativos {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_conteudo")
    private Long idConteudo;

    private String titulo;

    @Column(unique = true)
    private String slug;

    @Column(name = "corpo_md", nullable = false, columnDefinition = "TEXT")
    private String corpoMd;

    @Enumerated(EnumType.STRING)
    private NivelConteudo nivel;

    private boolean publicado;

    @CreationTimestamp
    @Column(name = "criado_em", updatable = false)
    private LocalDateTime criadoEm;

    @UpdateTimestamp
    @Column(name = "atualizado_em")
    private LocalDateTime atualizadoEm;
}