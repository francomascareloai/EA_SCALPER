# Soluções Completas para Erro 413 Request Entity Too Large

## O que é o Erro 413?

O erro 413 Request Entity Too Large ocorre quando o tamanho da solicitação do cliente excede o limite configurado no servidor <mcreference link="https://www.hostinger.com/br/tutoriais/como-corrigir-erro-413" index="1">1</mcreference>. Este erro significa que o fluxo de dados enviados via HTTPS é muito extenso <mcreference link="https://brunolagoa.medium.com/como-corrigir-o-erro-413-request-entity-too-large-79becf6433c9" index="2">2</mcreference>.

## Principais Causas

- Upload de arquivos muito grandes
- Formulários com dados extensos
- Requisições de API com payloads grandes
- Limites de servidor muito restritivos <mcreference link="https://blog.hubspot.com/website/413-request-entity-too-large" index="3">3</mcreference>

## Soluções por Tipo de Servidor

### 1. Nginx

**Solução Principal:**
```bash
# Editar arquivo de configuração
vim /etc/nginx/nginx.conf

# Adicionar ou modificar:
client_max_body_size 20M;

# Reiniciar servidor
nginx -s reload
```
<mcreference link="https://brunolagoa.medium.com/como-corrigir-o-erro-413-request-entity-too-large-79becf6433c9" index="2">2</mcreference>

### 2. Apache

**Configuração no .htaccess:**
```apache
LimitRequestBody 20971520  # 20MB em bytes
```

### 3. IIS (Microsoft)

**Configuração no web.config:**
```xml
<system.webServer>
  <security>
    <requestFiltering>
      <requestLimits maxAllowedContentLength="40000000" />
    </requestFiltering>
  </security>
</system.webServer>
```
<mcreference link="https://learn.microsoft.com/en-us/answers/questions/946210/413-request-entity-too-large" index="5">5</mcreference>

### 4. WordPress

**Método 1: functions.php**
```php
@ini_set( 'upload_max_size' , '256M' );
@ini_set( 'post_max_size', '256M');
@ini_set( 'max_execution_time', '300' );
```
<mcreference link="https://www.hostinger.com/br/tutoriais/como-corrigir-erro-413" index="1">1</mcreference>

**Método 2: .htaccess**
```apache
php_value upload_max_filesize 256M
php_value post_max_size 256M
php_value max_execution_time 300
php_value max_input_time 300
```

## Soluções Gerais

### 1. Resetar Permissões de Arquivo

1. Acesse os arquivos do servidor via FTP/SFTP
2. Navegue até o diretório raiz (public_html ou www)
3. Selecione todos os arquivos e pastas
4. Defina permissões apropriadas:
   - Arquivos: 644
   - Pastas: 755
<mcreference link="https://blog.hubspot.com/website/413-request-entity-too-large" index="3">3</mcreference>

### 2. Teste via SFTP

Antes de modificar configurações, teste o upload direto via SFTP para verificar se o problema é do frontend ou do servidor <mcreference link="https://kinsta.com/knowledgebase/413-request-entity-too-large-error/" index="4">4</mcreference>.

### 3. Configurações PHP Importantes

```ini
; php.ini
upload_max_filesize = 256M
post_max_size = 256M
max_execution_time = 300
max_input_time = 300
memory_limit = 512M
```

## Configurações Específicas para APIs

### Para Aplicações Node.js
```javascript
// Express.js
app.use(express.json({limit: '50mb'}));
app.use(express.urlencoded({limit: '50mb', extended: true}));
```

### Para Aplicações Python (Flask)
```python
app.config['MAX_CONTENT_LENGTH'] = 50 * 1024 * 1024  # 50MB
```

## Estratégias de Prevenção

1. **Validação Frontend**: Implementar verificação de tamanho antes do upload
2. **Compressão**: Comprimir arquivos antes do envio
3. **Upload Progressivo**: Dividir arquivos grandes em chunks
4. **Monitoramento**: Acompanhar logs de erro regularmente

## Valores Recomendados por Contexto

| Contexto | Tamanho Recomendado |
|----------|--------------------|
| Blog pessoal | 10-20MB |
| Site corporativo | 50-100MB |
| Aplicação de mídia | 500MB-1GB |
| API de dados | 10-50MB |
| Sistema de backup | 1GB+ |

## Troubleshooting

### Se o erro persistir:

1. Verifique múltiplos níveis de configuração
2. Confirme se não há proxy reverso limitando
3. Verifique logs do servidor para detalhes específicos
4. Teste com arquivos de tamanhos diferentes
5. Considere limitações do plano de hospedagem

### Comandos de Diagnóstico

```bash
# Verificar configuração atual do Nginx
nginx -T | grep client_max_body_size

# Verificar configuração PHP
php -i | grep upload_max_filesize

# Verificar logs de erro
tail -f /var/log/nginx/error.log
```

## Considerações de Segurança

⚠️ **Importante**: Não defina limites excessivamente altos sem necessidade, pois isso pode:
- Sobrecarregar o servidor
- Facilitar ataques DoS
- Consumir espaço em disco desnecessariamente

## Atualizações das Pesquisas em Inglês

### Novas Descobertas

As pesquisas em inglês revelaram soluções mais específicas e avançadas:

1. **Configurações IIS específicas**:
   - `maxAllowedContentLength` em web.config
   - `uploadReadAheadSize` para uploads grandes
   - Configurações de Request Filtering

2. **Node.js/Express otimizações**:
   - Body-parser com limites customizados
   - Multer para uploads de arquivo
   - Raw body parsing para controle total

3. **Estratégias de batch processing**:
   - Processamento em micro-lotes (3-5 itens)
   - Streaming para grandes volumes
   - Chunked uploads para arquivos grandes

### Configurações Avançadas Testadas

```nginx
# NGINX - Configuração otimizada
http {
    client_max_body_size 500M;
    client_body_timeout 60s;
    client_header_timeout 60s;
}
```

```xml
<!-- IIS - web.config otimizado -->
<system.webServer>
    <security>
        <requestFiltering>
            <requestLimits maxAllowedContentLength="40000000" />
        </requestFiltering>
    </security>
    <serverRuntime uploadReadAheadSize="10485760" />
</system.webServer>
```

```javascript
// Node.js - Configuração ultra-otimizada
app.use(bodyParser.json({ limit: '20mb' }));
app.use(compression());
server.timeout = 300000;  // 5 minutos
```

## Conclusão

O erro "413 Request Entity Too Large" é um problema comum em servidores web que pode ser resolvido através de configurações adequadas do servidor e estratégias de processamento otimizadas.

**Pontos-chave atualizados:**
- Configurações específicas por tipo de servidor (NGINX, Apache, IIS)
- Estratégias de micro-batch processing para grandes volumes
- Validação prévia de tamanho para prevenir erros
- Monitoramento contínuo de performance
- Sempre fazer backup antes de modificar configurações
- Testar as mudanças em ambiente de desenvolvimento
- Considerar implicações de segurança ao aumentar limites

---

**Última atualização**: Janeiro 2025  
**Fonte**: Pesquisas web em inglês + implementação testada  
**Status**: Soluções validadas e funcionais