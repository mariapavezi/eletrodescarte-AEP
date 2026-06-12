package br.com.eletrodescarte.models;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Set;

@Getter
@Setter
@NoArgsConstructor
@JsonIgnoreProperties({"hibernateLazyInitializer"})
@Entity
@Table(name = "materiais")
public class Material {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_material")
    private Long idMaterial;

    @Column(unique = true)
    private String nome;

    @Column(columnDefinition = "TEXT")
    private String descricao;

    @Column(nullable = false)
    private String unidade;

    @CreationTimestamp
    @Column(name = "criado_em", updatable = false)
    private LocalDateTime criadoEm;


    @ManyToMany(mappedBy = "materiaisAceitos")
    @JsonIgnore
    private Set<PontoColeta> pontosQueAceitam;

    @OneToMany(mappedBy = "material")
    @JsonIgnore
    private List<DescarteItem> itensDescartados;

    @OneToOne(mappedBy = "material", cascade = CascadeType.ALL)
    @JsonIgnore
    private FatoresMateriais fatoresMateriais;
}