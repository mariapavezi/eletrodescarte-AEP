package br.com.eletrodescarte.config;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
class SecurityConfigTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    @DisplayName("POST /api/descartes deve ser público para o app mobile")
    void postDescartesDeveSerPublico() throws Exception {
        String payload = """
                {
                  "observacoes": "teste",
                  "usuario": { "idUsuario": 1 },
                  "pontoColeta": { "idPonto": 1 },
                  "itens": [
                    {
                      "quantidadeKg": 1.5,
                      "material": { "idMaterial": 1 }
                    }
                  ]
                }
                """;

        mockMvc.perform(post("/api/descartes")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(payload))
                .andExpect(status().isCreated());
    }
}
