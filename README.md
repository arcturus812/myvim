# myvim

개인용 vim 설정. [amix/vimrc](https://github.com/amix/vimrc)를 기반으로 플러그인과 매핑을 정리하고,
코드 리뷰(탐색·검색·Git)에 필요한 것만 남겼다.

## 요구 사항

- Vim 8.2 이상 (`+job +timers +channel`, cscope 사용 시 `+cscope`)
- Copilot Chat은 Vim 9.0 이상 + GitHub Copilot 구독
- 선택 도구 (없으면 해당 기능만 비활성)

| 도구 | 용도 |
|---|---|
| `ctags`, `cscope` | 정의/호출 관계 탐색, tagbar outline(`F12`)·상태줄 현재 함수 |
| `rg` 또는 `ag` | `,g` 프로젝트 검색 (없으면 `grep`으로 동작) |
| `flake8` 등 린터 | ALE 린트 |

    sudo dnf install ctags cscope ripgrep   # Rocky/RHEL 계열 예시 (ripgrep은 EPEL)

## 설치

    git clone --depth=1 https://github.com/arcturus812/myvim.git ~/.vim_runtime
    sh ~/.vim_runtime/install_awesome_vimrc.sh

- 플러그인 없이 기본 설정만: `sh ~/.vim_runtime/install_basic_vimrc.sh`
- 여러 사용자에게 설치 (공용 경로에 clone 후):

      sh /opt/vim_runtime/install_awesome_parameterized.sh /opt/vim_runtime user0 user1
      sh /opt/vim_runtime/install_awesome_parameterized.sh /opt/vim_runtime --all

  이 경우 `,e`와 persistent undo 경로는 `~/.vim_runtime` 고정이라 동작하지 않는다.

제거: `~/.vim_runtime` 삭제 후 `~/.vimrc`에서 `.vim_runtime` 관련 줄 삭제.

## 구성

| 경로 | 내용 |
|---|---|
| `vimrcs/basic.vim` | 기본 옵션, 창·탭·버퍼 이동 |
| `vimrcs/filetypes.vim` | 파일 타입별 설정 |
| `vimrcs/plugins_config.vim` | 플러그인 로드(pathogen)와 설정 |
| `vimrcs/extended.vim` | 컬러스킴, persistent undo, 검색·quickfix |
| `my_configs.vim` | 개인 설정 (Fn 키, ctags/cscope 자동화) |
| `sources_non_forked/` | 외부 플러그인 (`update_plugins.py`로 갱신) |
| `sources_forked/` | 수정본 플러그인 (peaksea, set_tabline, blamer.nvim, copilot-chat.vim) |
| `my_plugins/` | 추가 플러그인을 넣는 곳 (git 미추적) |

### 플러그인

| 분류 | 플러그인 |
|---|---|
| 탐색 | nerdtree, ctrlp.vim, tagbar, ack.vim |
| 편집 | vim-surround, vim-repeat, vim-commentary, auto-pairs, vim-indent-object, tabular |
| Git | vim-fugitive, vim-gitgutter, blamer.nvim |
| 린트·UI | ale, lightline.vim, vim-markdown, gruvbox, peaksea |
| AI | copilot-chat.vim (첫 `,cp` 때 로드) |

### 플러그인 업데이트

    cd ~/.vim_runtime
    python3 update_plugins.py   # requests 모듈 필요

## ctags / cscope 자동 생성

- vim 시작 시 현재 디렉토리부터 위로 `tags`, `cscope.out`을 찾아 자동 연결한다.
- 없고 현재 디렉토리가 프로젝트 루트(`.git`, `Makefile`, `CMakeLists.txt`)이면 백그라운드로 생성한다.
  `~`, `/`에서는 생성하지 않는다.
- cscope는 C/C++ 소스만 색인한다. 확장자는 `g:cscope_file_exts`로 바꿀 수 있다.
- 생성 파일은 `.git/info/exclude`에 등록되어 `git status`에 나오지 않는다.
- 쓰기 권한이 없는 디렉토리에서는 생성하지 않는다.
- 자동 갱신은 없다. 코드가 바뀌면 `:MakeTags`로 다시 만든다.

## Copilot Chat

- `,cp`: 채팅 창 열기. visual 모드에서는 선택 영역을 채팅에 붙인다. 질문을 적고 `Enter`로 전송.
- 처음 `,cp` 때 GitHub 기기 인증을 진행한다. 표시된 URL에서 코드를 입력하고 vim에서 `Enter`.
- 토큰과 기록은 `~/.vim/copilot-chat`(권한 700)에 저장된다.
- `:CopilotChatModels`로 모델 선택, `:CopilotChatReset`으로 대화 초기화.

## 주요 단축키 (리더 `,`)

**탐색**

| 키 | 동작 |
|---|---|
| `F11` / `,nf` | NERDTree 토글 / 현재 파일 위치 표시 |
| `,j` 또는 `Ctrl-f` / `Ctrl-b` | CtrlP 파일 / 버퍼 검색 |
| `F12` | tagbar: 함수·클래스 outline 창 (ctags 필요, 상태줄에 현재 함수 표시) |
| `Ctrl-]` / `Ctrl-t` | 정의로 이동 / 복귀 |
| `Ctrl-\` + `g` `c` `d` `s` | cscope: 정의, 호출하는 곳, 호출되는 함수, 심볼 참조 |
| `Ctrl-\` + `t` `e` `f` `i` | cscope: 텍스트, egrep, 파일, include하는 곳 |
| `Ctrl-@` + 위 키 | cscope 결과를 분할 창에 |

**검색·quickfix**

| 키 | 동작 |
|---|---|
| `,g 패턴` | 프로젝트 전체 검색 |
| (visual) `gv` / `*` / `,r` | 선택 영역으로 검색 / 이동 / 치환 |
| `,cc` / `,n` / `,p` | quickfix 열기 / 다음 / 이전 |
| `,<Enter>` | 검색 하이라이트 해제 |

**Git·린트**

| 키 | 동작 |
|---|---|
| `:Git` / `:Git blame` | 상태 창 / 줄별 blame |
| `,bl` | 현재 줄 옆 blame 표시 토글 (기본 켜짐, 저장 전 수정도 반영) |
| `:Gvdiffsplit [rev]` / `:0Gclog` | 비교 / 현재 파일 이력 |
| `,d` | gitgutter 토글 (기본 꺼짐, 아래 줄은 켠 뒤 동작) |
| `]c` `[c` / `,hp` `,hs` `,hu` | 다음·이전 변경 / 미리보기·stage·되돌리기 |
| `F10` | `:diffthis` |
| `,a` / `:ALEDetail` | 다음 린트 오류 / 상세 |

**창·편집**

| 키 | 동작 |
|---|---|
| `Ctrl-h/j/k/l` | 창 이동 |
| `F1` / `F2` | 창 폭 80 / 30 |
| `,l` `,h` / `,bd` | 다음·이전 버퍼 / 버퍼 닫기 |
| `,tn` `,tl` `,te` | 새 탭 / 직전 탭 / 현재 경로로 탭 열기 |
| `gcc` / `cs"'` / `vii` | 주석 토글 / 감싸기 변경 / 들여쓰기 블록 선택 |
| `:W` | sudo로 저장 |
| `,e` | `my_configs.vim` 편집 (저장 시 즉시 반영) |

`,h`는 gitgutter의 `,hp` 등과 접두어가 겹쳐 `timeoutlen`(0.5초) 뒤에 동작한다.
