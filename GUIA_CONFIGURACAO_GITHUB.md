# 🔧 Guia de Configuração do Backup Automático no GitHub

## 📋 Visão Geral

Este guia explica como configurar o backup automático do sistema EA Scalper no GitHub para manter um histórico seguro de todas as alterações.

## 🚀 Passo a Passo

### 1. Criar Repositório no GitHub

1. **Acesse GitHub**: https://github.com
2. **Faça login** na sua conta
3. **Clique em "New repository"** (botão verde)
4. **Configure o repositório**:
   - **Nome**: `ea-scalper-trading-system` (ou nome de sua escolha)
   - **Descrição**: `Sistema Automatizado de Classificação de Códigos de Trading - EA Scalper`
   - **Visibilidade**: Private (recomendado) ou Public
   - **NÃO marque** "Initialize with README" (já temos arquivos)
5. **Clique em "Create repository"**

### 2. Obter URL do Repositório

Após criar o repositório, você verá uma página com instruções. Copie a URL:

**HTTPS** (mais fácil para iniciantes):
```
https://github.com/SEU-USUARIO/ea-scalper-trading-system.git
```

**SSH** (mais seguro, requer configuração de chaves):
```
git@github.com:SEU-USUARIO/ea-scalper-trading-system.git
```

### 3. Configurar Autenticação

#### Opção A: Token de Acesso Pessoal (HTTPS)

1. **Vá para Settings** → **Developer settings** → **Personal access tokens** → **Tokens (classic)**
2. **Clique em "Generate new token"**
3. **Configure o token**:
   - **Note**: `EA Scalper System Backup`
   - **Expiration**: 90 days (ou No expiration)
   - **Scopes**: Marque `repo` (acesso completo aos repositórios)
4. **Clique em "Generate token"**
5. **COPIE O TOKEN** (você não verá novamente!)

#### Opção B: SSH (Avançado)

Se preferir SSH, siga o guia oficial do GitHub para configurar chaves SSH.

### 4. Configurar o Sistema

#### Método 1: Configuração Automática

```powershell
# Execute no terminal do projeto
python Development\Scripts\auto_backup_integration.py setup
```

Quando solicitado, cole a URL do seu repositório.

#### Método 2: Configuração Manual

```powershell
# Adicionar repositório remoto
git remote add origin https://github.com/SEU-USUARIO/ea-scalper-trading-system.git

# Configurar branch principal
git branch -M main

# Fazer push inicial
git push -u origin main
```

**Para HTTPS com token**, quando solicitado:
- **Username**: seu-usuario-github
- **Password**: cole-o-token-aqui

### 5. Testar o Sistema

```powershell
# Testar backup manual
python Development\Scripts\auto_backup_integration.py test

# Executar backup manual
python Development\Scripts\auto_backup_integration.py backup "Teste inicial do sistema"
```

## 🔄 Como Funciona o Backup Automático

### Backup Automático

O sistema faz backup automaticamente após:
- ✅ **Classificação de códigos**
- ✅ **Geração de relatórios**
- ✅ **Atualizações do sistema**
- ✅ **Mudanças de configuração**

### Backup Manual

```powershell
# Backup com mensagem personalizada
python Development\Scripts\git_auto_backup.py backup "Sua mensagem aqui"

# Verificar status
python Development\Scripts\git_auto_backup.py status
```

## 📊 Monitoramento

### Logs de Backup

Os logs são salvos em:
- `Development/Logs/git_backup.log`
- `Development/Logs/backup_integration.log`

### Verificar Último Backup

```powershell
git log --oneline -5
```

## 🛠️ Solução de Problemas

### Erro: "Authentication failed"

**Para HTTPS:**
1. Verifique se o token está correto
2. Verifique se o token tem permissões `repo`
3. Use o token como senha, não sua senha do GitHub

**Para SSH:**
1. Verifique se as chaves SSH estão configuradas
2. Teste: `ssh -T git@github.com`

### Erro: "Repository not found"

1. Verifique se a URL está correta
2. Verifique se você tem acesso ao repositório
3. Para repositórios privados, confirme as permissões

### Erro: "Push rejected"

```powershell
# Sincronizar com o repositório remoto
git pull origin main --allow-unrelated-histories
git push origin main
```

## 🔐 Segurança

### Boas Práticas

1. **Use tokens com escopo mínimo** necessário
2. **Configure expiração** para tokens
3. **Mantenha tokens seguros** (não compartilhe)
4. **Use repositórios privados** para códigos de trading
5. **Revogue tokens** não utilizados

### Arquivos Excluídos

O `.gitignore` já está configurado para excluir:
- Arquivos temporários
- Logs grandes
- Dados sensíveis
- Arquivos compilados

## 📞 Suporte

### Comandos Úteis

```powershell
# Ver status do Git
git status

# Ver histórico
git log --oneline -10

# Ver repositórios remotos
git remote -v

# Verificar configuração
git config --list
```

### Recursos Adicionais

- [Documentação Git](https://git-scm.com/doc)
- [GitHub Docs](https://docs.github.com)
- [Tokens de Acesso](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)

---

## ✅ Checklist de Configuração

- [ ] Repositório criado no GitHub
- [ ] URL do repositório copiada
- [ ] Token de acesso criado (se usando HTTPS)
- [ ] Sistema configurado com `auto_backup_integration.py setup`
- [ ] Push inicial realizado
- [ ] Teste de backup executado
- [ ] Logs verificados

**🎉 Parabéns! Seu sistema de backup automático está configurado e funcionando!**

Todas as alterações no sistema serão automaticamente salvas no GitHub, mantendo um histórico completo e seguro do seu projeto.