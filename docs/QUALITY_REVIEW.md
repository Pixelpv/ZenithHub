# Quality Review — ZenithHub

Esta lista registra pontos de confiabilidade identificados por leitura estática. Ela não substitui testes de execução e não significa que os itens abaixo já foram corrigidos.

## Itens para validar

- [ ] **Persistência de configuração:** conferir se todos os pontos de chamada de `Config.Save` passam os argumentos esperados pela função e se erros de gravação são apresentados de forma clara.
- [ ] **Formato do arquivo de configuração:** validar que o JSON carregado representa uma tabela antes de mesclar valores padrão; lidar com arquivos vazios, corrompidos ou de versões antigas.
- [ ] **Identificadores de experiência:** centralizar os PlaceIds em uma única fonte de verdade para evitar divergência entre módulos.
- [ ] **Restauração de estado:** ao desativar uma opção ou executar limpeza, restaurar o valor anterior em vez de assumir que o valor padrão é sempre correto.
- [ ] **Ciclo de vida:** garantir que conexões, tarefas e objetos criados por módulos sejam encerrados na limpeza e que a limpeza possa ser chamada mais de uma vez sem erro.
- [ ] **Carregamento de dependências:** validar dependências e mostrar mensagens de erro acionáveis quando um módulo ou biblioteca não estiver disponível.
- [ ] **Testes automatizados:** adicionar verificações para funções puras, mesclagem de configurações e tratamento de dados inválidos, onde o ambiente permitir.
- [ ] **Arquivo consolidado:** documentar como `ZenithHub_all.lua` é gerado e verificar que ele não fica desatualizado em relação aos módulos.

## Observações da revisão estática

1. Em `Main.lua`, as chamadas de salvamento passam `Config` e `cfg`, enquanto a assinatura atual de `Config.Save` recebe um único argumento `data`. É necessário alinhar a interface entre os módulos e validar a persistência em teste.
2. Os identificadores de lugar usados para detectar mundos aparecem diferentes entre `Main.lua` e `UI.lua`. Eles devem ser conferidos e definidos em um único local.
3. Em `Modules/Universal.lua`, a limpeza de algumas opções atribui valores genéricos aos objetos, em vez de preservar o estado original. Isso pode alterar propriedades que já estavam desativadas ou configuradas de outra maneira.
4. O carregamento dinâmico de bibliotecas remotas introduz dependência de rede e de conteúdo externo que pode mudar. As fontes devem ser revisadas e as falhas de carregamento tratadas explicitamente.

## Critério de conclusão

Um item só deve ser marcado como concluído depois de:
- implementar a mudança em uma branch separada;
- revisar o diff;
- executar os testes disponíveis;
- registrar limitações de teste no pull request.

**Limitação:** esta revisão foi feita por inspeção do código-fonte disponível no GitHub. O projeto não foi executado em Roblox, e o comportamento em tempo de execução permanece não verificado.
