# 🛡️ QRShield - Lista de Verificação de Segurança

## 📋 Checklist Completo de Análise Offline-First

### 🌐 **URLs e Links Web**

#### **Esquemas Perigosos** ⚠️ CRÍTICO
- [ ] `javascript:` - Execução de código malicioso
- [ ] `data:` - Injeção de conteúdo arbitrário
- [ ] `file:` - Acesso a arquivos locais
- [ ] `ftp:` - Protocolos inseguros
- [ ] `vbscript:` - Scripts maliciosos
- [ ] `about:` - Páginas internas do navegador

#### **Domínios e TLDs Suspeitos** 🚨 ALTO RISCO
- [ ] `.ru`, `.tk`, `.ml`, `.ga`, `.cf` - TLDs frequentemente usados para phishing
- [ ] `.pw`, `.top`, `.click`, `.download` - Domínios suspeitos
- [ ] `.stream`, `.science`, `.racing`, `.review` - TLDs de baixa reputação
- [ ] `.bid`, `.win`, `.party`, `.date`, `.faith`, `.cricket` - Domínios temporários

#### **Padrões de Phishing Financeiro** 💰 CRÍTICO
- [ ] Bancos brasileiros: `itau`, `bradesco`, `santander`, `caixa`, `bb`
- [ ] Fintechs: `nubank`, `inter`, `c6bank`, `original`, `safra`
- [ ] Serviços internacionais: `paypal`, `stripe`, `square`, `wise`
- [ ] Cartões: `visa`, `mastercard`, `amex`, `elo`
- [ ] Criptomoedas: `binance`, `coinbase`, `mercadobitcoin`

#### **Imitação de Redes Sociais** 📱 ALTO RISCO
- [ ] `facebook`, `instagram`, `twitter`, `x.com`
- [ ] `linkedin`, `tiktok`, `youtube`, `whatsapp`
- [ ] `telegram`, `discord`, `snapchat`, `pinterest`
- [ ] `reddit`, `tumblr`, `twitch`, `vk`

#### **Padrões de URL Suspeitos** 🔍 MÉDIO RISCO
- [ ] Subdomínios longos: `paypal.com.verify.fake.ru`
- [ ] Caracteres especiais: `pαypal.com` (punycode)
- [ ] Encurtadores: `bit.ly`, `tinyurl`, `t.co`, `short.link`
- [ ] IPs diretos: `192.168.1.1`, `127.0.0.1`
- [ ] Portas não padrão: `:8080`, `:3000`, `:8888`

#### **Caminhos Perigosos** 📂 MÉDIO RISCO
- [ ] `/verify`, `/confirm`, `/update`, `/suspend`
- [ ] `/security`, `/urgent`, `/action-required`
- [ ] `/reset-password`, `/change-password`, `/forgot`
- [ ] `/download`, `/install`, `/setup`, `/update.exe`
- [ ] `/admin`, `/login`, `/auth`, `/oauth`

### 💳 **PIX e Pagamentos**

#### **Validação PIX EMV** ✅ CRÍTICO
- [ ] CRC16 checksum válido
- [ ] GUI (Globally Unique Identifier) válido
- [ ] Formato EMV correto
- [ ] Campos obrigatórios presentes
- [ ] Tamanho máximo respeitado (512 caracteres)

#### **Domínios PIX Dinâmico** 🏦 ALTO RISCO
- [ ] Domínios conhecidos: `pix.bcb.gov.br`, bancos oficiais
- [ ] Certificação válida (offline: lista pré-definida)
- [ ] Domínios suspeitos ou não reconhecidos
- [ ] URLs muito longas ou complexas

#### **Valores e Informações** 💰 MÉDIO RISCO
- [ ] Valores muito altos (acima de R$ 5.000)
- [ ] Informações do recebedor suspeitas
- [ ] Chaves PIX inválidas ou suspeitas
- [ ] Descrições com urgência ou pressão

### 📶 **WiFi e Redes**

#### **Configurações de Segurança** 🔒 CRÍTICO
- [ ] Redes abertas (sem senha)
- [ ] WEP (protocolo inseguro)
- [ ] WPA/WPA2 com senhas fracas
- [ ] Nomes de rede suspeitos

#### **Padrões Maliciosos** 📡 ALTO RISCO
- [ ] Nomes imitando redes legítimas: `FREE_WIFI`, `Airport_WiFi`
- [ ] Caracteres especiais ou unicode
- [ ] Redes com nomes de empresas conhecidas
- [ ] SSIDs muito longos ou estranhos

### 📱 **Deep Links e Apps**

#### **Esquemas de Aplicativo** 📲 ALTO RISCO
- [ ] `intent://` - Android intents
- [ ] `market://` - Google Play Store
- [ ] `itms://` - App Store
- [ ] Esquemas personalizados suspeitos

#### **Parâmetros Perigosos** ⚙️ MÉDIO RISCO
- [ ] URLs de redirecionamento
- [ ] Comandos de instalação
- [ ] Permissões solicitadas
- [ ] Dados sensíveis expostos

### 📧 **Contatos e Comunicação**

#### **Email e Telefone** 📞 MÉDIO RISCO
- [ ] Domínios de email suspeitos
- [ ] Números internacionais (+55, +1, etc.)
- [ ] Prefixos premium (0900, etc.)
- [ ] Formatos inválidos

#### **vCard e Contatos** 👤 BAIXO RISCO
- [ ] Informações excessivas
- [ ] URLs em campos de contato
- [ ] Caracteres especiais
- [ ] Dados inconsistentes

### 🔗 **Redirecionamentos e Encurtadores**

#### **Análise de Redirecionamentos** 🔄 ALTO RISCO
- [ ] Múltiplos redirecionamentos (>2)
- [ ] Mudança de protocolo (HTTPS → HTTP)
- [ ] Mudança de domínio suspeita
- [ ] Loops de redirecionamento

#### **Encurtadores Conhecidos** 📏 MÉDIO RISCO
- [ ] `bit.ly`, `tinyurl.com`, `t.co`
- [ ] `goo.gl`, `ow.ly`, `is.gd`
- [ ] `short.link`, `buff.ly`, `rebrand.ly`
- [ ] Encurtadores personalizados

### 🌍 **Análise Geográfica e Linguística**

#### **Indicadores Geográficos** 🗺️ MÉDIO RISCO
- [ ] TLDs de países de alto risco
- [ ] Idiomas inconsistentes
- [ ] Fusos horários suspeitos
- [ ] Padrões regionais anômalos

#### **Análise de Texto** 📝 BAIXO RISCO
- [ ] Erros ortográficos frequentes
- [ ] Mistura de idiomas
- [ ] Caracteres especiais excessivos
- [ ] Texto em maiúsculas (SPAM)

### ⏰ **Análise Temporal**

#### **Padrões de Tempo** 🕐 BAIXO RISCO
- [ ] URLs com timestamps suspeitos
- [ ] Validade muito curta
- [ ] Horários fora do padrão
- [ ] Urgência artificial

### 🔍 **Metadados e Estrutura**

#### **Análise de QR Code** 📊 TÉCNICO
- [ ] Versão do QR Code
- [ ] Nível de correção de erro
- [ ] Densidade de dados
- [ ] Padrões visuais anômalos

#### **Estrutura de Dados** 🏗️ TÉCNICO
- [ ] Codificação de caracteres
- [ ] Tamanho dos dados
- [ ] Compressão utilizada
- [ ] Metadados ocultos

### 📈 **Sistema de Pontuação**

#### **Níveis de Risco**
- **🟢 SEGURO (0-19 pontos)**: Baixo risco, pode prosseguir
- **🟡 SUSPEITO (20-49 pontos)**: Cuidado necessário, verificar origem
- **🔴 PERIGOSO (50+ pontos)**: Alto risco, não recomendado

#### **Distribuição de Pontos**
- **CRÍTICO**: 50-70 pontos
- **ALTO RISCO**: 30-45 pontos  
- **MÉDIO RISCO**: 15-25 pontos
- **BAIXO RISCO**: 5-10 pontos
- **TÉCNICO**: 0-5 pontos (informativo)

### 🎯 **Próximas Implementações**

#### **Fase 1 - Básico** (Implementado)
- [x] Esquemas perigosos
- [x] Phishing financeiro
- [x] Redes sociais
- [x] PIX EMV
- [x] WiFi básico

#### **Fase 2 - Avançado** (A implementar)
- [ ] Análise de redirecionamentos
- [ ] Deep links detalhados
- [ ] Metadados de QR Code
- [ ] Padrões geográficos

#### **Fase 3 - Expert** (Futuro)
- [ ] Machine Learning offline
- [ ] Análise comportamental
- [ ] Padrões temporais
- [ ] Correlação de dados

---

**🛡️ QRShield - Proteção Offline-First contra QR Codes maliciosos**
