# AGENTS.md

Guia para agentes de IA e devs que forem trabalhar neste repositório.

## Visão geral

Clone do Instagram em **Rails 7.1 / Ruby 3.2.2**.

- **Auth:** Devise (`username`, `full_name`, `phone_number`, `bio`, `private`, `profile_pic`)
- **Modelos:** `User`, `Post` (várias imagens via Active Storage), `Like`, `Comment`, `Follow` (com `accepted` para perfis privados)
- **Front:** importmap + Turbo + Stimulus; JS de terceiros vendorizado em `vendor/javascript` (bootstrap, popper, filepond). **Não há Node/yarn no build.**
- **CSS:** `tailwindcss-rails` (`app/assets/stylesheets/application.tailwind.css` → `tailwind.css`). Algumas views ainda usam classes do Bootstrap (ver TODO).
- **Banco:** SQLite em dev/test, PostgreSQL em produção (`DATABASE_URL`)
- **Paginação:** Kaminari

### Regras de privacidade

`User#visible_to?(viewer)` é a fonte única de verdade para "quem pode ver o conteúdo de quem". Ela é usada em `PostsController#show`, `LikesController`, `CommentsController#create` e `users/show`. Use-a em qualquer lugar novo que exponha posts.

- Só o dono edita, atualiza ou exclui um post (`PostsController#authorize_owner!`).
- Só o usuário seguido aceita ou recusa um pedido de follow (`current_user.follow_requests.find`).
- O feed deslogado mostra apenas posts de perfis públicos.

## Rodando localmente

```bash
bundle install
bin/rails db:prepare
bin/dev            # rails server + tailwindcss:watch (Procfile.dev)
```

Nesta máquina (Windows) **não há Ruby instalado**. Use Docker:

```bash
# Rodar a suíte RSpec (Git Bash)
MSYS_NO_PATHCONV=1 docker run --rm -v "$(pwd -W):/src:ro" ruby:3.2.2 bash -c '
  cp -r /src /app && cd /app && rm -rf tmp/cache &&
  sed -i "s/\r$//" bin/* &&
  bundle config set without production && bundle install -j4 --quiet &&
  bin/rails tailwindcss:build &&
  RAILS_ENV=test bin/rails db:schema:load &&
  bundle exec rspec --exclude-pattern "spec/system/**/*_spec.rb"'

# Atualizar o Gemfile.lock
MSYS_NO_PATHCONV=1 docker run --rm -v "$(pwd -W):/app" -w /app ruby:3.2.2-slim bundle lock
```

## Armadilhas conhecidas

- **CRLF:** checkouts no Windows deixam `bin/*` com `\r`, o que dá `/usr/bin/env: 'ruby\r'`. O `.gitattributes` força LF em `bin/*` e `*.sh`. O Dockerfile também normaliza `bin/*` **antes** do `assets:precompile`, então não inverta essa ordem.
- **Specs precisam do CSS:** rode `bin/rails tailwindcss:build` antes do RSpec, senão os specs de view falham com `couldn't find file 'tailwind.css'`.
- **Factory de usuário é privada por padrão:** o default da coluna `users.private` é `true`. Em specs, use `create(:user, private: false)` quando o viewer não segue o dono.
- **`force_ssl` em produção:** requisições HTTP recebem 301. Para testar o container localmente, mande `X-Forwarded-Proto: https`.
- **Checar exit code:** ao verificar builds (`docker build ... | tail`), o pipe esconde falhas. Redirecione para arquivo e cheque `$?`.
- **Plataformas no lockfile:** `Gemfile.lock` precisa manter `x86_64-linux` e `aarch64-linux`, além de `arm64-darwin`, senão o build Docker quebra.
- **Duas suítes de teste:** `spec/` (RSpec, a mantida) e `test/` (Minitest, scaffold antigo).

## Deploy (Docker)

- Build: `docker build -t instagram .`. Os assets são pré-compilados no build com `SECRET_KEY_BASE_DUMMY=1`.
- Variáveis de runtime: `DATABASE_URL`, `SECRET_KEY_BASE` (ou `RAILS_MASTER_KEY`).
- `docker-entrypoint.sh` roda `db:prepare` quando o comando é `./bin/rails server`.

## Histórico de correções (branch `fix/deploy-e-autorizacao`, 2026-09-29)

### Commit `e06091d`: deploy, autorização e specs

- Feed logado quebrava com `NoMethodError` (`current_user.following` → `followings`).
- Adicionada a gem `pg` (produção usava PostgreSQL sem a gem).
- `Gemfile.lock` só tinha `arm64-darwin-23`; adicionadas as plataformas Linux.
- Criado `docker-entrypoint.sh`, que o Dockerfile referenciava mas não existia.
- Adicionadas as gems de teste que `spec/` usava e faltavam: `rspec-rails`, `factory_bot_rails`, `faker`, `shoulda-matchers`, `rails-controller-testing`.
- **Segurança:** qualquer usuário podia aceitar ou recusar follows alheios; corrigido.
- **Segurança:** qualquer usuário podia editar ou atualizar posts alheios, e `user_id` era aceito nos params; corrigido.
- **Privacidade:** feed deslogado e `posts#show` expunham posts de perfis privados; corrigido com `User#visible_to?`.
- Corrigidos 3 specs que já estavam quebrados (home suggestions, posts show, home/index view).

### Commit `53a7a30`: likes e comentários, sugestões, limpeza

- **Privacidade:** like e comentário em posts de perfis privados não seguidos agora retornam 403.
- `HomeController#set_suggestions`: trocado `User.all.sample` e o N+1 por consultas SQL, com a mesma lógica.
- Dockerfile: `assets:precompile` movido para depois da normalização de `bin/*`, porque o build falhava.
- Removidos `jsbundling-rails`, `cssbundling-rails`, `yarn`, `package.json`, `package-lock.json` e `node_modules/` versionado.
- Removidos arquivos soltos: `.DS_Store`, `*.bak`, `INPDFViewer.pdf`, o arquivo vazio `2`. O `.gitignore` foi atualizado.
- Removido o import duplicado de `filepond` em `application.js`.
- Novos specs de autorização: follows, posts (update/destroy), likes.

**Status verificado:** 60 exemplos RSpec passando (sem o system spec). A imagem Docker compila, sobe contra Postgres 16, e `/`, `/users/sign_in` e o CSS respondem 200.

## TODO

### Visual / front

- [ ] **Views com Bootstrap sem estilo.** O layout só carrega `tailwind.css`, mas navbar, dropdown de busca, modais, telas do Devise, `posts/_form`, `_liker`, `_modal_comment` e `_search_results` usam classes e JS do Bootstrap. Recomendado migrar para Tailwind + Stimulus. Não carregar o CSS do Bootstrap junto: a classe `collapse` do Tailwind conflita com a navbar do Bootstrap.
- [ ] **Font Awesome** (`fa-solid`, `fa-brands`) é usado na navbar, mas não é carregado em lugar nenhum.
- [ ] `_post.html.erb` tem um `<script>` inline que procura `post<id>_images`, elemento que não existe mais. Isso dá erro de JS e quebra o duplo clique para curtir. Mover para um controller Stimulus.
- [ ] `_post.html.erb` mostra só a primeira imagem; o carrossel foi perdido na migração para Tailwind.
- [ ] Depois de migrar, remover `bootstrap` e `@popperjs/core` do importmap e de `vendor/javascript`, e revisar `custom.scss`, `filepond*.scss` e a gem `sassc`.

### Backend / segurança

- [ ] `CommentsController#destroy`: permitir que o dono do post também apague comentários (hoje só o autor).
- [ ] Respeitar `allow_comments` e `show_likes_count` do post (as colunas existem mas não são aplicadas).
- [ ] Foreign keys faltando: `posts.user_id`, `follows.follower_id`, `follows.followed_id`. Adicionar `dependent:` em `User has_many :posts/likes/comments/follows`.
- [ ] `username` sem validação de presença ou unicidade e sem índice único.
- [ ] Busca de usuários (`UsersController#index`) usa `LIKE` sem escapar `%` e `_`; limitar resultados.
- [ ] `FollowsController`: `find` de um follow inexistente ou alheio levanta `RecordNotFound` (404). Avaliar resposta mais amigável.
- [ ] `config.fixture_path` está deprecado no `rails_helper.rb`; usar `fixture_paths`.
- [ ] Aviso de deprecação: `Rails.application.secrets` (Rails 7.2 remove).

### Infra / testes

- [ ] Decidir entre `spec/` (RSpec) e `test/` (Minitest); remover a suíte morta.
- [ ] System spec (`spec/system/user_login_spec.rb`) precisa de Chrome headless; configurar ou mudar para `rack_test`. A gem `webdrivers` está obsoleta com Selenium 4.
- [ ] Adicionar CI (GitHub Actions) rodando RSpec + `docker build`.
- [ ] Active Storage em produção usa disco local; configurar S3/GCS ou volume persistente.
- [ ] Atualizar o README (ainda cita Bootstrap e SQLite; sem instruções de setup/deploy).
- [ ] Abrir PR de `fix/deploy-e-autorizacao` → `master` (ainda não foi feito push).
