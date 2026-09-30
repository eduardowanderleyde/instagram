# AGENTS.md

Guia para agentes de IA e devs que forem trabalhar neste repositório.

## Visão geral

Clone do Instagram em **Rails 7.2 / Ruby 3.2.2**.

- **Auth:** Devise (`username`, `full_name`, `phone_number`, `bio`, `private`, `profile_pic`)
- **Modelos:** `User`, `Post` (várias imagens via Active Storage), `Like`, `Comment`, `Follow` (com `accepted` para perfis privados)
- **Front:** importmap + Turbo + Stimulus; JS de terceiros vendorizado em `vendor/javascript` (filepond e plugins). **Não há Node/yarn no build.**
- **CSS:** `tailwindcss-rails` v3 + `@tailwindcss/forms` (`app/assets/stylesheets/application.tailwind.css` → `tailwind.css`). Sem Bootstrap e sem Sass. Componentes reutilizáveis ficam em `@layer components` nesse arquivo: `btn`, `btn-primary`, `btn-secondary`, `btn-danger`, `btn-link`, `input`, `card`, `modal`, `modal-header`, `divider-or`.
- **Ícones:** Font Awesome 6 via CDN (cdnjs) no layout.
- **UI com Stimulus:** `dropdown_controller` (menus; fecha ao clicar fora ou com Esc), `modal_controller` (`<dialog>` nativo), `carousel_controller` (imagens do post), `like_controller` (duplo clique curte), `search_results_controller` (busca com debounce), `comments_controller` (limpa o form). O FilePond se liga a `input[type=file].filepond` em `app/javascript/custom/custom.js`.
- **Helper `avatar_tag(user, size:)`** em `ApplicationHelper`: foto de perfil redonda com fallback para `user-pp.jpeg`. Use-o em vez de repetir `profile_pic.attached? ? ... : 'user-pp.jpeg'`.
- **Flash:** renderizado uma vez no layout (`layouts/_flash_messages`); as views não precisam renderizar.
- **Banco:** SQLite em dev/test, PostgreSQL em produção (`DATABASE_URL`)
- **Paginação:** Kaminari

### Regras de privacidade

`User#visible_to?(viewer)` é a fonte única de verdade para "quem pode ver o conteúdo de quem". Ela é usada em `PostsController#show`, `LikesController`, `CommentsController#create` e `users/show`. Use-a em qualquer lugar novo que exponha posts.

- Só o dono edita, atualiza ou exclui um post (`PostsController#authorize_owner!`).
- Só o usuário seguido aceita ou recusa um pedido de follow (`current_user.follow_requests.find`).
- O feed deslogado mostra apenas posts de perfis públicos.

## Rodando localmente

Com Ruby 3.2.2 instalado (ex.: macOS com rbenv):

```bash
bundle install
bin/rails db:prepare
bin/dev            # rails server + tailwindcss:watch (Procfile.dev)

# Rodar a suíte RSpec
bin/rails tailwindcss:build
RAILS_ENV=test bin/rails db:schema:load
bundle exec rspec --exclude-pattern "spec/system/**/*_spec.rb"
```

Sem Ruby local (ex.: Windows), use Docker:

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
- **Bundler 2.5.x trava** com `undefined method 'name' for nil:NilClass` neste lockfile multiplataforma. Use o bundler 2.6.9 ou mais novo (`gem update --system` ou `bundle _2.7.2_ install`).
- **Tailwind travado em v3:** `tailwindcss-rails` está em `~> 2.6`. A 4.x traz o Tailwind v4, que tem breaking changes no CSS; só suba com migração planejada.
- **Plataformas no lockfile:** `Gemfile.lock` precisa manter `x86_64-linux` e `aarch64-linux`, além de `arm64-darwin`, senão o build Docker quebra.
- **Cache do Sprockets após remover arquivos:** no container de dev, apagar ou renomear assets (ex.: os `.scss`) pode causar 500 `cannot load such file -- sassc`. Resolve com `rm -rf tmp/cache/assets` e reiniciar o servidor.
- **Checkbox dentro de `<details>` fechado** é "invisível" para o Capybara; use `visible: :all` nos specs.
- **Espaço em disco no Windows:** o disco do Docker Desktop (WSL) cresce e não encolhe sozinho. Com o C: cheio o Docker cai ("Docker Desktop is unable to start"). Use `docker image prune -a` e `docker builder prune` antes de baixar imagens grandes (a do Playwright tem cerca de 2 GB).
- **`server.pid` órfão:** se o container de dev morrer, `docker start` falha com "A server is already running". Apague `tmp/pids/server.pid`.
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

### Correção das vulnerabilidades do Dependabot (2026-09-29)

75 alertas abertos, todos no `Gemfile.lock` (4 críticos, 19 altos).

- **Rails 7.1 → 7.2.3.2:** a linha 7.1 saiu de suporte, e os alertas críticos e altos de Active Storage e Active Support só têm correção a partir de 7.2.3.1/7.2.3.2.
- **Puma ≥ 7.2.1:** sem backport para a 6.x.
- **Devise ≥ 5.0.4:** as falhas eram em `timeoutable` e `confirmable`, que o app não usa, mas o Devise 4 também gerava o aviso de `secrets`.
- **sqlite3 ≥ 2.9.5**, apenas em dev/test.
- **Removida a gem `webdrivers`,** que travava `rubyzip < 3.0` (path traversal).
- **Demais gems** (nokogiri, rack, rack-session, net-imap, websocket-driver etc.): `bundle update` dentro das faixas permitidas.

Verificado localmente no macOS: 60 specs passando e `eager_load!` sem erros. Em dev, cadastro, feed, post com imagem, like e comentário (Turbo Stream) respondem 200.

### Migração das views para Tailwind (2026-09-30)

- Todas as views que usavam Bootstrap (navbar, busca, modais, Devise, post, perfil, sugestões) foram reescritas em Tailwind. Modais e dropdowns passaram para Stimulus + `<dialog>`.
- Removidos `bootstrap`/`@popperjs/core` (importmap e `vendor/javascript`), `custom.scss`, `hello_controller.js` e a gem `sassc`. Os CSS do FilePond viraram `.css` e agora são carregados no layout (antes não eram).
- Font Awesome carregado no layout; carrossel de imagens restaurado no post; o post agora é um card único (antes havia card duplicado no feed).
- Formulário de post separado do modal: o modal fica na navbar, e `posts/new` e `posts/edit` renderizam o mesmo form. Removido o campo `location`, que não existe no model.
- **Bug corrigido:** a edição de perfil não salvava `full_name`, `bio`, `private` e `profile_pic`, porque o sanitizer do Devise usava `:account` em vez de `:account_update`.
- **Bug corrigido:** o follow state nunca aparecia no modal de curtidas (`<% render %>` sem `=`) e quebraria para visitantes deslogados.
- **Bug corrigido:** quando a criação de post falhava, o controller redirecionava com 422, que o Turbo não segue.
- Novos specs: `spec/requests/pages_smoke_spec.rb` (renderiza as páginas principais logado e deslogado) e `spec/requests/registrations_spec.rb`.

- `spec/fixtures/files/test_image.jpg` tinha 0 bytes (imagem quebrada nos dados de teste); trocado por um JPEG real.

**Status verificado:** 64 exemplos RSpec passando e build Docker de produção OK. Screenshots com Chrome headless (Playwright) de login, cadastro, feed, pedidos de follow, modal de novo post, busca, carrossel, modal de curtidas, perfil, configurações e mobile, sem erros de JS no console.

## TODO

### Visual / front

- [x] Views migradas de Bootstrap para Tailwind + Stimulus.
- [x] Font Awesome carregado no layout.
- [x] Visual conferido via screenshots (Playwright em Docker; ver "Armadilhas" para o espaço em disco).
- [ ] Navbar no mobile: a busca fica escondida abaixo de `sm`; avaliar um ícone de busca ou uma barra inferior.
- [ ] "Forgot password?" e "Log in with Facebook" são links `#` (sem mailer nem OAuth configurados).
- [ ] Stories são placeholders fixos (`story/_story`).
- [ ] Strings da UI misturam inglês e português; padronizar (ou usar I18n).
- [x] Duplo clique para curtir: movido do `<script>` inline (que quebrava) para `like_controller.js` (Stimulus).
- [x] Carrossel de imagens no post (`carousel_controller`).
- [x] Removidos Bootstrap, Popper, `custom.scss` e a gem `sassc`.

### Backend / segurança

- [ ] `CommentsController#destroy`: permitir que o dono do post também apague comentários (hoje só o autor).
- [ ] Respeitar `allow_comments` e `show_likes_count` do post (as colunas existem mas não são aplicadas).
- [ ] Foreign keys faltando: `posts.user_id`, `follows.follower_id`, `follows.followed_id`. Adicionar `dependent:` em `User has_many :posts/likes/comments/follows`.
- [ ] `username` sem validação de presença ou unicidade e sem índice único.
- [ ] Busca de usuários (`UsersController#index`) usa `LIKE` sem escapar `%` e `_`; limitar resultados.
- [ ] `FollowsController`: `find` de um follow inexistente ou alheio levanta `RecordNotFound` (404). Avaliar resposta mais amigável.
- [x] `config.fixture_path` → `fixture_paths` no `rails_helper.rb`.
- [x] Aviso de `Rails.application.secrets` (vinha do Devise 4; resolvido com Devise 5).
- [ ] Rails 7.2 sai de suporte de segurança em ago/2026 (já passou): planejar ida para Rails 8.x.

### Infra / testes

- [ ] Decidir entre `spec/` (RSpec) e `test/` (Minitest); remover a suíte morta.
- [ ] System spec (`spec/system/user_login_spec.rb`) precisa de Chrome headless; configurar ou mudar para `rack_test`. (A gem `webdrivers` foi removida; o Selenium 4 baixa o driver sozinho.)
- [ ] Adicionar CI (GitHub Actions) rodando RSpec + `docker build`.
- [ ] Active Storage em produção usa disco local; configurar S3/GCS ou volume persistente.
- [ ] Atualizar o README (ainda cita Bootstrap, Sass e SQLite; sem instruções de setup/deploy).
- [x] Abrir PR de `fix/deploy-e-autorizacao` → `master` ([#1](https://github.com/eduardowanderleyde/instagram/pull/1)).
