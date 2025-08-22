# qrshield

A new Flutter project.

## Getting Started

# QRShield - Secure QR Code Scanner

QRShield é um aplicativo Flutter que analisa códigos QR com foco em segurança, protegendo usuários contra golpes e links maliciosos através de análise offline-first e proteção interstitial obrigatória.

## 🛡️ Características de Segurança

- **Análise Offline-First**: Heurísticas de segurança executadas localmente
- **Proteção Interstitial**: Nada abre automaticamente - sempre requer confirmação
- **Detecção de Ameaças**: Identifica esquemas perigosos, punycode, domínios suspeitos
- **Análise PIX**: Validação de checksum e identificadores PIX
- **Verificação de Reputação**: Consulta opcional a bases de dados de ameaças
- **Expansão de URLs**: Revela destinos finais de links encurtados

## 📱 Funcionalidades

### Tipos de QR Code Suportados
- **URLs**: Links da web com análise de segurança completa
- **PIX**: Códigos de pagamento com validação EMV/BR Code
- **WiFi**: Redes WiFi com alertas de segurança
- **Deep Links**: Links de aplicativos com proteção adicional
- **Contatos**: vCards e informações de contato
- **Localização**: Coordenadas geográficas
- **Comunicação**: SMS, telefone, email

### Interface do Usuário
- **Material Design 3**: Interface moderna e acessível
- **Tema Claro/Escuro**: Suporte completo a temas
- **Badges de Risco**: Indicadores visuais claros (Seguro/Suspeito/Perigoso)
- **Internacionalização**: Suporte a português brasileiro

## 🏗️ Arquitetura

### Stack Tecnológica
- **Framework**: Flutter 3.x
- **Gerenciamento de Estado**: Riverpod
- **Roteamento**: go_router
- **Câmera**: camera + google_mlkit_barcode_scanning
- **Armazenamento**: flutter_secure_storage
- **HTTP**: http
- **Testes**: flutter_test + mocktail
- **Linting**: very_good_analysis

### Estrutura do Projeto
```
lib/
├── app/                    # Configuração do app
├── core/                   # Lógica de negócio
│   ├── domain/            # Entidades e regras
│   ├── services/          # Serviços externos
│   └── utils/             # Utilitários
├── features/              # Funcionalidades
│   ├── scan/              # Escaneamento
│   ├── report/            # Análise e relatórios
│   └── settings/          # Configurações
└── shared/                # Componentes compartilhados
    ├── widgets/           # Widgets reutilizáveis
    └── i18n/              # Internacionalização
```

## 🚀 Como Executar

### Pré-requisitos
- Flutter SDK 3.0+
- Dart SDK 3.0+
- Android Studio / Xcode (para desenvolvimento mobile)

### Instalação
```bash
# Clone o repositório
git clone https://github.com/leoaalvsufg/qrshield.git
cd qrshield

# Instale as dependências
flutter pub get

# Execute o app
flutter run
```

### Testes
```bash
# Execute todos os testes
flutter test

# Execute com cobertura
flutter test --coverage

# Análise de código
flutter analyze
```

## 📊 Algoritmo de Risco

O QRShield utiliza um sistema de pontuação de risco baseado em múltiplos fatores:

### Pontuações de Risco
- **Reputação Maliciosa**: +70 pontos
- **Esquema Bloqueado**: +70 pontos (javascript:, data:, file:)
- **Deep Link**: +40 pontos
- **PIX Inválido**: +40 pontos (CRC/GUI)
- **Domínio PIX Desconhecido**: +30 pontos
- **Punycode**: +20 pontos
- **WiFi Aberto**: +20 pontos
- **Múltiplos Redirecionamentos**: +15 pontos

### Níveis de Risco
- **Seguro** (0-19): Verde - Pode prosseguir
- **Suspeito** (20-49): Laranja - Cautela recomendada
- **Perigoso** (50+): Vermelho - Alto risco

## 🔒 Privacidade

- **Offline-First**: Análise principal executada localmente
- **Dados Não Armazenados**: QR Codes não são salvos
- **Consultas Anônimas**: Apenas hashes enviados quando necessário
- **Sem Rastreamento**: Nenhum dado pessoal coletado

## 🛠️ Desenvolvimento

### Contribuindo
1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

### TODO
- [ ] Integração com APIs de reputação (Google Safe Browsing, VirusTotal)
- [ ] Suporte a mais idiomas
- [ ] Histórico de escaneamentos
- [ ] Modo offline completo
- [ ] Análise de certificados SSL
- [ ] Detecção de QR Codes malformados

## 📄 Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

## 🤝 Suporte

Para suporte, abra uma issue no GitHub ou entre em contato através do email do projeto.

---

**⚠️ Aviso**: Este aplicativo é uma ferramenta de segurança, mas não substitui o bom senso. Sempre verifique a origem dos QR Codes antes de escaneá-los.
