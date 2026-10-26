# ZenithHub

Projeto modular em Lua/Luau para Roblox, com uma interface dividida em módulos e configuração separada.

> **Status:** projeto comunitário, sem garantia de compatibilidade contínua. O código não foi executado nem validado em ambiente Roblox durante esta revisão.

## Estrutura do repositório

| Arquivo/pasta | Responsabilidade |
| --- | --- |
| `Main.lua` | Inicialização, detecção do ambiente e coordenação dos módulos |
| `Config.lua` | Valores padrão e persistência de configurações |
| `UI.lua` | Construção da interface e integração com a biblioteca visual |
| `Loader.lua` | Carregamento e preparação dos módulos |
| `Modules/Universal.lua` | Recursos gerais de personagem e ambiente |
| `Modules/BloxFruits.lua` | Código específico para Blox Fruits |
| `ZenithHub_all.lua` | Arquivo consolidado do projeto |

## Dependências e ambiente

O projeto usa APIs de Roblox/Luau e, em alguns caminhos, funções específicas de ambientes externos, como leitura e gravação de arquivos e carregamento dinâmico de código. Essas funções não estão disponíveis em todos os ambientes Roblox.

A interface também busca componentes de terceiros pela internet. Antes de executar qualquer código, revise as fontes remotas e confirme que confia nelas. Código baixado dinamicamente pode mudar sem que este repositório seja atualizado.

## Revisão e testes

Antes de considerar uma alteração pronta:

1. Verifique erros de sintaxe de Lua/Luau com uma ferramenta compatível.
2. Teste o carregamento de cada módulo de forma isolada, sempre que possível.
3. Teste configurações ausentes, inválidas e antigas.
4. Verifique se funções de limpeza desconectam eventos e restauram somente os valores que o próprio módulo alterou.
5. Confirme manualmente as mudanças em um ambiente de teste permitido.
6. Revise as alterações em uma branch e use um pull request antes de mesclá-las à branch principal.

Documentos de apoio:
- [Checklist de revisão estática](docs/QUALITY_REVIEW.md)
- [Plano de testes e registro de execução](docs/TEST_PLAN.md)

## Uso responsável

Respeite os Termos de Uso do Roblox, as regras de cada experiência e os direitos dos criadores. Não use o projeto para prejudicar outros jogadores, contornar controles de segurança ou interferir em experiências sem autorização.

## Contribuições

Ao enviar mudanças, descreva o problema, liste os arquivos alterados, informe os testes realizados e seja transparente sobre o que ainda não foi testado.
